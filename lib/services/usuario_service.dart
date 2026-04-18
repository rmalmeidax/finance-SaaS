import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../model/usuario_model.dart';

class UsuarioService {
  // ── Dependências ──────────────────────────────────────────
  final FirebaseFirestore _db;
  final fb.FirebaseAuth _auth;

  /// Nome da coleção no Firestore
  static const String _colecao = 'TAB_Usuario';

  UsuarioService({
    FirebaseFirestore? db,
    fb.FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance;

  // ── Referência da coleção ─────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(_colecao);

  // ══════════════════════════════════════════════════════════
  //  LEITURA
  // ══════════════════════════════════════════════════════════

  /// Stream em tempo real de todos os usuários
  Stream<List<Usuario>> streamTodos() {
    return _ref
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Usuario.fromFirestore).toList());
  }

  /// Busca um usuário pelo ID
  Future<Usuario?> buscarPorId(String id) async {
    final doc = await _ref.doc(id).get();
    if (!doc.exists) return null;
    return Usuario.fromFirestore(doc);
  }

  /// Busca usuário pelo e-mail
  Future<Usuario?> buscarPorEmail(String email) async {
    final snap = await _ref
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Usuario.fromFirestore(snap.docs.first);
  }

  /// Lista todos (one-shot)
  Future<List<Usuario>> listarTodos() async {
    final snap = await _ref.orderBy('criadoEm', descending: true).get();
    return snap.docs.map(Usuario.fromFirestore).toList();
  }

  // ══════════════════════════════════════════════════════════
  //  CRIAÇÃO
  // ══════════════════════════════════════════════════════════

  /// Cria um novo usuário:
  ///   1. Cria conta no Firebase Auth com senha temporária
  ///   2. Salva os dados na coleção TAB_Usuario
  ///   3. Envia e-mail de redefinição de senha
  ///
  /// Retorna o [Usuario] criado com a senha temporária no campo [senhaTemporaria]
  Future<Usuario> criar({
    required String nome,
    required String sobrenome,
    required String email,
    required PerfilUsuario perfil,
    String? telefone,
    String? cargo,
    String? departamento,
    String? observacao,
  }) async {
    // Verificar duplicidade de e-mail
    final existe = await buscarPorEmail(email);
    if (existe != null) {
      throw UsuarioException('E-mail já cadastrado no sistema.');
    }

    // Gerar senha temporária segura
    final senhaTemp = _gerarSenhaTemporaria();

    // 1. Criar conta no Firebase Auth
    fb.UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: senhaTemp,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw UsuarioException(_traduzirErroAuth(e.code));
    }

    final uid = cred.user!.uid;

    // 2. Salvar no Firestore
    final usuario = Usuario(
      id: uid,
      nome: nome.trim(),
      sobrenome: sobrenome.trim(),
      email: email.trim().toLowerCase(),
      telefone: telefone?.trim(),
      cargo: cargo?.trim(),
      departamento: departamento?.trim(),
      perfil: perfil,
      status: StatusUsuario.pendente, // pendente até primeiro acesso
      criadoEm: DateTime.now(),
      primeiroAcesso: true,
      observacao: observacao?.trim(),
      senhaTemporaria: senhaTemp,
    );

    final erros = usuario.validar();
    if (erros.isNotEmpty) throw UsuarioException(erros.first);

    await _ref.doc(uid).set(usuario.toFirestore());

    // 3. Enviar e-mail de redefinição
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } catch (_) {
      // Silencia erro de e-mail — não impede o cadastro
    }

    return usuario;
  }

  // ══════════════════════════════════════════════════════════
  //  ATUALIZAÇÃO
  // ══════════════════════════════════════════════════════════

  /// Atualiza dados do usuário na coleção TAB_Usuario
  Future<void> atualizar(Usuario usuario) async {
    final erros = usuario.validar();
    if (erros.isNotEmpty) throw UsuarioException(erros.first);

    await _ref.doc(usuario.id).update({
      ...usuario.toFirestore(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  /// Altera apenas o status do usuário
  Future<void> alterarStatus(String id, StatusUsuario novoStatus) async {
    await _ref.doc(id).update({
      'status': novoStatus.name,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  /// Altera o perfil de acesso do usuário
  Future<void> alterarPerfil(String id, PerfilUsuario novoPerfil) async {
    await _ref.doc(id).update({
      'perfil': novoPerfil.name,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  // ══════════════════════════════════════════════════════════
  //  SENHA
  // ══════════════════════════════════════════════════════════

  /// Envia e-mail de redefinição de senha para o usuário
  Future<void> enviarRedefinicaoSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
          email: email.trim().toLowerCase());
    } on fb.FirebaseAuthException catch (e) {
      throw UsuarioException(_traduzirErroAuth(e.code));
    }
  }

  /// Redefine a senha diretamente (requer reautenticação)
  /// Gera nova senha temporária e envia por e-mail
  Future<String> redefinirSenhaTemporaria(String id) async {
    final usuario = await buscarPorId(id);
    if (usuario == null) throw UsuarioException('Usuário não encontrado.');

    final novaSenha = _gerarSenhaTemporaria();

    // Envia e-mail de reset (o usuário define a própria senha)
    await enviarRedefinicaoSenha(usuario.email);

    // Marca como primeiro acesso novamente
    await _ref.doc(id).update({
      'primeiroAcesso': true,
      'status': StatusUsuario.pendente.name,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });

    return novaSenha;
  }

  // ══════════════════════════════════════════════════════════
  //  EXCLUSÃO
  // ══════════════════════════════════════════════════════════

  /// Remove o usuário do Firestore (não remove do Auth por segurança)
  /// Para remover do Auth, use o Admin SDK no backend
  Future<void> excluir(String id) async {
    await _ref.doc(id).delete();
  }

  // ══════════════════════════════════════════════════════════
  //  UTILITÁRIOS PRIVADOS
  // ══════════════════════════════════════════════════════════

  /// Gera uma senha temporária segura (12 chars)
  String _gerarSenhaTemporaria() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#';
    final rng = Random.secure();
    return List.generate(12, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  /// Traduz códigos de erro do Firebase Auth para português
  String _traduzirErroAuth(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'E-mail já está em uso.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha muito fraca.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente mais tarde.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Erro de autenticação: $code';
    }
  }
}

// ══════════════════════════════════════════════════════════
//  EXCEPTION customizada
// ══════════════════════════════════════════════════════════

class UsuarioException implements Exception {
  final String mensagem;
  const UsuarioException(this.mensagem);

  @override
  String toString() => mensagem;
}
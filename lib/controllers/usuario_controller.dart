
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../model/usuario_model.dart';

import '../services/usuario_service.dart';

// ── Filtros ───────────────────────────────────────────────

enum FiltroStatusU { todos, ativo, inativo, bloqueado, pendente }

enum FiltroPerfil { todos, administrador, gerente, operador, visualizador }

// ══════════════════════════════════════════════════════════
class UsuarioController extends ChangeNotifier {
  // ── Dependência ────────────────────────────────────────
  final UsuarioService _service;

  UsuarioController({UsuarioService? service})
      : _service = service ?? UsuarioService();

  // ── Estado interno ─────────────────────────────────────
  List<Usuario> _todos = [];
  StreamSubscription<List<Usuario>>? _subscription;

  bool _carregando = false;
  bool _salvando = false;
  String? _erro;
  String? _sucesso;

  // Filtros
  String _busca = '';
  FiltroStatusU _filtroStatus = FiltroStatusU.todos;
  FiltroPerfil _filtroPerfil = FiltroPerfil.todos;

  // ── Getters públicos ────────────────────────────────────

  bool get carregando => _carregando;
  bool get salvando => _salvando;
  String? get erro => _erro;
  String? get sucesso => _sucesso;

  String get busca => _busca;
  FiltroStatusU get filtroStatus => _filtroStatus;
  FiltroPerfil get filtroPerfil => _filtroPerfil;

  // Lista filtrada + buscada
  List<Usuario> get usuarios {
    var lista = List<Usuario>.from(_todos);

    // Filtro de status
    if (_filtroStatus != FiltroStatusU.todos) {
      final statusAlvo = StatusUsuario.values.firstWhere(
            (e) => e.name == _filtroStatus.name,
        orElse: () => StatusUsuario.ativo,
      );
      lista = lista.where((u) => u.status == statusAlvo).toList();
    }

    // Filtro de perfil
    if (_filtroPerfil != FiltroPerfil.todos) {
      final perfilAlvo = PerfilUsuario.values.firstWhere(
            (e) => e.name == _filtroPerfil.name,
        orElse: () => PerfilUsuario.operador,
      );
      lista = lista.where((u) => u.perfil == perfilAlvo).toList();
    }

    // Busca textual
    if (_busca.trim().isNotEmpty) {
      final q = _busca.trim().toLowerCase();
      lista = lista.where((u) {
        return u.nomeCompleto.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            (u.cargo?.toLowerCase().contains(q) ?? false) ||
            (u.departamento?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return lista;
  }

  // Contagens para o dashboard
  int get totalAtivos =>
      _todos.where((u) => u.status == StatusUsuario.ativo).length;
  int get totalInativos =>
      _todos.where((u) => u.status == StatusUsuario.inativo).length;
  int get totalAdmins =>
      _todos.where((u) => u.perfil == PerfilUsuario.administrador).length;
  int get totalPendentes =>
      _todos.where((u) => u.status == StatusUsuario.pendente).length;

  // ══════════════════════════════════════════════════════════
  //  INICIALIZAÇÃO / STREAM
  // ══════════════════════════════════════════════════════════

  /// Inicia o stream em tempo real do Firestore
  void iniciar() {
    _carregando = true;
    notifyListeners();

    _subscription = _service.streamTodos().listen(
          (lista) {
        _todos = lista;
        _carregando = false;
        notifyListeners();
      },
      onError: (e) {
        _erro = 'Erro ao carregar usuários: $e';
        _carregando = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════
  //  FILTROS
  // ══════════════════════════════════════════════════════════

  void setBusca(String valor) {
    _busca = valor;
    notifyListeners();
  }

  void setFiltroStatus(FiltroStatusU filtro) {
    // Toggle: clicar no mesmo filtro limpa
    _filtroStatus = _filtroStatus == filtro ? FiltroStatusU.todos : filtro;
    notifyListeners();
  }

  void setFiltroPerfil(FiltroPerfil filtro) {
    _filtroPerfil = _filtroPerfil == filtro ? FiltroPerfil.todos : filtro;
    notifyListeners();
  }

  void limparFiltros() {
    _busca = '';
    _filtroStatus = FiltroStatusU.todos;
    _filtroPerfil = FiltroPerfil.todos;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════
  //  CRUD
  // ══════════════════════════════════════════════════════════

  /// Cria novo usuário — retorna a senha temporária gerada
  Future<String?> criar({
    required String nome,
    required String sobrenome,
    required String email,
    required PerfilUsuario perfil,
    String? telefone,
    String? cargo,
    String? departamento,
    String? observacao,
  }) async {
    _limparMensagens();
    _salvando = true;
    notifyListeners();

    try {
      final usuario = await _service.criar(
        nome: nome,
        sobrenome: sobrenome,
        email: email,
        perfil: perfil,
        telefone: telefone,
        cargo: cargo,
        departamento: departamento,
        observacao: observacao,
      );

      _sucesso = 'Usuário ${usuario.nomeCompleto} criado com sucesso!';
      notifyListeners();
      return usuario.senhaTemporaria;
    } on UsuarioException catch (e) {
      _erro = e.mensagem;
      notifyListeners();
      return null;
    } catch (e) {
      _erro = 'Erro inesperado ao criar usuário.';
      notifyListeners();
      return null;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  /// Atualiza um usuário existente
  Future<bool> atualizar(Usuario usuario) async {
    _limparMensagens();
    _salvando = true;
    notifyListeners();

    try {
      await _service.atualizar(usuario);
      _sucesso = 'Usuário atualizado com sucesso!';
      notifyListeners();
      return true;
    } on UsuarioException catch (e) {
      _erro = e.mensagem;
      notifyListeners();
      return false;
    } catch (_) {
      _erro = 'Erro ao atualizar usuário.';
      notifyListeners();
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  /// Alterna status ativo/inativo
  Future<void> alterarStatus(String id, StatusUsuario novoStatus) async {
    _limparMensagens();
    try {
      await _service.alterarStatus(id, novoStatus);
      _sucesso = 'Status alterado com sucesso!';
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao alterar status.';
      notifyListeners();
    }
  }

  /// Envia e-mail de redefinição de senha
  Future<bool> redefinirSenha(String email) async {
    _limparMensagens();
    _salvando = true;
    notifyListeners();

    try {
      await _service.enviarRedefinicaoSenha(email);
      _sucesso =
      'E-mail de redefinição enviado para $email';
      notifyListeners();
      return true;
    } on UsuarioException catch (e) {
      _erro = e.mensagem;
      notifyListeners();
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  /// Exclui um usuário
  Future<bool> excluir(String id) async {
    _limparMensagens();
    try {
      await _service.excluir(id);
      _sucesso = 'Usuário removido com sucesso!';
      notifyListeners();
      return true;
    } catch (_) {
      _erro = 'Erro ao excluir usuário.';
      notifyListeners();
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────

  void _limparMensagens() {
    _erro = null;
    _sucesso = null;
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  void limparSucesso() {
    _sucesso = null;
    notifyListeners();
  }
}
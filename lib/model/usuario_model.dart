// ============================================================
//  MODEL — TAB_Usuario
//  Representa a entidade de usuário vinculada à coleção
//  Firestore: TAB_Usuario
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

enum PerfilUsuario { administrador, gerente, operador, visualizador }

enum StatusUsuario { ativo, inativo, bloqueado, pendente }

extension PerfilUsuarioExt on PerfilUsuario {
  String get label {
    switch (this) {
      case PerfilUsuario.administrador:
        return 'Administrador';
      case PerfilUsuario.gerente:
        return 'Gerente';
      case PerfilUsuario.operador:
        return 'Operador';
      case PerfilUsuario.visualizador:
        return 'Visualizador';
    }
  }

  String get descricao {
    switch (this) {
      case PerfilUsuario.administrador:
        return 'Acesso total ao sistema';
      case PerfilUsuario.gerente:
        return 'Gerencia equipes e relatórios';
      case PerfilUsuario.operador:
        return 'Operações do dia a dia';
      case PerfilUsuario.visualizador:
        return 'Somente leitura';
    }
  }
}

extension StatusUsuarioExt on StatusUsuario {
  String get label {
    switch (this) {
      case StatusUsuario.ativo:
        return 'Ativo';
      case StatusUsuario.inativo:
        return 'Inativo';
      case StatusUsuario.bloqueado:
        return 'Bloqueado';
      case StatusUsuario.pendente:
        return 'Pendente';
    }
  }
}

class Usuario {
  final String id;
  final String nome;
  final String sobrenome;
  final String email;
  final String? telefone;
  final String? cargo;
  final String? departamento;
  final String? avatarUrl;
  final PerfilUsuario perfil;
  final StatusUsuario status;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;
  final DateTime? ultimoAcesso;
  final bool primeiroAcesso;
  final String? observacao;

  // Campos de controle (não armazenados no Firestore)
  final String? senhaTemporaria;

  const Usuario({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    this.telefone,
    this.cargo,
    this.departamento,
    this.avatarUrl,
    required this.perfil,
    required this.status,
    required this.criadoEm,
    this.atualizadoEm,
    this.ultimoAcesso,
    this.primeiroAcesso = true,
    this.observacao,
    this.senhaTemporaria,
  });

  /// Nome completo
  String get nomeCompleto => '$nome $sobrenome'.trim();

  /// Iniciais para avatar
  String get iniciais {
    final partes = nomeCompleto.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    }
    return partes.first.isNotEmpty ? partes.first[0].toUpperCase() : '?';
  }

  // ── Validações ──────────────────────────────────────────

  /// Retorna lista de erros de validação
  List<String> validar() {
    final erros = <String>[];

    if (nome.trim().isEmpty) {
      erros.add('Nome é obrigatório');
    } else if (nome.trim().length < 2) {
      erros.add('Nome deve ter pelo menos 2 caracteres');
    }

    if (sobrenome.trim().isEmpty) {
      erros.add('Sobrenome é obrigatório');
    }

    if (email.trim().isEmpty) {
      erros.add('E-mail é obrigatório');
    } else if (!_emailValido(email)) {
      erros.add('E-mail inválido');
    }

    if (telefone != null && telefone!.isNotEmpty) {
      final digits = telefone!.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10) {
        erros.add('Telefone inválido');
      }
    }

    return erros;
  }

  bool _emailValido(String email) =>
      RegExp(r'^[\w\-\.]+@[\w\-]+\.\w{2,}$').hasMatch(email.trim());

  // ── Serialização ────────────────────────────────────────

  /// Para salvar no Firestore — nunca inclui senha
  Map<String, dynamic> toFirestore() => {
    'nome': nome.trim(),
    'sobrenome': sobrenome.trim(),
    'email': email.trim().toLowerCase(),
    'telefone': telefone?.trim() ?? '',
    'cargo': cargo?.trim() ?? '',
    'departamento': departamento?.trim() ?? '',
    'avatarUrl': avatarUrl ?? '',
    'perfil': perfil.name,
    'status': status.name,
    'criadoEm': Timestamp.fromDate(criadoEm),
    'atualizadoEm': atualizadoEm != null
        ? Timestamp.fromDate(atualizadoEm!)
        : FieldValue.serverTimestamp(),
    'ultimoAcesso': ultimoAcesso != null
        ? Timestamp.fromDate(ultimoAcesso!)
        : null,
    'primeiroAcesso': primeiroAcesso,
    'observacao': observacao?.trim() ?? '',
  };

  /// Para JSON simples (relatórios, exportação)
  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'sobrenome': sobrenome,
    'email': email,
    'telefone': telefone,
    'cargo': cargo,
    'departamento': departamento,
    'perfil': perfil.name,
    'status': status.name,
    'criadoEm': criadoEm.toIso8601String(),
    'atualizadoEm': atualizadoEm?.toIso8601String(),
    'ultimoAcesso': ultimoAcesso?.toIso8601String(),
    'primeiroAcesso': primeiroAcesso,
    'observacao': observacao,
  };

  /// Desserializa do Firestore
  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nome: d['nome'] ?? '',
      sobrenome: d['sobrenome'] ?? '',
      email: d['email'] ?? '',
      telefone: d['telefone'],
      cargo: d['cargo'],
      departamento: d['departamento'],
      avatarUrl: d['avatarUrl'],
      perfil: PerfilUsuario.values.firstWhere(
            (e) => e.name == d['perfil'],
        orElse: () => PerfilUsuario.operador,
      ),
      status: StatusUsuario.values.firstWhere(
            (e) => e.name == d['status'],
        orElse: () => StatusUsuario.pendente,
      ),
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm: (d['atualizadoEm'] as Timestamp?)?.toDate(),
      ultimoAcesso: (d['ultimoAcesso'] as Timestamp?)?.toDate(),
      primeiroAcesso: d['primeiroAcesso'] ?? true,
      observacao: d['observacao'],
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] ?? '',
    nome: json['nome'] ?? '',
    sobrenome: json['sobrenome'] ?? '',
    email: json['email'] ?? '',
    telefone: json['telefone'],
    cargo: json['cargo'],
    departamento: json['departamento'],
    avatarUrl: json['avatarUrl'],
    perfil: PerfilUsuario.values.firstWhere(
          (e) => e.name == json['perfil'],
      orElse: () => PerfilUsuario.operador,
    ),
    status: StatusUsuario.values.firstWhere(
          (e) => e.name == json['status'],
      orElse: () => StatusUsuario.pendente,
    ),
    criadoEm: DateTime.tryParse(json['criadoEm'] ?? '') ?? DateTime.now(),
    atualizadoEm: json['atualizadoEm'] != null
        ? DateTime.tryParse(json['atualizadoEm'])
        : null,
    ultimoAcesso: json['ultimoAcesso'] != null
        ? DateTime.tryParse(json['ultimoAcesso'])
        : null,
    primeiroAcesso: json['primeiroAcesso'] ?? true,
    observacao: json['observacao'],
  );

  /// Cria uma cópia com campos alterados
  Usuario copyWith({
    String? nome,
    String? sobrenome,
    String? email,
    String? telefone,
    String? cargo,
    String? departamento,
    String? avatarUrl,
    PerfilUsuario? perfil,
    StatusUsuario? status,
    DateTime? atualizadoEm,
    DateTime? ultimoAcesso,
    bool? primeiroAcesso,
    String? observacao,
  }) =>
      Usuario(
        id: id,
        nome: nome ?? this.nome,
        sobrenome: sobrenome ?? this.sobrenome,
        email: email ?? this.email,
        telefone: telefone ?? this.telefone,
        cargo: cargo ?? this.cargo,
        departamento: departamento ?? this.departamento,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        perfil: perfil ?? this.perfil,
        status: status ?? this.status,
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm ?? this.atualizadoEm,
        ultimoAcesso: ultimoAcesso ?? this.ultimoAcesso,
        primeiroAcesso: primeiroAcesso ?? this.primeiroAcesso,
        observacao: observacao ?? this.observacao,
      );

  @override
  String toString() =>
      'Usuario(id:$id, nome:$nomeCompleto, email:$email, perfil:${perfil.name}, status:${status.name})';
}
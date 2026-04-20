// ─────────────────────────────────────────────
// perfil_model.dart
// ─────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';

class EnderecoModel {
  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String municipio;
  final String estado;

  const EnderecoModel({
    this.cep = '',
    this.logradouro = '',
    this.numero = '',
    this.complemento = '',
    this.bairro = '',
    this.municipio = '',
    this.estado = '',
  });

  EnderecoModel copyWith({
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? municipio,
    String? estado,
  }) =>
      EnderecoModel(
        cep: cep ?? this.cep,
        logradouro: logradouro ?? this.logradouro,
        numero: numero ?? this.numero,
        complemento: complemento ?? this.complemento,
        bairro: bairro ?? this.bairro,
        municipio: municipio ?? this.municipio,
        estado: estado ?? this.estado,
      );

  factory EnderecoModel.fromViaCep(Map<String, dynamic> json) => EnderecoModel(
    cep: (json['cep'] as String? ?? '').replaceAll('-', ''),
    logradouro: json['logradouro'] as String? ?? '',
    bairro: json['bairro'] as String? ?? '',
    municipio: json['localidade'] as String? ?? '',
    estado: json['estado'] as String? ?? json['uf'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'cep': cep,
    'logradouro': logradouro,
    'numero': numero,
    'complemento': complemento,
    'bairro': bairro,
    'municipio': municipio,
    'estado': estado,
  };
}

class PerfilModel {
  final String id;
  final String nome;
  final String sobrenome;
  final String email; // somente leitura – vem do cadastro de login
  final String? telefone;
  final DateTime? dataNascimento;
  final String? fotoUrl;
  final EnderecoModel endereco;
  final String? cargo;
  final String? departamento;
  final DateTime? atualizadoEm;

  const PerfilModel({
    required this.id,
    required this.nome,
    required this.sobrenome,
    required this.email,
    this.telefone,
    this.dataNascimento,
    this.fotoUrl,
    this.endereco = const EnderecoModel(),
    this.cargo,
    this.departamento,
    this.atualizadoEm,
  });

  String get nomeCompleto => '$nome $sobrenome'.trim();

  String get iniciais {
    final n = nome.isNotEmpty ? nome[0].toUpperCase() : '';
    final s = sobrenome.isNotEmpty ? sobrenome[0].toUpperCase() : '';
    return '$n$s';
  }

  PerfilModel copyWith({
    String? id,
    String? nome,
    String? sobrenome,
    String? email,
    String? telefone,
    DateTime? dataNascimento,
    String? fotoUrl,
    EnderecoModel? endereco,
    String? cargo,
    String? departamento,
    DateTime? atualizadoEm,
  }) =>
      PerfilModel(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        sobrenome: sobrenome ?? this.sobrenome,
        email: email ?? this.email,
        telefone: telefone ?? this.telefone,
        dataNascimento: dataNascimento ?? this.dataNascimento,
        fotoUrl: fotoUrl ?? this.fotoUrl,
        endereco: endereco ?? this.endereco,
        cargo: cargo ?? this.cargo,
        departamento: departamento ?? this.departamento,
        atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      );

  factory PerfilModel.fromJson(Map<String, dynamic> json) => PerfilModel(
    id: json['id'] as String,
    nome: json['nome'] as String? ?? '',
    sobrenome: json['sobrenome'] as String? ?? '',
    email: json['email'] as String? ?? '',
    telefone: json['telefone'] as String?,
    dataNascimento: json['dataNascimento'] is Timestamp 
        ? (json['dataNascimento'] as Timestamp).toDate()
        : (json['dataNascimento'] != null ? DateTime.tryParse(json['dataNascimento'].toString()) : null),
    fotoUrl: json['fotoUrl'] as String?,
    endereco: json['endereco'] != null
        ? EnderecoModel.fromViaCep(
        json['endereco'] as Map<String, dynamic>)
        : const EnderecoModel(),
    cargo: json['cargo'] as String?,
    departamento: json['departamento'] as String?,
    atualizadoEm: json['atualizadoEm'] is Timestamp 
        ? (json['atualizadoEm'] as Timestamp).toDate()
        : (json['atualizadoEm'] != null ? DateTime.tryParse(json['atualizadoEm'].toString()) : null),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'sobrenome': sobrenome,
    'email': email,
    'telefone': telefone,
    'dataNascimento': dataNascimento != null ? Timestamp.fromDate(dataNascimento!) : null,
    'fotoUrl': fotoUrl,
    'endereco': endereco.toJson(),
    'cargo': cargo,
    'departamento': departamento,
    'atualizadoEm': atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
  };
}
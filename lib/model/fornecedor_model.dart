enum TipoPessoa { fisica, juridica }

class Fornecedor {
  final String id;
  final TipoPessoa tipoPessoa;

  // Dados principais
  final String nome;
  final String fantasia;
  final String documento; // CPF ou CNPJ

  // Endereço
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;

  // Contato
  final String telefone;
  final String email;

  // Status
  String status; // Ativo, Inativo

  Fornecedor({
    required this.id,
    required this.tipoPessoa,
    required this.nome,
    this.fantasia = '',
    required this.documento,
    this.logradouro = '',
    this.numero = '',
    this.complemento = '',
    this.bairro = '',
    this.cidade = '',
    this.estado = '',
    this.cep = '',
    this.telefone = '',
    this.email = '',
    this.status = 'Ativo',
  });

  Fornecedor copyWith({
    String? nome,
    String? fantasia,
    String? documento,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
    String? cep,
    String? telefone,
    String? email,
    String? status,
    TipoPessoa? tipoPessoa,
  }) {
    return Fornecedor(
      id: id,
      tipoPessoa: tipoPessoa ?? this.tipoPessoa,
      nome: nome ?? this.nome,
      fantasia: fantasia ?? this.fantasia,
      documento: documento ?? this.documento,
      logradouro: logradouro ?? this.logradouro,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      status: status ?? this.status,
    );
  }
}
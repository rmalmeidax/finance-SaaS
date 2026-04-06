enum TipoPessoaCliente { fisica, juridica }

class Cliente {
  final String id;
  final TipoPessoaCliente tipoPessoa;

  final String nome;
  final String fantasia;
  final String documento;

  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;

  final String telefone;
  final String email;

  String status;

  Cliente({
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
}
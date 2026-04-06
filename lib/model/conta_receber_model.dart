
enum TipoDocumento {
  boleto,
  duplicata,
  contrato,
  notaFiscal,
}

class ContaReceber {
  final String id;
  final String cliente;
  final String descricao;

  final TipoDocumento tipoDocumento;
  final String numeroDocumento;

  final DateTime dataEmissao;
  final DateTime dataVencimento;

  final double valorBoleto;
  double valorAtualizado;

  final double juros;
  final double multa;

  String status; // Pendente, Vencido, Recebido

  ContaReceber({
    required this.id,
    required this.cliente,
    required this.descricao,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.dataEmissao,
    required this.dataVencimento,
    required this.valorBoleto,
    required this.valorAtualizado,
    required this.juros,
    required this.multa,
    required this.status,
  });
}

enum TipoDocumento {
  boleto,
  duplicata,
  contrato,
  notaFiscal,
}

class ContaPagar {
  final String id;
  final String fornecedor;
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

  ContaPagar({
    required this.id,
    required this.fornecedor,
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
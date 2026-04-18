enum DescontoStatus { ativo, agendado, expirando, expirado }
enum TipoTitulo { cheque, duplicata }

extension DescontoStatusExtension on DescontoStatus {
  String get label => {
    DescontoStatus.ativo: 'ATIVO',
    DescontoStatus.agendado: 'AGENDADO',
    DescontoStatus.expirando: 'EXPIRANDO',
    DescontoStatus.expirado: 'EXPIRADO',
  }[this]!;
}

class DescontoModel {
  final String id;
  final String titulo;
  final String nomeCliente;
  final double valorNominal;
  final double taxaDesconto; // Ex: 0.05 para 5%
  final DateTime validade;
  final DescontoStatus status;
  final TipoTitulo tipo;

  DescontoModel({
    required this.id,
    required this.titulo,
    required this.nomeCliente,
    required this.valorNominal,
    required this.taxaDesconto,
    required this.validade,
    required this.status,
    required this.tipo,
  });

  // Cálculo bancário: Valor Líquido = Nominal - (Nominal * Taxa)
  double get valorLiquido => valorNominal * (1 - taxaDesconto);

  String get iniciaisCliente => nomeCliente.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase();
}

class DescontoResumo {
  final double totalBruto;
  final double totalLiquido;
  final int ativos;
  final int expirando;

  DescontoResumo({
    this.totalBruto = 0,
    this.totalLiquido = 0,
    this.ativos = 0,
    this.expirando = 0,
  });
}
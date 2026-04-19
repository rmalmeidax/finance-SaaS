// lib/features/desconto/model/desconto_model.dart

enum DescontoStatus { ativo, agendado, expirando, expirado }

enum TipoDocumento { duplicata, cheque, notaPromissoria, cce, cpr, outros }

extension DescontoStatusExtension on DescontoStatus {
  String get label {
    switch (this) {
      case DescontoStatus.ativo:     return 'Ativo';
      case DescontoStatus.agendado:  return 'Agendado';
      case DescontoStatus.expirando: return 'Expirando';
      case DescontoStatus.expirado:  return 'Expirado';
    }
  }
}

extension TipoDocumentoExtension on TipoDocumento {
  String get label {
    switch (this) {
      case TipoDocumento.duplicata:       return 'Duplicata';
      case TipoDocumento.cheque:          return 'Cheque';
      case TipoDocumento.notaPromissoria: return 'Nota Promissória';
      case TipoDocumento.cce:             return 'CCE';
      case TipoDocumento.cpr:             return 'CPR';
      case TipoDocumento.outros:          return 'Outros';
    }
  }
}

class DescontoModel {
  final String id;

  // ── Dados do título ──────────────────────────────────────
  final String numeroDocumento;
  final TipoDocumento tipoDocumento;
  final DateTime dataEmissao;
  final DateTime dataVencimento;

  // ── Valores ──────────────────────────────────────────────
  final double valorNominal;
  final double taxaJuros;     // % ao mês
  final double taxaIof;       // % sobre o valor
  final double taxaDesconto;  // % ao mês (taxa de desconto do banco)

  // ── Calculados ───────────────────────────────────────────
  double get diasCorridos =>
      dataVencimento.difference(dataEmissao).inDays.toDouble();

  double get valorJuros => valorNominal * (taxaJuros / 100) * (diasCorridos / 30);

  double get valorIof => valorNominal * (taxaIof / 100);

  double get valorDesconto =>
      valorNominal * (taxaDesconto / 100) * (diasCorridos / 30);

  double get valorLiquido =>
      valorNominal - valorDesconto - valorIof - valorJuros;

  double get cet {
    // Custo Efetivo Total aproximado (ao mês)
    final total = valorDesconto + valorIof + valorJuros;
    return (total / valorNominal) / (diasCorridos / 30) * 100;
  }

  // ── Cliente ───────────────────────────────────────────────
  final String nomeCliente;
  final String iniciaisCliente;
  final DescontoStatus status;

  const DescontoModel({
    required this.id,
    required this.numeroDocumento,
    required this.tipoDocumento,
    required this.dataEmissao,
    required this.dataVencimento,
    required this.valorNominal,
    required this.taxaJuros,
    required this.taxaIof,
    required this.taxaDesconto,
    required this.nomeCliente,
    required this.iniciaisCliente,
    required this.status,
  });

  DescontoModel copyWith({
    String? id,
    String? numeroDocumento,
    TipoDocumento? tipoDocumento,
    DateTime? dataEmissao,
    DateTime? dataVencimento,
    double? valorNominal,
    double? taxaJuros,
    double? taxaIof,
    double? taxaDesconto,
    String? nomeCliente,
    String? iniciaisCliente,
    DescontoStatus? status,
  }) {
    return DescontoModel(
      id:              id              ?? this.id,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      tipoDocumento:   tipoDocumento   ?? this.tipoDocumento,
      dataEmissao:     dataEmissao     ?? this.dataEmissao,
      dataVencimento:  dataVencimento  ?? this.dataVencimento,
      valorNominal:    valorNominal    ?? this.valorNominal,
      taxaJuros:       taxaJuros       ?? this.taxaJuros,
      taxaIof:         taxaIof         ?? this.taxaIof,
      taxaDesconto:    taxaDesconto    ?? this.taxaDesconto,
      nomeCliente:     nomeCliente     ?? this.nomeCliente,
      iniciaisCliente: iniciaisCliente ?? this.iniciaisCliente,
      status:          status          ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':              id,
    'numeroDocumento': numeroDocumento,
    'tipoDocumento':   tipoDocumento.name,
    'dataEmissao':     dataEmissao.toIso8601String(),
    'dataVencimento':  dataVencimento.toIso8601String(),
    'valorNominal':    valorNominal,
    'taxaJuros':       taxaJuros,
    'taxaIof':         taxaIof,
    'taxaDesconto':    taxaDesconto,
    'nomeCliente':     nomeCliente,
    'iniciaisCliente': iniciaisCliente,
    'status':          status.name,
  };

  factory DescontoModel.fromJson(Map<String, dynamic> json) => DescontoModel(
    id:              json['id'],
    numeroDocumento: json['numeroDocumento'],
    tipoDocumento:   TipoDocumento.values.firstWhere((e) => e.name == json['tipoDocumento']),
    dataEmissao:     DateTime.parse(json['dataEmissao']),
    dataVencimento:  DateTime.parse(json['dataVencimento']),
    valorNominal:    (json['valorNominal'] as num).toDouble(),
    taxaJuros:       (json['taxaJuros'] as num).toDouble(),
    taxaIof:         (json['taxaIof'] as num).toDouble(),
    taxaDesconto:    (json['taxaDesconto'] as num).toDouble(),
    nomeCliente:     json['nomeCliente'],
    iniciaisCliente: json['iniciaisCliente'],
    status:          DescontoStatus.values.firstWhere((e) => e.name == json['status']),
  );
}

// ── Resumo para o dashboard ──────────────────────────────────
class DescontoResumo {
  final int total;
  final int ativos;
  final int expirando;
  final double totalLiquido;
  final double totalNominal;

  const DescontoResumo({
    required this.total,
    required this.ativos,
    required this.expirando,
    required this.totalLiquido,
    required this.totalNominal,
  });
}
// lib/models/investment_model.dart

enum InvestmentType { acoes, fii, cripto, rendaFixa, etf }

class InvestmentModel {
  final String id;
  final String name;
  final InvestmentType type;
  final double investedValue;
  double currentValue;
  final double quantity;
  final DateTime entryDate;

  InvestmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.investedValue,
    required this.currentValue,
    required this.quantity,
    required this.entryDate,
  });

  double get totalReturn => currentValue - investedValue;
  double get returnPercent =>
      investedValue != 0 ? (totalReturn / investedValue) * 100 : 0;
  bool get isPositive => totalReturn >= 0;

  String get typeLabel {
    switch (type) {
      case InvestmentType.acoes:     return 'Ações';
      case InvestmentType.fii:       return 'FII';
      case InvestmentType.cripto:    return 'Cripto';
      case InvestmentType.rendaFixa: return 'Renda Fixa';
      case InvestmentType.etf:       return 'ETF';
    }
  }

  InvestmentModel copyWith({double? currentValue}) => InvestmentModel(
    id: id,
    name: name,
    type: type,
    investedValue: investedValue,
    currentValue: currentValue ?? this.currentValue,
    quantity: quantity,
    entryDate: entryDate,
  );
}

class MarketIndex {
  final String symbol;
  final String label;
  double value;
  double changePercent;
  final List<double> sparkData;

  MarketIndex({
    required this.symbol,
    required this.label,
    required this.value,
    required this.changePercent,
    required this.sparkData,
  });

  bool get isPositive => changePercent >= 0;
}

class TickerItem {
  final String symbol;
  double value;
  double changePercent;

  TickerItem({
    required this.symbol,
    required this.value,
    required this.changePercent,
  });

  bool get isPositive => changePercent >= 0;
}
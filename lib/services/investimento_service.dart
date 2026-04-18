// lib/services/investment_service.dart

import 'dart:math';
import '../model/investimento_model.dart';


class InvestmentService {
  InvestmentService._();
  static final InvestmentService instance = InvestmentService._();

  final _rng = Random();

  // ── Seed data ──────────────────────────────────────────
  List<InvestmentModel> seedInvestments() => [
    InvestmentModel(
      id: '1', name: 'PETR4', type: InvestmentType.acoes,
      investedValue: 5000, currentValue: 6238.12,
      quantity: 162, entryDate: DateTime(2024, 3, 15),
    ),
    InvestmentModel(
      id: '2', name: 'HGLG11', type: InvestmentType.fii,
      investedValue: 8000, currentValue: 8405.28,
      quantity: 52, entryDate: DateTime(2024, 1, 10),
    ),
    InvestmentModel(
      id: '3', name: 'Bitcoin', type: InvestmentType.cripto,
      investedValue: 3000, currentValue: 4162.75,
      quantity: 0.05, entryDate: DateTime(2023, 11, 20),
    ),
    InvestmentModel(
      id: '4', name: 'Tesouro IPCA+', type: InvestmentType.rendaFixa,
      investedValue: 10000, currentValue: 11340,
      quantity: 1, entryDate: DateTime(2023, 6, 1),
    ),
    InvestmentModel(
      id: '5', name: 'BOVA11', type: InvestmentType.etf,
      investedValue: 4500, currentValue: 4938.33,
      quantity: 45, entryDate: DateTime(2024, 2, 28),
    ),
  ];

  List<MarketIndex> seedIndices() => [
    MarketIndex(
      symbol: 'IBOVESPA', label: 'IBOVESPA',
      value: 136392, changePercent: 0.87,
      sparkData: _genSpark(136000, 50),
    ),
    MarketIndex(
      symbol: 'SP500', label: 'S&P 500',
      value: 5647.59, changePercent: 0.42,
      sparkData: _genSpark(5640, 20),
    ),
    MarketIndex(
      symbol: 'NASDAQ', label: 'NASDAQ',
      value: 19822, changePercent: 0.61,
      sparkData: _genSpark(19800, 20),
    ),
    MarketIndex(
      symbol: 'DOLAR', label: 'DÓLAR',
      value: 5.17, changePercent: -0.23,
      sparkData: _genSpark(5.17, 20),
    ),
    MarketIndex(
      symbol: 'BTCUSD', label: 'BTC/USD',
      value: 84307, changePercent: 1.34,
      sparkData: _genSpark(84000, 20),
    ),
  ];

  List<TickerItem> seedTicker() => [
    TickerItem(symbol: 'PETR4',  value: 38.42,  changePercent: 1.23),
    TickerItem(symbol: 'VALE3',  value: 61.18,  changePercent: -0.84),
    TickerItem(symbol: 'ITUB4',  value: 35.67,  changePercent: 0.52),
    TickerItem(symbol: 'BBDC4',  value: 16.43,  changePercent: -0.38),
    TickerItem(symbol: 'MGLU3',  value: 7.82,   changePercent: 2.14),
    TickerItem(symbol: 'WEGE3',  value: 48.90,  changePercent: 0.73),
    TickerItem(symbol: 'RENT3',  value: 54.12,  changePercent: -1.02),
    TickerItem(symbol: 'ABEV3',  value: 13.25,  changePercent: 0.19),
    TickerItem(symbol: 'B3SA3',  value: 11.38,  changePercent: -0.47),
    TickerItem(symbol: 'SUZB3',  value: 55.60,  changePercent: 1.58),
    TickerItem(symbol: 'HGLG11', value: 158.40, changePercent: 0.31),
    TickerItem(symbol: 'BTC',    value: 84307,  changePercent: 1.34),
    TickerItem(symbol: 'USD',    value: 5.17,   changePercent: -0.23),
  ];

  // ── Fluctuation ────────────────────────────────────────
  List<InvestmentModel> fluctuate(List<InvestmentModel> list) => list
      .map((i) => i.copyWith(
    currentValue: i.currentValue *
        (1 + (_rng.nextDouble() - 0.49) * 0.004),
  ))
      .toList();

  void fluctuateIndices(List<MarketIndex> indices) {
    for (final idx in indices) {
      idx.value *= 1 + (_rng.nextDouble() - 0.49) * 0.002;
      idx.changePercent += (_rng.nextDouble() - 0.5) * 0.04;
      idx.sparkData.add(
        idx.sparkData.last * (1 + (_rng.nextDouble() - 0.49) * 0.003),
      );
      if (idx.sparkData.length > 50) idx.sparkData.removeAt(0);
    }
  }

  void fluctuateTicker(List<TickerItem> items) {
    for (final t in items) {
      t.value *= 1 + (_rng.nextDouble() - 0.5) * 0.006;
      t.changePercent += (_rng.nextDouble() - 0.5) * 0.04;
    }
  }

  // ── Chart data ─────────────────────────────────────────
  List<double> generateChartData(String range) {
    final n = {'1D': 48, '1S': 42, '1M': 30, '3M': 90, '1A': 252}[range] ?? 48;
    double v = 99000;
    return List.generate(n + 1, (_) {
      v *= 1 + (_rng.nextDouble() - 0.46) * 0.008;
      return v;
    });
  }

  List<String> generateChartLabels(String range, int count) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final offset = count - 1 - i;
      if (range == '1D') {
        final d = now.subtract(Duration(minutes: offset * 30));
        return '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
      } else {
        final d = now.subtract(Duration(days: offset));
        return '${d.month}/${d.day.toString().padLeft(2, '0')}';
      }
    });
  }

  // ── CRUD ───────────────────────────────────────────────
  Future<InvestmentModel> create(InvestmentModel inv) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return inv;
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── Helpers ────────────────────────────────────────────
  List<double> _genSpark(double base, int n) {
    double v = base;
    return List.generate(n, (_) {
      v *= 1 + (_rng.nextDouble() - 0.48) * 0.005;
      return v;
    });
  }
}
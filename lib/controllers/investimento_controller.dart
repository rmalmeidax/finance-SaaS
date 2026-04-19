// lib/relatorio_controller/investment_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../model/investimento_model.dart';

import '../services/investimento_service.dart';


class InvestmentController extends ChangeNotifier {
  final InvestmentService _svc;

  InvestmentController({InvestmentService? service})
      : _svc = service ?? InvestmentService.instance {
    _init();
  }

  // ── State ──────────────────────────────────────────────
  bool loading = false;
  List<InvestmentModel> investments = [];
  List<MarketIndex>    indices     = [];
  List<TickerItem>     ticker      = [];
  List<double>         chartData   = [];
  List<String>         chartLabels = [];
  String               chartRange  = '1D';
  DateTime             now         = DateTime.now();

  // ── Derived metrics ────────────────────────────────────
  double get totalCurrent  => investments.fold(0, (s, i) => s + i.currentValue);
  double get totalInvested => investments.fold(0, (s, i) => s + i.investedValue);
  double get totalReturn   => totalCurrent - totalInvested;
  double get returnPercent => totalInvested != 0 ? (totalReturn / totalInvested) * 100 : 0;
  double get dailyChange   => investments.fold(
      0, (s, i) => s + i.currentValue * (0.003 * (i.hashCode % 3 == 0 ? -1 : 1)));

  MarketIndex get ibovespa => indices.firstWhere(
        (i) => i.symbol == 'IBOVESPA',
    orElse: () => indices.first,
  );

  List<MarketIndex> get sideIndices =>
      indices.where((i) => i.symbol != 'IBOVESPA').toList();

  InvestmentModel? get bestPerformer => investments.isEmpty
      ? null
      : investments.reduce(
          (a, b) => b.returnPercent > a.returnPercent ? b : a);

  InvestmentModel? get biggestPosition => investments.isEmpty
      ? null
      : investments.reduce((a, b) => b.currentValue > a.currentValue ? b : a);

  double get avgReturn => investments.isEmpty
      ? 0
      : investments.fold(0.0, (s, i) => s + i.returnPercent) /
      investments.length;

  // ── Timers ─────────────────────────────────────────────
  Timer? _clockTimer;
  Timer? _marketTimer;
  Timer? _portfolioTimer;

  void _init() {
    loading = true;
    investments = _svc.seedInvestments();
    indices     = _svc.seedIndices();
    ticker      = _svc.seedTicker();
    _refreshChart();
    loading = false;

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      now = DateTime.now();
      notifyListeners();
    });

    _marketTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      _svc.fluctuateIndices(indices);
      _svc.fluctuateTicker(ticker);
      notifyListeners();
    });

    _portfolioTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      investments = _svc.fluctuate(investments);
      notifyListeners();
    });
  }

  void _refreshChart() {
    chartData   = _svc.generateChartData(chartRange);
    chartLabels = _svc.generateChartLabels(chartRange, chartData.length);
  }

  void setChartRange(String range) {
    chartRange = range;
    _refreshChart();
    notifyListeners();
  }

  // ── CRUD ───────────────────────────────────────────────
  Future<void> addInvestment(InvestmentModel inv) async {
    loading = true; notifyListeners();
    final created = await _svc.create(inv);
    investments = [created, ...investments];
    loading = false; notifyListeners();
  }

  Future<void> removeInvestment(String id) async {
    await _svc.delete(id);
    investments = investments.where((i) => i.id != id).toList();
    notifyListeners();
  }

  // ── Format helpers (used by UI) ────────────────────────
  String fmtCurrency(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+,)'), (m) => '${m[1]}.')}';

  String fmtPercent(double v) =>
      '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';

  String fmtClock() =>
      '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}';

  @override
  void dispose() {
    _clockTimer?.cancel();
    _marketTimer?.cancel();
    _portfolioTimer?.cancel();
    super.dispose();
  }
}
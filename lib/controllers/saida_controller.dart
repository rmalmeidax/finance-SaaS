import 'package:flutter/material.dart';
import '../model/saida_model.dart';
import '../services/saida_service.dart';


enum FiltroPeriodoSaida { hoje, semana, mes, trimestre, todos }
enum FiltroStatusSaida { todos, pago, pendente, vencido }

class SaidaController extends ChangeNotifier {
  final SaidaService service;

  SaidaController(this.service) {
    _init();
  }

  List<Saida> _todas = [];

  String busca = '';
  FiltroPeriodoSaida filtroPeriodo = FiltroPeriodoSaida.mes;
  FiltroStatusSaida filtroStatus = FiltroStatusSaida.todos;
  CategoriaSaida? filtroCategoria;
  TipoDespesa? filtroTipo;
  DateTimeRange? periodoCustom;

  void _init() {
    service.listar().listen((lista) {
      // Auto atualiza status vencido
      final hoje = DateTime.now();
      _todas = lista.map((s) {
        if (s.status == 'Pendente' &&
            s.dataVencimento != null &&
            hoje.isAfter(s.dataVencimento!)) {
          s.status = 'Vencido';
        }
        return s;
      }).toList();
      notifyListeners();
    });
  }

  List<Saida> get saidas {
    final hoje = DateTime.now();

    return _todas.where((s) {
      final matchBusca =
          s.descricao.toLowerCase().contains(busca.toLowerCase()) ||
              s.fornecedor.toLowerCase().contains(busca.toLowerCase());

      final matchStatus = filtroStatus == FiltroStatusSaida.todos ||
          (filtroStatus == FiltroStatusSaida.pago && s.status == 'Pago') ||
          (filtroStatus == FiltroStatusSaida.pendente && s.status == 'Pendente') ||
          (filtroStatus == FiltroStatusSaida.vencido && s.status == 'Vencido');

      final matchCategoria =
          filtroCategoria == null || s.categoria == filtroCategoria;

      final matchTipo =
          filtroTipo == null || s.tipoDespesa == filtroTipo;

      bool matchPeriodo = true;
      if (periodoCustom != null) {
        matchPeriodo = s.data.isAfter(
            periodoCustom!.start.subtract(const Duration(days: 1))) &&
            s.data
                .isBefore(periodoCustom!.end.add(const Duration(days: 1)));
      } else if (filtroPeriodo == FiltroPeriodoSaida.hoje) {
        matchPeriodo = s.data.year == hoje.year &&
            s.data.month == hoje.month &&
            s.data.day == hoje.day;
      } else if (filtroPeriodo == FiltroPeriodoSaida.semana) {
        final inicio = hoje.subtract(Duration(days: hoje.weekday - 1));
        matchPeriodo =
            s.data.isAfter(inicio.subtract(const Duration(days: 1)));
      } else if (filtroPeriodo == FiltroPeriodoSaida.mes) {
        matchPeriodo =
            s.data.year == hoje.year && s.data.month == hoje.month;
      } else if (filtroPeriodo == FiltroPeriodoSaida.trimestre) {
        final tresAtras = DateTime(hoje.year, hoje.month - 2, 1);
        matchPeriodo =
            s.data.isAfter(tresAtras.subtract(const Duration(days: 1)));
      }

      return matchBusca && matchStatus && matchCategoria && matchTipo && matchPeriodo;
    }).toList();
  }

  // Totais
  double get totalSaidas => saidas.fold(0, (s, e) => s + e.valor);
  double get totalPago =>
      saidas.where((s) => s.status == 'Pago').fold(0, (s, e) => s + e.valor);
  double get totalPendente =>
      saidas.where((s) => s.status != 'Pago').fold(0, (s, e) => s + e.valor);
  double get totalFixas =>
      saidas.where((s) => s.tipoDespesa == TipoDespesa.fixa).fold(0, (s, e) => s + e.valor);
  double get totalVariaveis =>
      saidas.where((s) => s.tipoDespesa == TipoDespesa.variavel).fold(0, (s, e) => s + e.valor);

  void setBusca(String v) { busca = v; notifyListeners(); }
  void setFiltroPeriodo(FiltroPeriodoSaida v) {
    filtroPeriodo = v;
    periodoCustom = null;
    notifyListeners();
  }
  void setFiltroStatus(FiltroStatusSaida v) { filtroStatus = v; notifyListeners(); }
  void setFiltroCategoria(CategoriaSaida? v) { filtroCategoria = v; notifyListeners(); }
  void setFiltroTipo(TipoDespesa? v) { filtroTipo = v; notifyListeners(); }
  void setPeriodoCustom(DateTimeRange range) {
    periodoCustom = range;
    filtroPeriodo = FiltroPeriodoSaida.todos;
    notifyListeners();
  }

  Future<void> salvar(Saida s) async => await service.salvar(s);
  Future<void> atualizar(Saida s) async => await service.atualizar(s);
  Future<void> marcarComoPago(String id) async => await service.marcarComoPago(id);
  Future<void> excluir(String id) async => await service.excluir(id);
}
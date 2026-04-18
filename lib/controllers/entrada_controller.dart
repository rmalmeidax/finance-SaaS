import 'package:flutter/material.dart';
import '../model/entrada_model.dart';
import '../services/entrada_service.dart';


enum FiltroPeriodo { hoje, semana, mes, trimestre, todos }

class EntradaController extends ChangeNotifier {
  final EntradaService service;

  EntradaController(this.service) {
    _init();
  }

  List<Entrada> _todas = [];

  String busca = '';
  FiltroPeriodo filtroPeriodo = FiltroPeriodo.mes;
  CategoriaEntrada? filtroCategoria; // null = todas
  DateTimeRange? periodoCustom;

  void _init() {
    service.listar().listen((lista) {
      _todas = lista;
      notifyListeners();
    });
  }

  List<Entrada> get entradas {
    final hoje = DateTime.now();

    return _todas.where((e) {
      // Busca
      final matchBusca =
          e.descricao.toLowerCase().contains(busca.toLowerCase()) ||
              e.cliente.toLowerCase().contains(busca.toLowerCase());

      // Categoria
      final matchCategoria =
          filtroCategoria == null || e.categoria == filtroCategoria;

      // Período
      bool matchPeriodo = true;
      if (filtroPeriodo == FiltroPeriodo.hoje) {
        matchPeriodo = e.data.year == hoje.year &&
            e.data.month == hoje.month &&
            e.data.day == hoje.day;
      } else if (filtroPeriodo == FiltroPeriodo.semana) {
        final inicioSemana =
        hoje.subtract(Duration(days: hoje.weekday - 1));
        matchPeriodo = e.data.isAfter(
            inicioSemana.subtract(const Duration(days: 1)));
      } else if (filtroPeriodo == FiltroPeriodo.mes) {
        matchPeriodo =
            e.data.year == hoje.year && e.data.month == hoje.month;
      } else if (filtroPeriodo == FiltroPeriodo.trimestre) {
        final tresAtras =
        DateTime(hoje.year, hoje.month - 2, 1);
        matchPeriodo = e.data.isAfter(
            tresAtras.subtract(const Duration(days: 1)));
      } else if (filtroPeriodo == FiltroPeriodo.todos) {
        matchPeriodo = true;
      }

      if (periodoCustom != null) {
        matchPeriodo = e.data.isAfter(
            periodoCustom!.start.subtract(const Duration(days: 1))) &&
            e.data.isBefore(
                periodoCustom!.end.add(const Duration(days: 1)));
      }

      return matchBusca && matchCategoria && matchPeriodo;
    }).toList();
  }

  // Totais
  double get totalEntradas =>
      entradas.fold(0, (s, e) => s + e.valor);

  double totalPorCategoria(CategoriaEntrada cat) =>
      entradas.where((e) => e.categoria == cat).fold(0, (s, e) => s + e.valor);

  // Setters
  void setBusca(String v) { busca = v; notifyListeners(); }
  void setFiltroPeriodo(FiltroPeriodo v) {
    filtroPeriodo = v;
    periodoCustom = null;
    notifyListeners();
  }
  void setFiltroCategoria(CategoriaEntrada? v) {
    filtroCategoria = v;
    notifyListeners();
  }
  void setPeriodoCustom(DateTimeRange range) {
    periodoCustom = range;
    filtroPeriodo = FiltroPeriodo.todos;
    notifyListeners();
  }

  Future<void> salvar(Entrada e) async => await service.salvar(e);
  Future<void> atualizar(Entrada e) async => await service.atualizar(e);
  Future<void> excluir(String id) async => await service.excluir(id);
}
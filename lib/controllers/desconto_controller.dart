// lib/features/desconto/controller/desconto_controller.dart

import 'package:flutter/foundation.dart';
import '../model/desconto_model.dart';
import '../services/desconto_service.dart';


class DescontoState {
  final List<DescontoModel> descontos;
  final DescontoResumo? resumo;
  final DescontoStatus? filtroAtivo;
  final String busca;
  final bool carregando;
  final String? erro;

  const DescontoState({
    this.descontos   = const [],
    this.resumo,
    this.filtroAtivo,
    this.busca       = '',
    this.carregando  = false,
    this.erro,
  });

  DescontoState copyWith({
    List<DescontoModel>? descontos,
    DescontoResumo?      resumo,
    DescontoStatus?      filtroAtivo,
    String?              busca,
    bool?                carregando,
    String?              erro,
    bool                 limparErro    = false,
    bool                 limparFiltro  = false,
  }) {
    return DescontoState(
      descontos:   descontos   ?? this.descontos,
      resumo:      resumo      ?? this.resumo,
      filtroAtivo: limparFiltro ? null : (filtroAtivo ?? this.filtroAtivo),
      busca:       busca       ?? this.busca,
      carregando:  carregando  ?? this.carregando,
      erro:        limparErro  ? null : (erro ?? this.erro),
    );
  }

  bool get temErro   => erro != null;
  bool get estaVazio => !carregando && descontos.isEmpty;
  int  get total     => descontos.length;
}

class DescontoController extends ChangeNotifier {
  final IDescontoService _service;

  DescontoController({IDescontoService? service})
      : _service = service ?? DescontoService();

  DescontoState _state = const DescontoState();
  DescontoState get state => _state;

  void _emit(DescontoState s) { _state = s; notifyListeners(); }
  void _setCarregando() => _emit(_state.copyWith(carregando: true, limparErro: true));
  void _setErro(Object e) => _emit(_state.copyWith(carregando: false, erro: e.toString()));

  // ── Ações ────────────────────────────────────────────────

  Future<void> carregarDescontos() async {
    _setCarregando();
    try {
      final resultados = await Future.wait([
        _service.filtrarPorStatus(_state.filtroAtivo),
        _service.obterResumo(),
      ]);
      var lista = resultados[0] as List<DescontoModel>;

      // Aplicar busca local
      if (_state.busca.isNotEmpty) {
        final q = _state.busca.toLowerCase();
        lista = lista.where((d) =>
        d.numeroDocumento.toLowerCase().contains(q) ||
            d.nomeCliente.toLowerCase().contains(q) ||
            d.tipoDocumento.label.toLowerCase().contains(q),
        ).toList();
      }

      _emit(_state.copyWith(
        descontos:  lista,
        resumo:     resultados[1] as DescontoResumo,
        carregando: false,
      ));
    } catch (e) {
      _setErro(e);
    }
  }

  Future<void> aplicarFiltro(DescontoStatus? status) async {
    _emit(_state.copyWith(
      filtroAtivo:  status,
      limparFiltro: status == null,
    ));
    await carregarDescontos();
  }

  void setBusca(String valor) {
    _emit(_state.copyWith(busca: valor));
    carregarDescontos();
  }

  Future<void> inserirTitulo(DescontoModel desconto) async {
    _setCarregando();
    try {
      await _service.criar(desconto);
      await carregarDescontos();
    } catch (e) {
      _setErro(e);
    }
  }

  Future<void> excluirDesconto(String id) async {
    _setCarregando();
    try {
      await _service.excluir(id);
      await carregarDescontos();
    } catch (e) {
      _setErro(e);
    }
  }

  void descartarErro() => _emit(_state.copyWith(limparErro: true));
}
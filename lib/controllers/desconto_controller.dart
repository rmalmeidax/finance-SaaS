import 'package:flutter/material.dart';
import '../model/desconto_model.dart';
import '../services/desconto_service.dart';

class DescontoState {
  final List<DescontoModel> descontos;
  final bool carregando;
  final String? erro;
  final DescontoStatus? filtroAtivo;
  final DescontoResumo? resumo;

  DescontoState({
    this.descontos = const [],
    this.carregando = false,
    this.erro,
    this.filtroAtivo,
    this.resumo,
  });
}

class DescontoController extends ChangeNotifier {
  final DescontoService _service;

  DescontoState _state = DescontoState();
  List<DescontoModel> _todosDescontos = []; // Backup para busca
  String _termoBusca = "";

  DescontoController(this._service);

  DescontoState get state => _state;

  Future<void> carregarDescontos() async {
    _updateState(carregando: true);
    try {
      _todosDescontos = await _service.fetchDescontos();
      _filtrarEProcessar();
    } catch (e) {
      _updateState(carregando: false, erro: 'Falha ao carregar dados.');
    }
  }

  // Define o termo de busca vindo do TextField
  void setBusca(String valor) {
    _termoBusca = valor.toLowerCase();
    _filtrarEProcessar();
  }

  // Aplica o filtro de status (Ativo, Expirando, etc)
  void aplicarFiltro(DescontoStatus? status) {
    _state = DescontoState(
      descontos: _state.descontos,
      carregando: _state.carregando,
      filtroAtivo: status,
      resumo: _state.resumo,
    );
    _filtrarEProcessar();
  }

  void _filtrarEProcessar() {
    // Filtragem combinada: Status + Busca
    final filtrados = _todosDescontos.where((d) {
      final bateStatus = _state.filtroAtivo == null || d.status == _state.filtroAtivo;
      final bateBusca = d.titulo.toLowerCase().contains(_termoBusca) ||
          d.nomeCliente.toLowerCase().contains(_termoBusca);
      return bateStatus && bateBusca;
    }).toList();

    // Cálculos de Resumo
    double bruto = 0;
    double liquido = 0;
    int ativos = 0;
    int exp = 0;

    for (var item in filtrados) {
      bruto += item.valorNominal;
      liquido += item.valorLiquido;
      if (item.status == DescontoStatus.ativo) ativos++;
      if (item.status == DescontoStatus.expirando) exp++;
    }

    _state = DescontoState(
      descontos: filtrados,
      carregando: false,
      filtroAtivo: _state.filtroAtivo,
      resumo: DescontoResumo(
          totalBruto: bruto,
          totalLiquido: liquido,
          ativos: ativos,
          expirando: exp
      ),
    );
    notifyListeners();
  }

  void _updateState({bool carregando = false, String? erro}) {
    _state = DescontoState(
      descontos: _state.descontos,
      carregando: carregando,
      erro: erro,
      filtroAtivo: _state.filtroAtivo,
      resumo: _state.resumo,
    );
    notifyListeners();
  }
}
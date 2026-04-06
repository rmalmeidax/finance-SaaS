import 'package:flutter/material.dart';

import '../model/conta_receber_model.dart';
import '../services/conta_receber_service.dart';

enum FiltroStatus { todos, aVencer, vencidos, pagos }

class ContaReceberController extends ChangeNotifier {
  final ContaReceberService service;

  ContaReceberController(this.service) {
    _init();
  }

  List<ContaReceber> _todas = [];

  FiltroStatus filtroAtual = FiltroStatus.todos;
  String busca = "";

  void _init() {
    service.listar().listen((lista) {
      _todas = lista.map((c) {
        c.valorAtualizado = calcularValorAtualizado(c);
        return c;
      }).toList();

      notifyListeners();
    });
  }

  List<ContaReceber> get contas {
    final hoje = DateTime.now();

    return _todas.where((c) {
      final matchBusca = c.descricao.toLowerCase().contains(busca.toLowerCase()) ||
          c.cliente.toLowerCase().contains(busca.toLowerCase());

      bool matchStatus = true;

      if (filtroAtual == FiltroStatus.aVencer) {
        matchStatus = c.dataVencimento.isAfter(hoje) && c.status != "Recebido";
      } else if (filtroAtual == FiltroStatus.vencidos) {
        matchStatus = c.dataVencimento.isBefore(hoje) && c.status != "Recebido";
      } else if (filtroAtual == FiltroStatus.pagos) {
        matchStatus = c.status == "Recebido";
      }

      return matchBusca && matchStatus;
    }).toList();
  }

  // 🎯 FILTRO
  void setFiltro(FiltroStatus filtro) {
    filtroAtual = filtro;
    notifyListeners();
  }

  // 🔍 BUSCA
  void setBusca(String valor) {
    busca = valor;
    notifyListeners();
  }

  // ➕ ADICIONAR
  Future<void> adicionar(ContaReceber conta) async {
    conta.valorAtualizado = calcularValorAtualizado(conta);
    await service.adicionar(conta);
  }

  // 🔄 ATUALIZAR
  Future<void> atualizar(ContaReceber conta) async {
    conta.valorAtualizado = calcularValorAtualizado(conta);
    await service.atualizar(conta);
  }

  // 💸 MARCAR COMO PAGO
  Future<void> marcarComoRecebido(String id) async {
    await service.marcarComoRecebido(id);
  }

  // 🧮 REGRA DE NEGÓCIO (Receber)
  double calcularValorAtualizado(ContaReceber c) {
    final hoje = DateTime.now();

    // 👉 Só calcula juros se venceu
    if (hoje.isAfter(c.dataVencimento)) {
      final dias = hoje.difference(c.dataVencimento).inDays;

      // juros diário baseado no mensal
      final jurosDia = (c.juros / 100) / 30;
      final jurosTotal = c.valorBoleto * jurosDia * dias;

      // multa única
      final multa = c.valorBoleto * (c.multa / 100);

      return c.valorBoleto + jurosTotal + multa;
    }

    return c.valorBoleto;
  }
}
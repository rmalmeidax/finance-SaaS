import 'package:flutter/material.dart';

import '../model/conta_pagar_model.dart';
import '../services/conta_pagar_service.dart';

enum FiltroStatus { todos, aVencer, vencidos, pagos }

class ContaPagarController extends ChangeNotifier {
  final ContaPagarService service;

  ContaPagarController(this.service) {
    _init();
  }

  List<ContaPagar> _todas = [];

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

  // 📋 LISTA FILTRADA
  List<ContaPagar> get contas {
    final hoje = DateTime.now();

    return _todas.where((c) {
      // 🔍 busca
      final matchBusca =
          c.descricao.toLowerCase().contains(busca.toLowerCase()) ||
              c.fornecedor.toLowerCase().contains(busca.toLowerCase());

      // 🎯 status
      bool matchStatus = true;

      if (filtroAtual == FiltroStatus.aVencer) {
        matchStatus =
            c.dataVencimento.isAfter(hoje) && c.status != "Pago";
      } else if (filtroAtual == FiltroStatus.vencidos) {
        matchStatus =
            c.dataVencimento.isBefore(hoje) && c.status != "Pago";
      } else if (filtroAtual == FiltroStatus.pagos) {
        matchStatus = c.status == "Pago";
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
  Future<void> adicionar(ContaPagar conta) async {
    conta.valorAtualizado = calcularValorAtualizado(conta);
    await service.adicionar(conta);
  }

  // 🔄 ATUALIZAR
  Future<void> atualizar(ContaPagar conta) async {
    conta.valorAtualizado = calcularValorAtualizado(conta);
    await service.atualizar(conta);
  }

  // 💸 MARCAR COMO PAGO
  Future<void> marcarComoPago(String id) async {
    await service.marcarComoPago(id);
  }

  // 🧮 REGRA DE NEGÓCIO (PAGAR)
  double calcularValorAtualizado(ContaPagar c) {
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
import 'package:flutter/material.dart';
import '../model/fornecedor_model.dart';
import '../services/fornecedor_service.dart';


enum FiltroTipo { todos, pf, pj }
enum FiltroStatusF { todos, ativo, inativo }

class FornecedorController extends ChangeNotifier {
  final FornecedorService service;

  FornecedorController(this.service) {
    _init();
  }

  List<Fornecedor> _todos = [];
  bool loading = false;
  String? erro;

  String busca = '';
  FiltroTipo filtroTipo = FiltroTipo.todos;
  FiltroStatusF filtroStatus = FiltroStatusF.todos;

  void _init() {
    service.listar().listen((lista) {
      _todos = lista;
      notifyListeners();
    });
  }

  List<Fornecedor> get fornecedores {
    return _todos.where((f) {
      final matchBusca =
          f.nome.toLowerCase().contains(busca.toLowerCase()) ||
              f.documento.contains(busca) ||
              f.fantasia.toLowerCase().contains(busca.toLowerCase());

      final matchTipo = filtroTipo == FiltroTipo.todos ||
          (filtroTipo == FiltroTipo.pj && f.tipoPessoa == TipoPessoa.juridica) ||
          (filtroTipo == FiltroTipo.pf && f.tipoPessoa == TipoPessoa.fisica);

      final matchStatus = filtroStatus == FiltroStatusF.todos ||
          (filtroStatus == FiltroStatusF.ativo && f.status == 'Ativo') ||
          (filtroStatus == FiltroStatusF.inativo && f.status == 'Inativo');

      return matchBusca && matchTipo && matchStatus;
    }).toList();
  }

  void setBusca(String v) { busca = v; notifyListeners(); }
  void setFiltroTipo(FiltroTipo v) { filtroTipo = v; notifyListeners(); }
  void setFiltroStatus(FiltroStatusF v) { filtroStatus = v; notifyListeners(); }

  Future<void> salvar(Fornecedor f) async {
    await service.salvar(f);
  }

  Future<void> alterarStatus(String id, String status) async {
    await service.alterarStatus(id, status);
  }

  Future<void> excluir(String id) async {
    await service.excluir(id);
  }

  // ── BUSCAR CNPJ ──
  Future<Map<String, dynamic>?> buscarCnpj(String cnpj) async {
    loading = true;
    erro = null;
    notifyListeners();
    final result = await service.buscarCnpj(cnpj);
    loading = false;
    if (result == null) erro = 'CNPJ não encontrado ou inválido.';
    notifyListeners();
    return result;
  }
}
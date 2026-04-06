import 'package:flutter/material.dart';
import '../model/clientes_model.dart';
import '../services/cliente_service.dart';


enum FiltroTipoCliente { todos, pf, pj }
enum FiltroStatusCliente { todos, ativo, inativo }

class ClienteController extends ChangeNotifier {
  final ClienteService service;

  ClienteController(this.service) {
    _init();
  }

  List<Cliente> _todos = [];
  bool loading = false;
  String? erro;

  String busca = '';
  FiltroTipoCliente filtroTipo = FiltroTipoCliente.todos;
  FiltroStatusCliente filtroStatus = FiltroStatusCliente.todos;

  void _init() {
    service.listar().listen((lista) {
      _todos = lista;
      notifyListeners();
    });
  }

  List<Cliente> get clientes {
    return _todos.where((c) {
      final matchBusca =
          c.nome.toLowerCase().contains(busca.toLowerCase()) ||
              c.documento.contains(busca) ||
              c.fantasia.toLowerCase().contains(busca.toLowerCase());

      final matchTipo = filtroTipo == FiltroTipoCliente.todos ||
          (filtroTipo == FiltroTipoCliente.pj &&
              c.tipoPessoa == TipoPessoaCliente.juridica) ||
          (filtroTipo == FiltroTipoCliente.pf &&
              c.tipoPessoa == TipoPessoaCliente.fisica);

      final matchStatus = filtroStatus == FiltroStatusCliente.todos ||
          (filtroStatus == FiltroStatusCliente.ativo && c.status == 'Ativo') ||
          (filtroStatus == FiltroStatusCliente.inativo &&
              c.status == 'Inativo');

      return matchBusca && matchTipo && matchStatus;
    }).toList();
  }

  void setBusca(String v) { busca = v; notifyListeners(); }
  void setFiltroTipo(FiltroTipoCliente v) { filtroTipo = v; notifyListeners(); }
  void setFiltroStatus(FiltroStatusCliente v) { filtroStatus = v; notifyListeners(); }

  Future<void> salvar(Cliente c) async => await service.salvar(c);
  Future<void> alterarStatus(String id, String status) async =>
      await service.alterarStatus(id, status);
  Future<void> excluir(String id) async => await service.excluir(id);

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
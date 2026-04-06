import 'package:flutter/material.dart';
import '../model/fornecedor_model.dart';
import '../services/fornecedor_service.dart';

class FornecedorController extends ChangeNotifier {
  final service = FornecedorService();

  bool loading = false;
  Fornecedor? fornecedor;

  Future<void> buscar(String cnpj) async {
    loading = true;
    notifyListeners();

    fornecedor = await service.buscarCNPJ(cnpj);

    loading = false;
    notifyListeners();
  }
}
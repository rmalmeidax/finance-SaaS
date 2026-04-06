import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/fornecedor_model.dart';

class FornecedorService {

  Future<Fornecedor?> buscarCNPJ(String cnpj) async {
    final url = Uri.parse(
        "https://brasilapi.com.br/api/cnpj/v1/$cnpj");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Fornecedor(
        cnpj: data['cnpj'] ?? '',
        nome: data['razao_social'] ?? '',
        fantasia: data['nome_fantasia'] ?? '',
        endereco:
        "${data['logradouro'] ?? ''}, ${data['numero'] ?? ''}",
        cidade: data['municipio'] ?? '',
        estado: data['uf'] ?? '',
        telefone: data['ddd_telefone_1'] ?? '',
        email: data['email'] ?? '',
      );
    }

    return null;
  }
}
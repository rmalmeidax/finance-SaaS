import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../model/clientes_model.dart';


class ClienteService {
  final _col = FirebaseFirestore.instance.collection('tab_clientes');

  Stream<List<Cliente>> listar() {
    return _col.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final d = doc.data();
        return Cliente(
          id: doc.id,
          tipoPessoa: d['tipoPessoa'] == 'juridica'
              ? TipoPessoaCliente.juridica
              : TipoPessoaCliente.fisica,
          nome: d['nome'] ?? '',
          fantasia: d['fantasia'] ?? '',
          documento: d['documento'] ?? '',
          logradouro: d['logradouro'] ?? '',
          numero: d['numero'] ?? '',
          complemento: d['complemento'] ?? '',
          bairro: d['bairro'] ?? '',
          cidade: d['cidade'] ?? '',
          estado: d['estado'] ?? '',
          cep: d['cep'] ?? '',
          telefone: d['telefone'] ?? '',
          email: d['email'] ?? '',
          status: d['status'] ?? 'Ativo',
        );
      }).toList();
    });
  }

  Future<void> salvar(Cliente c) async {
    await _col.doc(c.id).set({
      'tipoPessoa': c.tipoPessoa.name,
      'nome': c.nome,
      'fantasia': c.fantasia,
      'documento': c.documento,
      'logradouro': c.logradouro,
      'numero': c.numero,
      'complemento': c.complemento,
      'bairro': c.bairro,
      'cidade': c.cidade,
      'estado': c.estado,
      'cep': c.cep,
      'telefone': c.telefone,
      'email': c.email,
      'status': c.status,
    });
  }

  Future<void> alterarStatus(String id, String status) async {
    await _col.doc(id).update({'status': status});
  }

  Future<void> excluir(String id) async {
    await _col.doc(id).delete();
  }

  Future<Map<String, dynamic>?> buscarCnpj(String cnpj) async {
    final raw = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://brasilapi.com.br/api/cnpj/v1/$raw');
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}
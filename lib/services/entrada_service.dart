import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/entrada_model.dart';


class EntradaService {
  final _col = FirebaseFirestore.instance.collection('tab_entradas');

  Stream<List<Entrada>> listar() {
    return _col.orderBy('data', descending: true).snapshots().map((snap) {
      return snap.docs.map((doc) {
        final d = doc.data();
        return Entrada(
          id: doc.id,
          descricao: d['descricao'] ?? '',
          cliente: d['cliente'] ?? '',
          categoria: CategoriaEntrada.values.firstWhere(
                (e) => e.name == d['categoria'],
            orElse: () => CategoriaEntrada.outros,
          ),
          data: (d['data'] as Timestamp).toDate(),
          valor: (d['valor'] as num).toDouble(),
          observacao: d['observacao'] ?? '',
          status: d['status'] ?? 'Recebido',
        );
      }).toList();
    });
  }

  Future<void> salvar(Entrada e) async {
    await _col.doc(e.id).set({
      'descricao': e.descricao,
      'cliente': e.cliente,
      'categoria': e.categoria.name,
      'data': Timestamp.fromDate(e.data),
      'valor': e.valor,
      'observacao': e.observacao,
      'status': e.status,
    });
  }

  Future<void> atualizar(Entrada e) async {
    await _col.doc(e.id).update({
      'descricao': e.descricao,
      'cliente': e.cliente,
      'categoria': e.categoria.name,
      'data': Timestamp.fromDate(e.data),
      'valor': e.valor,
      'observacao': e.observacao,
      'status': e.status,
    });
  }

  Future<void> excluir(String id) async {
    await _col.doc(id).delete();
  }
}
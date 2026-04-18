import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/saida_model.dart';


class SaidaService {
  final _col = FirebaseFirestore.instance.collection('tab_saidas');

  Stream<List<Saida>> listar() {
    return _col.orderBy('data', descending: true).snapshots().map((snap) {
      return snap.docs.map((doc) {
        final d = doc.data();
        return Saida(
          id: doc.id,
          descricao: d['descricao'] ?? '',
          fornecedor: d['fornecedor'] ?? '',
          categoria: CategoriaSaida.values.firstWhere(
                (e) => e.name == d['categoria'],
            orElse: () => CategoriaSaida.outros,
          ),
          tipoDespesa: d['tipoDespesa'] == 'fixa'
              ? TipoDespesa.fixa
              : TipoDespesa.variavel,
          data: (d['data'] as Timestamp).toDate(),
          dataVencimento: d['dataVencimento'] != null
              ? (d['dataVencimento'] as Timestamp).toDate()
              : null,
          valor: (d['valor'] as num).toDouble(),
          observacao: d['observacao'] ?? '',
          status: d['status'] ?? 'Pendente',
        );
      }).toList();
    });
  }

  Future<void> salvar(Saida s) async {
    await _col.doc(s.id).set({
      'descricao': s.descricao,
      'fornecedor': s.fornecedor,
      'categoria': s.categoria.name,
      'tipoDespesa': s.tipoDespesa.name,
      'data': Timestamp.fromDate(s.data),
      'dataVencimento': s.dataVencimento != null
          ? Timestamp.fromDate(s.dataVencimento!)
          : null,
      'valor': s.valor,
      'observacao': s.observacao,
      'status': s.status,
    });
  }

  Future<void> atualizar(Saida s) async {
    await _col.doc(s.id).update({
      'descricao': s.descricao,
      'fornecedor': s.fornecedor,
      'categoria': s.categoria.name,
      'tipoDespesa': s.tipoDespesa.name,
      'data': Timestamp.fromDate(s.data),
      'dataVencimento': s.dataVencimento != null
          ? Timestamp.fromDate(s.dataVencimento!)
          : null,
      'valor': s.valor,
      'observacao': s.observacao,
      'status': s.status,
    });
  }

  Future<void> marcarComoPago(String id) async {
    await _col.doc(id).update({'status': 'Pago'});
  }

  Future<void> excluir(String id) async {
    await _col.doc(id).delete();
  }
}
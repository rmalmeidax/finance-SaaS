import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/conta_receber_model.dart';

class ContaReceberService {
  final collection =
  FirebaseFirestore.instance.collection('tab_contas_receber');

  Stream<List<ContaReceber>> listar() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return ContaReceber(
          id: doc.id,
          cliente: data['cliente'] ?? '',
          descricao: data['descricao'] ?? '',
          numeroDocumento: data['numeroDocumento'] ?? '',
          tipoDocumento: TipoDocumento.values.firstWhere(
                (e) => e.name == data['tipoDocumento'],
            orElse: () => TipoDocumento.boleto,
          ),
          dataEmissao: (data['dataEmissao'] as Timestamp).toDate(),
          dataVencimento: (data['dataVencimento'] as Timestamp).toDate(),
          valorBoleto: (data['valorBoleto'] as num).toDouble(),
          valorAtualizado: (data['valorBoleto'] as num).toDouble(), // 🔥 recalculado depois
          juros: (data['juros'] as num).toDouble(),
          multa: (data['multa'] as num).toDouble(),
          status: data['status'] ?? 'Pendente',
        );
      }).toList();
    });
  }

  Future<void> adicionar(ContaReceber conta) async {
    await collection.doc(conta.id).set({
      'cliente': conta.cliente,
      'descricao': conta.descricao,
      'numeroDocumento': conta.numeroDocumento,
      'tipoDocumento': conta.tipoDocumento.name,
      'dataEmissao': Timestamp.fromDate(conta.dataEmissao),
      'dataVencimento': Timestamp.fromDate(conta.dataVencimento),
      'valorBoleto': conta.valorBoleto,
      'juros': conta.juros,
      'multa': conta.multa,
      'status': conta.status,
    });
  }

  Future<void> marcarComoRecebido(String id) async {
    await collection.doc(id).update({
      'status': 'Recebido',
    });
  }

  Future<void> atualizar(ContaReceber conta) async {
    await collection.doc(conta.id).update({
      'valorAtualizado': conta.valorAtualizado,
    });
  }
}
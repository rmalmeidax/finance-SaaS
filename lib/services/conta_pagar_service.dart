import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/model/conta_pagar_model.dart';


class ContaPagarService {
  final collection =
  FirebaseFirestore.instance.collection('tab_contas_pagar');

  Stream<List<ContaPagar>> listar() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return ContaPagar(
          id: doc.id,
          fornecedor: data['fornecedor'] ?? '',
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

  Future<void> adicionar(ContaPagar conta) async {
    await collection.doc(conta.id).set({
      'fornecedor': conta.fornecedor,
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

  Future<void> marcarComoPago(String id) async {
    await collection.doc(id).update({
      'status': 'Recebido',
    });
  }

  Future<void> atualizar(ContaPagar conta) async {
    await collection.doc(conta.id).update({
      'valorAtualizado': conta.valorAtualizado,
    });
  }
}
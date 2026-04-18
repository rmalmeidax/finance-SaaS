import '../model/desconto_model.dart';

class DescontoService {
  Future<List<DescontoModel>> fetchDescontos() async {
    // Simulando delay de rede/banco de dados
    await Future.delayed(const Duration(seconds: 1));

    return [
      DescontoModel(
        id: '1',
        titulo: 'CHEQUE BRADESCO 4022',
        nomeCliente: 'Rafael Almeida',
        valorNominal: 2500.00,
        taxaDesconto: 0.035,
        validade: DateTime.now().add(const Duration(days: 5)),
        status: DescontoStatus.ativo,
        tipo: TipoTitulo.cheque,
      ),
      DescontoModel(
        id: '2',
        titulo: 'DUPLICATA MERCADORIA #88',
        nomeCliente: 'Antônio Heringer',
        valorNominal: 12450.00,
        taxaDesconto: 0.021,
        validade: DateTime.now().add(const Duration(days: 2)),
        status: DescontoStatus.expirando,
        tipo: TipoTitulo.duplicata,
      ),
    ];
  }
}
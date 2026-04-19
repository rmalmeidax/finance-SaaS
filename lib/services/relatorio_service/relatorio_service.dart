import '../../model/relatorio_madel/relatorio_request.dart';
import '../../model/relatorio_madel/relatorio_tipo.dart';


/// Camada de serviço responsável pela comunicação com a API/backend.
class RelatorioService {
  // Em produção: injete o Dio/http client aqui
  // final Dio _dio;
  // RelatorioService(this._dio);

  Future<RelatorioResult> emitirRelatorio(RelatorioRequest request) async {
    try {
      // Simula chamada à API — substitua pelo endpoint real:
      // final response = await _dio.post(
      //   '/api/relatorios/emitir',
      //   data: request.toMap(),
      // );
      // return RelatorioResult.sucesso(response.data['url']);

      await Future.delayed(const Duration(seconds: 2));

      _validarRequest(request);

      final nomeArquivo =
          '${request.tipo.label.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.${request.formato.label.toLowerCase()}';

      return RelatorioResult.sucesso('/storage/relatorios/$nomeArquivo');
    } on RelatorioException catch (e) {
      return RelatorioResult.erro(e.message);
    } catch (_) {
      return RelatorioResult.erro(
        'Erro inesperado ao gerar relatório. Tente novamente.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> buscarHistorico() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'tipo': 'Contas a Pagar / Receber',
        'formato': 'PDF',
        'geradoEm': DateTime.now().subtract(const Duration(hours: 2)),
        'arquivo': 'contas_123.pdf',
      },
      {
        'tipo': 'Clientes / Fornecedores',
        'formato': 'Excel',
        'geradoEm': DateTime.now().subtract(const Duration(days: 1)),
        'arquivo': 'clientes_456.xlsx',
      },
    ];
  }

  void _validarRequest(RelatorioRequest request) {
    if (request.filtroContas != null) {
      final f = request.filtroContas!;
      if (f.dataInicial != null &&
          f.dataFinal != null &&
          f.dataInicial!.isAfter(f.dataFinal!)) {
        throw RelatorioException(
          'A data inicial não pode ser maior que a data final.',
        );
      }
    }
    if (request.filtroClientes != null) {
      if (request.filtroClientes!.informacoesIncluidas.isEmpty) {
        throw RelatorioException(
          'Selecione ao menos uma informação para incluir no relatório.',
        );
      }
    }
    if (request.filtroInvestimentos != null) {
      if (request.filtroInvestimentos!.metricas.isEmpty) {
        throw RelatorioException(
          'Selecione ao menos uma métrica para o relatório.',
        );
      }
    }
  }
}

class RelatorioException implements Exception {
  final String message;
  RelatorioException(this.message);
}

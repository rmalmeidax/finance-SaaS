import 'relatorio_tipo.dart';
import 'filtro_contas.dart';
import 'filtro_clientes.dart';
import 'filtro_usuarios.dart';
import 'filtro_investimentos.dart';

class RelatorioRequest {
  final TipoRelatorio tipo;
  final FormatoExportacao formato;
  final FiltroContas? filtroContas;
  final FiltroClientes? filtroClientes;
  final FiltroUsuarios? filtroUsuarios;
  final FiltroInvestimentos? filtroInvestimentos;

  RelatorioRequest({
    required this.tipo,
    required this.formato,
    this.filtroContas,
    this.filtroClientes,
    this.filtroUsuarios,
    this.filtroInvestimentos,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo.label,
      'formato': formato.label,
      'filtros': _filtrosAtivos(),
    };
  }

  Map<String, dynamic> _filtrosAtivos() {
    if (filtroContas != null) return filtroContas!.toMap();
    if (filtroClientes != null) return filtroClientes!.toMap();
    if (filtroUsuarios != null) return filtroUsuarios!.toMap();
    if (filtroInvestimentos != null) return filtroInvestimentos!.toMap();
    return {};
  }
}

enum StatusRelatorio { idle, gerando, sucesso, erro }

class RelatorioResult {
  final StatusRelatorio status;
  final String? mensagem;
  final String? arquivoPath;
  final DateTime? geradoEm;

  const RelatorioResult({
    required this.status,
    this.mensagem,
    this.arquivoPath,
    this.geradoEm,
  });

  factory RelatorioResult.idle() =>
      const RelatorioResult(status: StatusRelatorio.idle);

  factory RelatorioResult.gerando() =>
      const RelatorioResult(status: StatusRelatorio.gerando);

  factory RelatorioResult.sucesso(String path) => RelatorioResult(
    status: StatusRelatorio.sucesso,
    mensagem: 'Relatório gerado com sucesso!',
    arquivoPath: path,
    geradoEm: DateTime.now(),
  );

  factory RelatorioResult.erro(String mensagem) => RelatorioResult(
    status: StatusRelatorio.erro,
    mensagem: mensagem,
  );
}

import 'package:flutter/material.dart';
import '../../model/relatorio_madel/filtro_clientes.dart';
import '../../model/relatorio_madel/filtro_contas.dart';
import '../../model/relatorio_madel/filtro_investimentos.dart';
import '../../model/relatorio_madel/filtro_usuarios.dart';
import '../../model/relatorio_madel/relatorio_request.dart';
import '../../model/relatorio_madel/relatorio_tipo.dart';
import '../../services/relatorio_service/relatorio_service.dart';


class RelatorioController extends ChangeNotifier {
  final RelatorioService _service;

  RelatorioController(this._service) {
    _carregarHistorico();
  }

  // ── Estado ──────────────────────────────────────────────────────
  TipoRelatorio? _tipoSelecionado;
  FormatoExportacao _formatoSelecionado = FormatoExportacao.pdf;
  RelatorioResult _resultado = RelatorioResult.idle();
  List<Map<String, dynamic>> _historico = [];

  // ── Filtros ─────────────────────────────────────────────────────
  FiltroContas _filtroContas = FiltroContas();
  FiltroClientes _filtroClientes = FiltroClientes();
  FiltroUsuarios _filtroUsuarios = FiltroUsuarios();
  FiltroInvestimentos _filtroInvestimentos = FiltroInvestimentos();

  // ── Getters ─────────────────────────────────────────────────────
  TipoRelatorio? get tipoSelecionado => _tipoSelecionado;
  FormatoExportacao get formatoSelecionado => _formatoSelecionado;
  RelatorioResult get resultado => _resultado;
  List<Map<String, dynamic>> get historico => _historico;
  FiltroContas get filtroContas => _filtroContas;
  FiltroClientes get filtroClientes => _filtroClientes;
  FiltroUsuarios get filtroUsuarios => _filtroUsuarios;
  FiltroInvestimentos get filtroInvestimentos => _filtroInvestimentos;

  bool get isGerando => _resultado.status == StatusRelatorio.gerando;
  bool get temRelatorioSelecionado => _tipoSelecionado != null;

  // ── Seleção ─────────────────────────────────────────────────────
  void selecionarTipo(TipoRelatorio tipo) {
    _tipoSelecionado = tipo;
    _resultado = RelatorioResult.idle();
    notifyListeners();
  }

  void selecionarFormato(FormatoExportacao formato) {
    _formatoSelecionado = formato;
    notifyListeners();
  }

  // ── Filtros: Contas ─────────────────────────────────────────────
  void setTipoLancamento(TipoLancamento v) {
    _filtroContas = _filtroContas.copyWith(tipoLancamento: v);
    notifyListeners();
  }

  void setStatusConta(StatusConta v) {
    _filtroContas = _filtroContas.copyWith(status: v);
    notifyListeners();
  }

  void setCategoriaConta(CategoriaConta v) {
    _filtroContas = _filtroContas.copyWith(categoria: v);
    notifyListeners();
  }

  void setDataInicialContas(DateTime? v) {
    _filtroContas = _filtroContas.copyWith(dataInicial: v);
    notifyListeners();
  }

  void setDataFinalContas(DateTime? v) {
    _filtroContas = _filtroContas.copyWith(dataFinal: v);
    notifyListeners();
  }

  void setAgrupamentoConta(AgrupamentoConta v) {
    _filtroContas = _filtroContas.copyWith(agrupamento: v);
    notifyListeners();
  }

  // ── Filtros: Clientes ───────────────────────────────────────────
  void setTipoEntidade(TipoEntidade v) {
    _filtroClientes.tipoEntidade = v;
    notifyListeners();
  }

  void setStatusCadastro(StatusCadastro v) {
    _filtroClientes.statusCadastro = v;
    notifyListeners();
  }

  void setTipoPessoa(TipoPessoa v) {
    _filtroClientes.tipoPessoa = v;
    notifyListeners();
  }

  void setDataInicialClientes(DateTime? v) {
    _filtroClientes.dataInicial = v;
    notifyListeners();
  }

  void setDataFinalClientes(DateTime? v) {
    _filtroClientes.dataFinal = v;
    notifyListeners();
  }

  void toggleInfoClientes(String info) {
    if (_filtroClientes.informacoesIncluidas.contains(info)) {
      _filtroClientes.informacoesIncluidas.remove(info);
    } else {
      _filtroClientes.informacoesIncluidas.add(info);
    }
    notifyListeners();
  }

  // ── Filtros: Usuários ───────────────────────────────────────────
  void setTipoUsuario(TipoUsuario v) {
    _filtroUsuarios.tipoUsuario = v;
    notifyListeners();
  }

  void setModuloSistema(ModuloSistema v) {
    _filtroUsuarios.moduloSistema = v;
    notifyListeners();
  }

  void setTipoAcao(TipoAcao v) {
    _filtroUsuarios.tipoAcao = v;
    notifyListeners();
  }

  void setDataInicialUsuarios(DateTime? v) {
    _filtroUsuarios.dataInicial = v;
    notifyListeners();
  }

  void setDataFinalUsuarios(DateTime? v) {
    _filtroUsuarios.dataFinal = v;
    notifyListeners();
  }

  // ── Filtros: Investimentos ──────────────────────────────────────
  void setTipoAnalise(TipoAnalise v) {
    _filtroInvestimentos.tipoAnalise = v;
    notifyListeners();
  }

  void setTipoInvestimento(TipoInvestimento v) {
    _filtroInvestimentos.tipoInvestimento = v;
    notifyListeners();
  }

  void setTipoDesconto(TipoDesconto v) {
    _filtroInvestimentos.tipoDesconto = v;
    notifyListeners();
  }

  void setDataInicialInvestimentos(DateTime? v) {
    _filtroInvestimentos.dataInicial = v;
    notifyListeners();
  }

  void setDataFinalInvestimentos(DateTime? v) {
    _filtroInvestimentos.dataFinal = v;
    notifyListeners();
  }

  void toggleMetrica(String metrica) {
    if (_filtroInvestimentos.metricas.contains(metrica)) {
      _filtroInvestimentos.metricas.remove(metrica);
    } else {
      _filtroInvestimentos.metricas.add(metrica);
    }
    notifyListeners();
  }

  // ── Ações principais ────────────────────────────────────────────
  Future<void> emitirRelatorio(BuildContext context) async {
    if (_tipoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um tipo de relatório antes de emitir.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _resultado = RelatorioResult.gerando();
    notifyListeners();

    final request = _buildRequest();
    final result = await _service.emitirRelatorio(request);

    _resultado = result;
    notifyListeners();

    if (result.status == StatusRelatorio.sucesso) {
      await _carregarHistorico();
    }
  }

  void limparFiltros() {
    switch (_tipoSelecionado) {
      case TipoRelatorio.contasPagarReceber:
        _filtroContas = FiltroContas();
        break;
      case TipoRelatorio.clientesFornecedores:
        _filtroClientes = FiltroClientes();
        break;
      case TipoRelatorio.usuarios:
        _filtroUsuarios = FiltroUsuarios();
        break;
      case TipoRelatorio.investimentosDescontos:
        _filtroInvestimentos = FiltroInvestimentos();
        break;
      case null:
        break;
    }
    _resultado = RelatorioResult.idle();
    notifyListeners();
  }

  Future<void> _carregarHistorico() async {
    _historico = await _service.buscarHistorico();
    notifyListeners();
  }

  RelatorioRequest _buildRequest() {
    return RelatorioRequest(
      tipo: _tipoSelecionado!,
      formato: _formatoSelecionado,
      filtroContas: _tipoSelecionado == TipoRelatorio.contasPagarReceber
          ? _filtroContas
          : null,
      filtroClientes: _tipoSelecionado == TipoRelatorio.clientesFornecedores
          ? _filtroClientes
          : null,
      filtroUsuarios: _tipoSelecionado == TipoRelatorio.usuarios
          ? _filtroUsuarios
          : null,
      filtroInvestimentos:
      _tipoSelecionado == TipoRelatorio.investimentosDescontos
          ? _filtroInvestimentos
          : null,
    );
  }
}

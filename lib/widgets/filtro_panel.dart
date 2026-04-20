import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/relatorio_controller/relatorio_controller.dart';
import '../model/relatorio_madel/relatorio_tipo.dart';
import '../util/app_theme.dart';
import 'filter_section.dart';
import 'filtro_clientes_panel.dart';
import 'filtro_contas_panel.dart';
import 'filtro_investimentos_panel.dart';
import 'filtro_usuarios_panel.dart';

class FiltroPanel extends StatelessWidget {
  const FiltroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RelatorioController>();
    final tipo = ctrl.tipoSelecionado;

    if (tipo == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1), width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros — ${tipo.label}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tipo.descricao,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // ── Filtros específicos ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(18),
            child: _buildFiltros(tipo),
          ),

          // ── Barra de ações ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: ctrl.isGerando
                      ? null
                      : () => ctrl.emitirRelatorio(context),
                  icon: ctrl.isGerando
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.file_download_outlined, size: 16),
                  label: Text(
                    ctrl.isGerando ? 'Gerando...' : 'Emitir relatório',
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: ctrl.limparFiltros,
                  child: const Text('Limpar filtros'),
                ),
                const Spacer(),
                SizedBox(
                  width: 100,
                  child: FilterDropdown<FormatoExportacao>(
                    items: FormatoExportacao.values,
                    value: ctrl.formatoSelecionado,
                    labelFor: (v) => v.label,
                    onChanged: (v) {
                      if (v != null) {
                        context.read<RelatorioController>().selecionarFormato(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(TipoRelatorio tipo) {
    switch (tipo) {
      case TipoRelatorio.contasPagarReceber:
        return const FiltroContasPanel();
      case TipoRelatorio.clientesFornecedores:
        return const FiltroClientesPanel();
      case TipoRelatorio.usuarios:
        return const FiltroUsuariosPanel();
      case TipoRelatorio.investimentosDescontos:
        return const FiltroInvestimentosPanel();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/relatorio_controller/relatorio_controller.dart';
import '../model/relatorio_madel/filtro_investimentos.dart';
import 'filter_section.dart';
import '../../widgets/toggle_pill_group.dart';

class FiltroInvestimentosPanel extends StatelessWidget {
  const FiltroInvestimentosPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RelatorioController>();
    final f = ctrl.filtroInvestimentos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSection(
          label: 'Tipo de Análise',
          child: TogglePillGroup<TipoAnalise>(
            options: TipoAnalise.values,
            selected: f.tipoAnalise,
            labelFor: (v) => v.label,
            onChanged: (v) => context.read<RelatorioController>().setTipoAnalise(v),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilterSection(
                label: 'Tipo de Investimento',
                child: FilterDropdown<TipoInvestimento>(
                  items: TipoInvestimento.values,
                  value: f.tipoInvestimento,
                  labelFor: (v) => v.label,
                  onChanged: (v) {
                    if (v != null) context.read<RelatorioController>().setTipoInvestimento(v);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilterSection(
                label: 'Tipo de Desconto',
                child: FilterDropdown<TipoDesconto>(
                  items: TipoDesconto.values,
                  value: f.tipoDesconto,
                  labelFor: (v) => v.label,
                  onChanged: (v) {
                    if (v != null) context.read<RelatorioController>().setTipoDesconto(v);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilterSection(
                label: 'Data Inicial',
                child: FilterDatePicker(
                  hint: 'Selecionar',
                  value: f.dataInicial,
                  onChanged: (v) => context.read<RelatorioController>().setDataInicialInvestimentos(v),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilterSection(
                label: 'Data Final',
                child: FilterDatePicker(
                  hint: 'Selecionar',
                  value: f.dataFinal,
                  onChanged: (v) => context.read<RelatorioController>().setDataFinalInvestimentos(v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilterSection(
          label: 'Métricas Exibidas',
          child: MultiTogglePillGroup(
            options: FiltroInvestimentos.opcoesMetricas,
            selected: f.metricas,
            onToggle: (v) => context.read<RelatorioController>().toggleMetrica(v),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/relatorio_controller/relatorio_controller.dart';
import '../model/relatorio_madel/filtro_contas.dart';
import 'filter_section.dart';
import '../../widgets/toggle_pill_group.dart';

class FiltroContasPanel extends StatelessWidget {
  const FiltroContasPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RelatorioController>();
    final f = ctrl.filtroContas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSection(
          label: 'Tipo de Lançamento',
          child: TogglePillGroup<TipoLancamento>(
            options: TipoLancamento.values,
            selected: f.tipoLancamento,
            labelFor: (v) => v.label,
            onChanged: (v) => context.read<RelatorioController>().setTipoLancamento(v),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilterSection(
                label: 'Status',
                child: FilterDropdown<StatusConta>(
                  items: StatusConta.values,
                  value: f.status,
                  labelFor: (v) => v.label,
                  onChanged: (v) {
                    if (v != null) context.read<RelatorioController>().setStatusConta(v);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilterSection(
                label: 'Categoria',
                child: FilterDropdown<CategoriaConta>(
                  items: CategoriaConta.values,
                  value: f.categoria,
                  labelFor: (v) => v.label,
                  onChanged: (v) {
                    if (v != null) context.read<RelatorioController>().setCategoriaConta(v);
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
                  onChanged: (v) => context.read<RelatorioController>().setDataInicialContas(v),
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
                  onChanged: (v) => context.read<RelatorioController>().setDataFinalContas(v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilterSection(
          label: 'Agrupamento',
          child: TogglePillGroup<AgrupamentoConta>(
            options: AgrupamentoConta.values,
            selected: f.agrupamento,
            labelFor: (v) => v.label,
            onChanged: (v) => context.read<RelatorioController>().setAgrupamentoConta(v),
          ),
        ),
      ],
    );
  }
}

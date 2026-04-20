import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/relatorio_controller/relatorio_controller.dart';
import '../model/relatorio_madel/filtro_clientes.dart';
import 'filter_section.dart';
import '../../widgets/toggle_pill_group.dart';

class FiltroClientesPanel extends StatelessWidget {
  const FiltroClientesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RelatorioController>();
    final f = ctrl.filtroClientes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSection(
          label: 'Tipo de Entidade',
          child: TogglePillGroup<TipoEntidade>(
            options: TipoEntidade.values,
            selected: f.tipoEntidade,
            labelFor: (v) => v.label,
            onChanged: (v) => context.read<RelatorioController>().setTipoEntidade(v),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilterSection(
                label: 'Status do Cadastro',
                child: FilterDropdown<StatusCadastro>(
                  items: StatusCadastro.values,
                  value: f.statusCadastro,
                  labelFor: (v) => v.label,
                  onChanged: (v) {
                    if (v != null) context.read<RelatorioController>().setStatusCadastro(v);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilterSection(
                label: 'Tipo de Pessoa',
                child: FilterDropdown<TipoPessoa>(
                  items: TipoPessoa.values,
                  value: f.tipoPessoa,
                  labelFor: (v) => v.label,
                  onChanged: (v) {
                    if (v != null) context.read<RelatorioController>().setTipoPessoa(v);
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
                  onChanged: (v) => context.read<RelatorioController>().setDataInicialClientes(v),
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
                  onChanged: (v) => context.read<RelatorioController>().setDataFinalClientes(v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilterSection(
          label: 'Informações Incluídas',
          child: MultiTogglePillGroup(
            options: FiltroClientes.opcoesInformacoes,
            selected: f.informacoesIncluidas,
            onToggle: (v) => context.read<RelatorioController>().toggleInfoClientes(v),
          ),
        ),
      ],
    );
  }
}

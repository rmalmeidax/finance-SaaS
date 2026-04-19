import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/relatorio_controller/relatorio_controller.dart';
import '../model/relatorio_madel/filtro_usuarios.dart';
import '../util/app_theme.dart';
import 'filter_section.dart';
import '../../widgets/toggle_pill_group.dart';

class FiltroUsuariosPanel extends StatelessWidget {
  const FiltroUsuariosPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RelatorioController>();
    final f = ctrl.filtroUsuarios;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FilterSection(
                label: 'Usuário',
                child: FilterDropdown<TipoUsuario>(
                  items: TipoUsuario.values,
                  value: f.tipoUsuario,
                  labelFor: (v) => v.label,
                  onChanged: (v) {
                    if (v != null) context.read<RelatorioController>().setTipoUsuario(v);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilterSection(
                label: 'Módulo do Sistema',
                child: FilterDropdown<ModuloSistema>(
                  items: ModuloSistema.values,
                  value: f.moduloSistema,
                  labelFor: (v) => v.label,
                  onChanged: (v) {
                    if (v != null) context.read<RelatorioController>().setModuloSistema(v);
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
                  onChanged: (v) => context.read<RelatorioController>().setDataInicialUsuarios(v),
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
                  onChanged: (v) => context.read<RelatorioController>().setDataFinalUsuarios(v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilterSection(
          label: 'Tipo de Ação',
          child: TogglePillGroup<TipoAcao>(
            options: TipoAcao.values,
            selected: f.tipoAcao,
            labelFor: (v) => v.label,
            onChanged: (v) => context.read<RelatorioController>().setTipoAcao(v),
            activeColor: AppColors.purpleMid,
            activeBg: AppColors.purpleLight,
            activeText: AppColors.purpleDark,
          ),
        ),
      ],
    );
  }
}

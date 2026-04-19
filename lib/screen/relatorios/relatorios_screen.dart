import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/relatorio_controller/relatorio_controller.dart';
import '../../model/relatorio_madel/relatorio_request.dart';
import '../../model/relatorio_madel/relatorio_tipo.dart';
import '../../widgets/filtro_panel.dart';
import '../../widgets/relatorio_card_button.dart';
import '../../widgets/resultado_banner.dart';

abstract class _T {
  static const teal = Color(0xFF00BFA5);
  static const mono = 'monospace';
}



class RelatoriosScreen extends StatelessWidget {
  const RelatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Icon(Icons.chevron_left,
                    size: 24, color: textColor?.withValues(alpha: 0.55)),
              ),
            ),
            Container(
              width: 2, height: 18,
              decoration: BoxDecoration(
                  color: _T.teal, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Text(
              'CENTRAL DE RELATÓRIOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 1.8,
                fontFamily: _T.mono,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.history_rounded, size: 22, color: textColor?.withValues(alpha: 0.7)),
              onPressed: () => _showHistorico(context),
              tooltip: 'Histórico',
            ),
            const SizedBox(width: 8),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: theme.dividerColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecione o tipo de relatório e configure os filtros',
              style: TextStyle(fontSize: 11, color: textColor?.withValues(alpha: 0.5), fontFamily: _T.mono),
            ),
            const SizedBox(height: 20),
            const _RelatorioGrid(),
            const SizedBox(height: 20),
            const ResultadoBanner(),
            const _ResultadoSpacer(),
            const FiltroPanel(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showHistorico(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<RelatorioController>(),
        child: const _HistoricoSheet(),
      ),
    );
  }
}

class _RelatorioGrid extends StatelessWidget {
  const _RelatorioGrid();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RelatorioController>();

    return GridView.count(
      crossAxisCount: _crossAxisCount(context),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: _cardRatio(context),
      children: TipoRelatorio.values
          .map(
            (tipo) => RelatorioCardButton(
          tipo: tipo,
          isSelected: ctrl.tipoSelecionado == tipo,
          onTap: () => context.read<RelatorioController>().selecionarTipo(tipo),
        ),
      )
          .toList(),
    );
  }

  int _crossAxisCount(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 400) return 1;
    if (w < 700) return 2;
    return 4;
  }

  double _cardRatio(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 400) return 3.5;
    return 1.1;
  }
}

class _ResultadoSpacer extends StatelessWidget {
  const _ResultadoSpacer();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<RelatorioController>().resultado.status;
    final isVisible =
        status != StatusRelatorio.idle && status != StatusRelatorio.gerando;
    return SizedBox(height: isVisible ? 16 : 0);
  }
}

class _HistoricoSheet extends StatelessWidget {
  const _HistoricoSheet();

  @override
  Widget build(BuildContext context) {
    final historico = context.watch<RelatorioController>().historico;
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Histórico de relatórios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          if (historico.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Nenhum relatório gerado ainda.',
                  style: TextStyle(fontSize: 13, color: textColor?.withValues(alpha: 0.5)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: historico.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: theme.dividerColor),
              itemBuilder: (_, i) {
                final item = historico[i];
                final dt = item['geradoEm'] as DateTime;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: theme.primaryColor,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    item['tipo'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    '${item['formato']}  •  '
                        '${dt.day.toString().padLeft(2, '0')}/'
                        '${dt.month.toString().padLeft(2, '0')}/'
                        '${dt.year}  '
                        '${dt.hour.toString().padLeft(2, '0')}:'
                        '${dt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor?.withValues(alpha: 0.5),
                    ),
                  ),
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: textColor?.withValues(alpha: 0.3),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/relatorio_controller/relatorio_controller.dart';
import '../../model/relatorio_madel/relatorio_request.dart';
import '../../model/relatorio_madel/relatorio_tipo.dart';
import '../../widgets/filtro_panel.dart';
import '../../widgets/relatorio_card_button.dart';
import '../../widgets/resultado_banner.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
abstract class _T {
  static const teal    = Color(0xFF00BFA5);
  static const tealDim = Color(0xFF00897B);
  static const mono    = 'monospace';
}

// ─────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────
class RelatoriosScreen extends StatelessWidget {
  const RelatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // ── AppBar compacta e elegante ──────────────────────────
      appBar: _buildAppBar(context, theme, textColor),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtítulo pequeno
            _SectionLabel(
              icon: Icons.tune_rounded,
              text: 'Tipo de Relatório',
            ),
            const SizedBox(height: 10),

            // Grid de cards — 2 colunas no mobile
            const _RelatorioGrid(),
            const SizedBox(height: 20),

            // Banner de resultado (aparece quando há resultado)
            const ResultadoBanner(),
            const _ResultadoSpacer(),

            // Painel de filtros
            _SectionLabel(
              icon: Icons.filter_alt_outlined,
              text: 'Filtros & Configurações',
            ),
            const SizedBox(height: 10),
            const FiltroPanel(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ThemeData theme, Color? textColor) {
    return AppBar(
      backgroundColor: theme.cardColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 56,
      title: Row(
        children: [
          // ── Botão voltar ──────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: textColor?.withValues(alpha: 0.55),
              ),
            ),
          ),
          // ── Barra teal + título ───────────────────────────
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: _T.teal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // Título com Flexible para não estourar
          Flexible(
            child: Text(
              'RELATÓRIOS',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 2.5,
                fontFamily: _T.mono,
              ),
            ),
          ),
          const Spacer(),
          // ── Botão histórico com badge visual ─────────────
          _HistoricoButton(textColor: textColor),
          const SizedBox(width: 8),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: theme.dividerColor),
      ),
    );
  }

  void _showHistorico(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,        // permite crescer conforme conteúdo
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<RelatorioController>(),
        child: const _HistoricoSheet(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BOTÃO HISTÓRICO (com contador de itens)
// ─────────────────────────────────────────────────────────────
class _HistoricoButton extends StatelessWidget {
  final Color? textColor;
  const _HistoricoButton({required this.textColor});

  @override
  Widget build(BuildContext context) {
    final ctrl     = context.watch<RelatorioController>();
    final count    = ctrl.historico.length;
    final theme    = Theme.of(context);
    final primary  = theme.primaryColor;
    final border   = theme.dividerColor;

    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded,
                size: 16, color: textColor?.withValues(alpha: 0.7)),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: _T.teal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontFamily: _T.mono,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<RelatorioController>(),
        child: const _HistoricoSheet(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SECTION LABEL — ícone + texto
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Row(
      children: [
        Icon(icon, size: 13, color: _T.teal),
        const SizedBox(width: 6),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: textColor?.withValues(alpha: 0.45),
            fontFamily: _T.mono,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GRID DE TIPOS — 2 colunas mobile / 4 wide
// ─────────────────────────────────────────────────────────────
class _RelatorioGrid extends StatelessWidget {
  const _RelatorioGrid();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RelatorioController>();

    return GridView.count(
      crossAxisCount: _crossAxisCount(context),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: _cardRatio(context),
      children: TipoRelatorio.values
          .map((tipo) => RelatorioCardButton(
        tipo: tipo,
        isSelected: ctrl.tipoSelecionado == tipo,
        onTap: () =>
            context.read<RelatorioController>().selecionarTipo(tipo),
      ))
          .toList(),
    );
  }

  int _crossAxisCount(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    if (w < 400) return 2;
    if (w < 700) return 2;
    return 4;
  }

  double _cardRatio(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    // Mobile: cards um pouco mais altos que largos
    if (w < 400) return 1.3;
    if (w < 700) return 1.4;
    return 1.1;
  }
}

// ─────────────────────────────────────────────────────────────
//  SPACER dinâmico após banner de resultado
// ─────────────────────────────────────────────────────────────
class _ResultadoSpacer extends StatelessWidget {
  const _ResultadoSpacer();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<RelatorioController>().resultado.status;
    final isVisible =
        status != StatusRelatorio.idle && status != StatusRelatorio.gerando;
    return SizedBox(height: isVisible ? 20 : 0);
  }
}

// ─────────────────────────────────────────────────────────────
//  BOTTOM SHEET — HISTÓRICO
// ─────────────────────────────────────────────────────────────
class _HistoricoSheet extends StatelessWidget {
  const _HistoricoSheet();

  @override
  Widget build(BuildContext context) {
    final historico = context.watch<RelatorioController>().historico;
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final primary   = theme.primaryColor;
    final border    = theme.dividerColor;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Column(
        children: [
          // ── Handle e cabeçalho fixo ───────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Título do sheet
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _T.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _T.teal.withValues(alpha: 0.25)),
                      ),
                      child: const Icon(Icons.history_rounded,
                          size: 18, color: _T.teal),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HISTÓRICO',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            fontFamily: _T.mono,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '${historico.length} relatório(s) gerado(s)',
                          style: TextStyle(
                            fontSize: 10,
                            color: textColor?.withValues(alpha: 0.45),
                            fontFamily: _T.mono,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: border),
              ],
            ),
          ),

          // ── Lista scrollável ──────────────────────────────
          Expanded(
            child: historico.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.inbox_outlined,
                        size: 26,
                        color: textColor?.withValues(alpha: 0.25),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum relatório ainda',
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor?.withValues(alpha: 0.4),
                        fontFamily: _T.mono,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : ListView.separated(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: historico.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: border.withValues(alpha: 0.5)),
              itemBuilder: (_, i) =>
                  _HistoricoTile(item: historico[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TILE DE ITEM DO HISTÓRICO
// ─────────────────────────────────────────────────────────────
class _HistoricoTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _HistoricoTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final primary   = theme.primaryColor;
    final dt        = item['geradoEm'] as DateTime;

    final dateStr = '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Ícone
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
              Border.all(color: primary.withValues(alpha: 0.15)),
            ),
            child: Icon(Icons.description_outlined,
                color: primary, size: 18),
          ),
          const SizedBox(width: 12),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['tipo'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _Tag(text: item['formato'] as String),
                    const SizedBox(width: 6),
                    Text(
                      '$dateStr · $timeStr',
                      style: TextStyle(
                        fontSize: 10,
                        color: textColor?.withValues(alpha: 0.45),
                        fontFamily: _T.mono,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Ação
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.open_in_new_rounded,
                size: 14,
                color: textColor?.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAG — chip pequeno de formato
// ─────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerColor;
    final tc     = Theme.of(context).textTheme.bodyMedium?.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _T.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _T.teal.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: _T.teal,
          fontFamily: _T.mono,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
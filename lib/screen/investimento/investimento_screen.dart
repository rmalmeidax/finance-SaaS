// lib/screens/investimentos_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/investimento_controller.dart';
import '../../model/investimento_model.dart';
import '../../widgets/theme_toggle_button.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
class _C {
  static const green  = Color(0xFF4CAF50);
  static const green2 = Color(0xFF00C853);
  static const red    = Color(0xFFE53935);
  static const blue   = Color(0xFF2196F3);
  static const yellow = Color(0xFFFFA726);
  static const purple = Color(0xFF8B6FD4);
  static const teal   = Color(0xFF00BFA5); // barra vertical do header
  static const mono   = 'monospace';
}

// ─────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────
class InvestimentosScreen extends StatefulWidget {
  const InvestimentosScreen({super.key});

  @override
  State<InvestimentosScreen> createState() => _InvestimentosScreenState();
}

class _InvestimentosScreenState extends State<InvestimentosScreen>
    with TickerProviderStateMixin {
  late final AnimationController _tickerCtrl;

  @override
  void initState() {
    super.initState();
    _tickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _tickerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<InvestmentController>(
          builder: (_, ctrl, __) => Column(
            children: [
              _Header(ctrl: ctrl),
              _TickerBar(ctrl: ctrl, animation: _tickerCtrl),
              Expanded(
                child: ctrl.loading
                    ? Center(child: CircularProgressIndicator(color: color))
                    : _Body(ctrl: ctrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HEADER — modelo: < | TÍTULO
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final InvestmentController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final textColor       = Theme.of(context).textTheme.bodyMedium?.color;
    final secondaryText   = textColor?.withOpacity(0.6);
    final borderColor     = Theme.of(context).dividerColor;
    final cardColor       = Theme.of(context).cardColor;
    final secondaryBg     = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // ── Botão voltar + barra teal + título ──────────────
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(
                Icons.chevron_left,
                size: 22,
                color: secondaryText,
              ),
            ),
          ),
          // Barra vertical teal
          Container(
            width: 2,
            height: 18,
            decoration: BoxDecoration(
              color: _C.teal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          // Título uppercase
          Text(
            'INVESTIMENTOS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 1.2,
              fontFamily: _C.mono,
            ),
          ),
          const Spacer(),
          // Live badge
          _PulseBadge(),
          const SizedBox(width: 8),
          // Relógio
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: secondaryBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              ctrl.fmtClock(),
              style: TextStyle(
                color: secondaryText,
                fontSize: 10,
                fontFamily: _C.mono,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const ThemeToggleButton(),
        ],
      ),
    );
  }
}

class _PulseBadge extends StatefulWidget {
  @override
  State<_PulseBadge> createState() => _PulseBadgeState();
}

class _PulseBadgeState extends State<_PulseBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);
  late final Animation<double> _a =
  Tween<double>(begin: 1, end: .4).animate(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _C.red.withOpacity(.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.red.withOpacity(.3)),
      ),
      child: const Text(
        '● AO VIVO',
        style: TextStyle(
          color: _C.red,
          fontSize: 10,
          fontFamily: _C.mono,
          fontWeight: FontWeight.w600,
          letterSpacing: .6,
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  TICKER BAR
// ─────────────────────────────────────────────────────────────
class _TickerBar extends StatelessWidget {
  final InvestmentController ctrl;
  final Animation<double> animation;
  const _TickerBar({required this.ctrl, required this.animation});

  @override
  Widget build(BuildContext context) {
    final borderColor     = Theme.of(context).dividerColor;
    final cardColor       = Theme.of(context).cardColor;
    final textColor       = Theme.of(context).textTheme.bodyMedium?.color;
    final secondaryText   = textColor?.withOpacity(0.6);
    final primary         = Theme.of(context).primaryColor;

    final items = ctrl.ticker;
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 34,
      color: cardColor,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) {
          return LayoutBuilder(builder: (_, box) {
            const itemW = 140.0;
            final totalW = itemW * items.length;
            final offset = -(animation.value * totalW * 2) % totalW;

            return ClipRect(
              child: Stack(
                children: [
                  Positioned(
                    left: offset,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        ...items.map((t) => _TickItem(
                          item: t,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryText,
                          primary: primary,
                        )),
                        ...items.map((t) => _TickItem(
                          item: t,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryText,
                          primary: primary,
                        )),
                        ...items.map((t) => _TickItem(
                          item: t,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryText,
                          primary: primary,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

class _TickItem extends StatelessWidget {
  final TickerItem item;
  final Color borderColor;
  final Color? textColor;
  final Color? secondaryTextColor;
  final Color primary;

  const _TickItem({
    required this.item,
    required this.borderColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.symbol,
              style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 11,
                  fontFamily: _C.mono,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(_fmtVal(item.value),
              style:
              TextStyle(color: textColor, fontSize: 11, fontFamily: _C.mono)),
          const SizedBox(width: 5),
          Text(
            '${item.isPositive ? '+' : ''}${item.changePercent.toStringAsFixed(2)}%',
            style: TextStyle(
                color: item.isPositive ? primary : _C.red,
                fontSize: 10,
                fontFamily: _C.mono),
          ),
        ],
      ),
    );
  }

  String _fmtVal(double v) {
    if (v >= 1000) return v.toStringAsFixed(0);
    if (v >= 10) return v.toStringAsFixed(2);
    return v.toStringAsFixed(2);
  }
}

// ─────────────────────────────────────────────────────────────
//  BODY
// ─────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final InvestmentController ctrl;
  const _Body({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        _MetricsRow(ctrl: ctrl),
        const SizedBox(height: 14),
        _MainGrid(ctrl: ctrl),
        const SizedBox(height: 14),
        _FormCard(ctrl: ctrl),
        const SizedBox(height: 14),
        _TableCard(ctrl: ctrl),
        const SizedBox(height: 14),
        _FooterStats(ctrl: ctrl),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  METRICS ROW
// ─────────────────────────────────────────────────────────────
class _MetricsRow extends StatelessWidget {
  final InvestmentController ctrl;
  const _MetricsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final daily       = ctrl.dailyChange;
    final primary     = Theme.of(context).primaryColor;
    final cardColor   = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor;
    final textColor   = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;

          if (isNarrow) {
            return Column(
              children: [
                _MetricTile(
                  label: 'PATRIMÔNIO',
                  value: ctrl.fmtCurrency(ctrl.totalCurrent),
                  sub: '${ctrl.fmtPercent(ctrl.returnPercent)} total',
                  valueColor: _C.green2,
                  subColor: primary,
                  showBorder: false,
                  isFullWidth: true,
                ),
                Divider(height: 1, color: borderColor),
                Row(
                  children: [
                    Expanded(
                        child: _MetricTile(
                          label: 'RENDIMENTO',
                          value: ctrl.fmtCurrency(ctrl.totalReturn),
                          sub: ctrl.totalReturn >= 0 ? '▲ lucro' : '▼ perda',
                          valueColor: _C.blue,
                          subColor: ctrl.totalReturn >= 0 ? primary : _C.red,
                          showBorder: true,
                        )),
                    Expanded(
                        child: _MetricTile(
                          label: 'HOJE',
                          value: ctrl.fmtCurrency(daily),
                          sub: daily >= 0 ? '▲ hoje' : '▼ hoje',
                          valueColor: daily >= 0 ? _C.green2 : _C.red,
                          subColor: daily >= 0 ? primary : _C.red,
                          showBorder: false,
                        )),
                  ],
                ),
                Divider(height: 1, color: borderColor),
                _MetricTile(
                  label: 'ATIVOS',
                  value: '${ctrl.investments.length}',
                  sub: 'na carteira',
                  valueColor: textColor ?? Colors.white,
                  subColor: textColor?.withOpacity(0.6) ?? Colors.white70,
                  showBorder: false,
                  isFullWidth: true,
                ),
              ],
            );
          }

          return Row(
            children: [
              _MetricTile(
                label: 'PATRIMÔNIO',
                value: ctrl.fmtCurrency(ctrl.totalCurrent),
                sub: '${ctrl.fmtPercent(ctrl.returnPercent)} total',
                valueColor: _C.green2,
                subColor: primary,
                showBorder: true,
              ),
              _MetricTile(
                label: 'RENDIMENTO',
                value: ctrl.fmtCurrency(ctrl.totalReturn),
                sub: ctrl.totalReturn >= 0 ? '▲ lucro' : '▼ perda',
                valueColor: _C.blue,
                subColor: ctrl.totalReturn >= 0 ? primary : _C.red,
                showBorder: true,
              ),
              _MetricTile(
                label: 'HOJE',
                value: ctrl.fmtCurrency(daily),
                sub: daily >= 0 ? '▲ hoje' : '▼ hoje',
                valueColor: daily >= 0 ? _C.green2 : _C.red,
                subColor: daily >= 0 ? primary : _C.red,
                showBorder: true,
              ),
              _MetricTile(
                label: 'ATIVOS',
                value: '${ctrl.investments.length}',
                sub: 'na carteira',
                valueColor: textColor ?? Colors.white,
                subColor: textColor?.withOpacity(0.6) ?? Colors.white70,
                showBorder: false,
              ),
            ].map((t) => Expanded(child: t)).toList(),
          );
        },
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label, value, sub;
  final Color valueColor, subColor;
  final bool showBorder;
  final bool isFullWidth;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
    required this.subColor,
    required this.showBorder,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final textColor   = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: showBorder
          ? BoxDecoration(border: Border(right: BorderSide(color: borderColor)))
          : null,
      child: Column(
        crossAxisAlignment:
        isFullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: textColor?.withOpacity(0.4),
                  fontSize: 8,
                  fontFamily: _C.mono,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment:
            isFullWidth ? Alignment.center : Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    color: valueColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.6)),
          ),
          const SizedBox(height: 4),
          Text(sub,
              style: TextStyle(
                  color: subColor, fontSize: 10, fontFamily: _C.mono)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  MAIN GRID
// ─────────────────────────────────────────────────────────────
class _MainGrid extends StatelessWidget {
  final InvestmentController ctrl;
  const _MainGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    if (isWide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _ChartCard(ctrl: ctrl)),
            const SizedBox(width: 14),
            SizedBox(width: 280, child: _SidePanel(ctrl: ctrl)),
          ],
        ),
      );
    }
    return Column(
      children: [
        _ChartCard(ctrl: ctrl),
        const SizedBox(height: 14),
        _SidePanel(ctrl: ctrl),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  CHART CARD
// ─────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final InvestmentController ctrl;
  const _ChartCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final textColor   = Theme.of(context).textTheme.bodyMedium?.color;
    final borderColor = Theme.of(context).dividerColor;
    final primary     = Theme.of(context).primaryColor;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Text('Performance da Carteira',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                for (final r in ['1D', '1S', '1M', '3M', '1A'])
                  _RangeTab(
                    label: r,
                    active: ctrl.chartRange == r,
                    onTap: () => ctrl.setChartRange(r),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          SizedBox(
            height: 190,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: CustomPaint(
                painter: _ChartPainter(
                  data: ctrl.chartData,
                  labels: ctrl.chartLabels,
                  primaryColor: primary,
                  gridColor: textColor?.withOpacity(0.05) ??
                      Colors.white.withOpacity(0.05),
                  labelColor: textColor?.withOpacity(0.4) ??
                      const Color(0x997B8699),
                  chartRange: ctrl.chartRange,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _RangeTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary   = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          color: active ? primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? primary : textColor?.withOpacity(0.4),
                fontSize: 10,
                fontFamily: _C.mono,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color primaryColor;
  final Color gridColor;
  final Color labelColor;
  final String chartRange;

  const _ChartPainter({
    required this.data,
    required this.labels,
    required this.primaryColor,
    required this.gridColor,
    required this.labelColor,
    required this.chartRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const pl = 50.0, pr = 10.0, pt = 8.0, pb = 28.0;
    final cW = size.width - pl - pr;
    final cH = size.height - pt - pb;

    final mn = data.reduce(math.min) * .997;
    final mx = data.reduce(math.max) * 1.003;
    final rng = mx - mn;

    double tx(int i) => pl + i / (data.length - 1) * cW;
    double ty(double v) => pt + (1 - (v - mn) / rng) * cH;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int g = 0; g <= 5; g++) {
      final y = pt + g * (cH / 5);
      canvas.drawLine(Offset(pl, y), Offset(size.width - pr, y), gridPaint);
      final val = mx - g / 5 * rng;
      final tp = TextPainter(
        text: TextSpan(
          text: 'R\$${(val / 1000).toStringAsFixed(0)}k',
          style: TextStyle(color: labelColor, fontSize: 8, fontFamily: 'monospace'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - 5));
    }

    final path = Path();
    path.moveTo(tx(0), ty(data[0]));
    for (int i = 1; i < data.length; i++) {
      path.lineTo(tx(i), ty(data[i]));
    }

    final fillPath = Path.from(path)
      ..lineTo(tx(data.length - 1), pt + cH)
      ..lineTo(tx(0), pt + cH)
      ..close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [primaryColor.withOpacity(.22), primaryColor.withOpacity(0)],
    );
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader =
        gradient.createShader(Rect.fromLTWH(0, pt, size.width, cH)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = primaryColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    final step = math.max(1, (data.length / 7).ceil());
    for (int i = 0; i < labels.length; i++) {
      if (i % step != 0) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: labelColor, fontSize: 8, fontFamily: 'monospace'),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(tx(i) - tp.width / 2, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.data != data || old.chartRange != chartRange;
}

// ─────────────────────────────────────────────────────────────
//  SIDE PANEL — overflow do sparkline IBOVESPA corrigido
// ─────────────────────────────────────────────────────────────
class _SidePanel extends StatelessWidget {
  final InvestmentController ctrl;
  const _SidePanel({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final ibov        = ctrl.ibovespa;
    final textColor   = Theme.of(context).textTheme.bodyMedium?.color;
    final primary     = Theme.of(context).primaryColor;
    final borderColor = Theme.of(context).dividerColor;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IBOVESPA header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('IBOVESPA',
                          style: TextStyle(
                              color: textColor?.withOpacity(0.4),
                              fontSize: 9,
                              fontFamily: _C.mono,
                              letterSpacing: 1.6)),
                      const SizedBox(height: 4),
                      Text(
                        ibov.value
                            .toStringAsFixed(0)
                            .replaceAllMapped(
                            RegExp(r'(\d)(?=(\d{3})+$)'),
                                (m) => '${m[1]}.'),
                        style: TextStyle(
                            color: primary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Pill(
                      text:
                      '${ibov.isPositive ? '+' : ''}${ibov.changePercent.toStringAsFixed(2)}%',
                      positive: ibov.isPositive,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ibov.isPositive ? '+' : ''}${(ibov.value * ibov.changePercent / 100).toStringAsFixed(0)} pts',
                      style: TextStyle(
                          color: textColor?.withOpacity(0.4),
                          fontSize: 9,
                          fontFamily: _C.mono),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Sparkline IBOVESPA — ClipRect impede overflow ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: ClipRect(                          // ← correção do overflow
                child: CustomPaint(
                  painter: _SparkPainter(
                    data: ibov.sparkData,
                    color: primary,
                    filled: true,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          Divider(height: 1, color: borderColor),

          // Índices
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: ctrl.sideIndices
                  .map((idx) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _IndexRow(index: idx),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexRow extends StatelessWidget {
  final MarketIndex index;
  const _IndexRow({required this.index});

  @override
  Widget build(BuildContext context) {
    final fmtVal  = index.value >= 1000
        ? index.value.toStringAsFixed(0)
        : index.value.toStringAsFixed(2);
    final primary   = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    // Layout fixo sem Spacer:
    // [label 52] [spark Expanded] [valor 52] [pill 58]
    // Total com padding interno (28px) ≤ 280px do SidePanel
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            index.label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                color: textColor?.withOpacity(0.6),
                fontSize: 11,
                fontFamily: _C.mono),
          ),
        ),
        const SizedBox(width: 4),
        // Sparkline ocupa o espaço restante
        Expanded(
          child: SizedBox(
            height: 28,
            child: ClipRect(
              child: CustomPaint(
                painter: _SparkPainter(
                  data: index.sparkData,
                  color: index.isPositive ? primary : _C.red,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 50,
          child: Text(
            fmtVal,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                color: index.isPositive ? primary : _C.red,
                fontSize: 11,
                fontFamily: _C.mono,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 6),
        // Pill com largura fixa para não estourar
        SizedBox(
          width: 56,
          child: _Pill(
            text:
            '${index.isPositive ? '+' : ''}${index.changePercent.toStringAsFixed(2)}%',
            positive: index.isPositive,
            small: true,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SPARK PAINTER
// ─────────────────────────────────────────────────────────────
class _SparkPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool filled;
  const _SparkPainter(
      {required this.data, required this.color, this.filled = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final mn  = data.reduce(math.min);
    final mx  = data.reduce(math.max);
    final rng = mx - mn;
    if (rng == 0) return;

    double tx(int i)    => i / (data.length - 1) * size.width;
    double ty(double v) => size.height - (v - mn) / rng * (size.height - 4) - 2;

    final path = Path();
    path.moveTo(tx(0), ty(data[0]));
    for (int i = 1; i < data.length; i++) {
      path.lineTo(tx(i), ty(data[i]));
    }

    if (filled) {
      final fill = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      // Gradiente restrito ao bounds do widget — não vaza mais
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(.25), color.withOpacity(0)],
      );
      canvas.drawPath(
        fill,
        Paint()
          ..shader = gradient
              .createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = filled ? 2 : 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.data != data;
}

// ─────────────────────────────────────────────────────────────
//  FORM CARD
// ─────────────────────────────────────────────────────────────
class _FormCard extends StatefulWidget {
  final InvestmentController ctrl;
  const _FormCard({required this.ctrl});

  @override
  State<_FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<_FormCard> {
  final _name   = TextEditingController();
  final _invest = TextEditingController();
  final _atual  = TextEditingController();
  final _qty    = TextEditingController();
  DateTime _date = DateTime.now();
  InvestmentType _type = InvestmentType.acoes;
  String? _msg;

  static const _typeOptions = [
    (InvestmentType.acoes,     'Ações Nacionais'),
    (InvestmentType.acoes,     'Ações EUA (BDR)'),
    (InvestmentType.fii,       'FII – Fundos Imobiliários'),
    (InvestmentType.rendaFixa, 'Tesouro Direto'),
    (InvestmentType.rendaFixa, 'CDB / LCI / LCA'),
    (InvestmentType.rendaFixa, 'Debêntures'),
    (InvestmentType.cripto,    'Criptomoedas'),
    (InvestmentType.etf,       'ETF Nacional'),
    (InvestmentType.etf,       'ETF Internacional'),
  ];

  @override
  void dispose() {
    _name.dispose();
    _invest.dispose();
    _atual.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary     = Theme.of(context).primaryColor;
    final textColor   = Theme.of(context).textTheme.bodyMedium?.color;
    final bgColor     = Theme.of(context).scaffoldBackgroundColor;
    final borderColor = Theme.of(context).dividerColor;

    return _Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('+ ', style: TextStyle(color: primary, fontSize: 15)),
              Text('Novo Lançamento',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 14),

            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final fields = [
                Expanded(
                  flex: isNarrow ? 0 : 3,
                  child: _Field(
                      label: 'NOME / ATIVO',
                      child: _Input(
                          ctrl: _name, hint: 'Ex: PETR4, Bitcoin...')),
                ),
                if (!isNarrow) const SizedBox(width: 10),
                Expanded(
                  flex: isNarrow ? 0 : 2,
                  child: _Field(
                    label: 'TIPO',
                    child: _DropField(
                      value: _type,
                      options: _typeOptions,
                      onChanged: (t) => setState(() => _type = t),
                    ),
                  ),
                ),
                if (!isNarrow) const SizedBox(width: 10),
                Expanded(
                  flex: isNarrow ? 0 : 2,
                  child: _Field(
                      label: 'VALOR INVESTIDO (R\$)',
                      child: _Input(
                          ctrl: _invest, hint: '0,00', isNum: true)),
                ),
              ];

              if (isNarrow) {
                return Column(children: [
                  fields[0],
                  const SizedBox(height: 10),
                  fields[2],
                  const SizedBox(height: 10),
                  fields[4],
                ]);
              }
              return Row(children: fields);
            }),

            const SizedBox(height: 10),

            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final fields = [
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _Field(
                      label: 'VALOR ATUAL (R\$)',
                      child: _Input(
                          ctrl: _atual, hint: '0,00', isNum: true)),
                ),
                if (!isNarrow) const SizedBox(width: 10),
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _Field(
                      label: 'QTD. COTAS / AÇÕES',
                      child:
                      _Input(ctrl: _qty, hint: '0', isNum: true)),
                ),
                if (!isNarrow) const SizedBox(width: 10),
                Expanded(
                  flex: isNarrow ? 0 : 1,
                  child: _Field(
                    label: 'DATA DE ENTRADA',
                    child: GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _date = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 10),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontFamily: _C.mono),
                              ),
                            ),
                            Icon(Icons.calendar_today_outlined,
                                color: textColor?.withOpacity(0.4),
                                size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];

              if (isNarrow) {
                return Column(children: [
                  fields[0],
                  const SizedBox(height: 10),
                  fields[2],
                  const SizedBox(height: 10),
                  fields[4],
                ]);
              }
              return Row(children: fields);
            }),

            const SizedBox(height: 14),
            Row(
              children: [
                if (_msg != null)
                  Text(_msg!,
                      style: TextStyle(
                          color: primary,
                          fontSize: 11,
                          fontFamily: _C.mono)),
                const Spacer(),
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [primary, primary.withOpacity(0.8)]),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Adicionar à Carteira',
                      style: TextStyle(
                          color: primary.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final name = _name.text.trim();
    final inv  = double.tryParse(_invest.text.replaceAll(',', '.')) ?? 0;
    if (name.isEmpty || inv <= 0) {
      setState(() => _msg = 'Preencha nome e valor investido.');
      return;
    }
    final atual = double.tryParse(_atual.text.replaceAll(',', '.')) ?? inv;
    final qty   = double.tryParse(_qty.text.replaceAll(',', '.')) ?? 0;

    widget.ctrl.addInvestment(InvestmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: _type,
      investedValue: inv,
      currentValue: atual,
      quantity: qty,
      entryDate: _date,
    ));

    _name.clear();
    _invest.clear();
    _atual.clear();
    _qty.clear();
    setState(() {
      _msg = '✓ Adicionado com sucesso!';
      _date = DateTime.now();
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _msg = null);
    });
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textColor?.withOpacity(0.4),
                fontSize: 8,
                fontFamily: _C.mono,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isNum;
  const _Input(
      {required this.ctrl, required this.hint, this.isNum = false});

  @override
  Widget build(BuildContext context) {
    final textColor   = Theme.of(context).textTheme.bodyMedium?.color;
    final primary     = Theme.of(context).primaryColor;
    final borderColor = Theme.of(context).dividerColor;
    final bgColor     = Theme.of(context).scaffoldBackgroundColor;

    return TextField(
      controller: ctrl,
      keyboardType:
      isNum ? TextInputType.number : TextInputType.text,
      style: TextStyle(
          color: textColor, fontSize: 12, fontFamily: _C.mono),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: textColor?.withOpacity(0.4), fontSize: 12),
        filled: true,
        fillColor: bgColor,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: primary, width: 1.2)),
      ),
    );
  }
}

class _DropField extends StatelessWidget {
  final InvestmentType value;
  final List<(InvestmentType, String)> options;
  final ValueChanged<InvestmentType> onChanged;
  const _DropField(
      {required this.value,
        required this.options,
        required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textColor   = Theme.of(context).textTheme.bodyMedium?.color;
    final primary     = Theme.of(context).primaryColor;
    final borderColor = Theme.of(context).dividerColor;
    final bgColor     = Theme.of(context).scaffoldBackgroundColor;
    final cardColor   = Theme.of(context).cardColor;

    return DropdownButtonFormField<String>(
      value: options.firstWhere((o) => o.$1 == value).$2,
      dropdownColor: cardColor,
      style: TextStyle(
          color: textColor, fontSize: 12, fontFamily: _C.mono),
      decoration: InputDecoration(
        filled: true,
        fillColor: bgColor,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: primary, width: 1.2)),
      ),
      icon: Icon(Icons.keyboard_arrow_down,
          color: textColor?.withOpacity(0.4), size: 16),
      items: options
          .map((o) => DropdownMenuItem(
        value: o.$2,
        child: Text(o.$2, overflow: TextOverflow.ellipsis),
      ))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        final match = options.firstWhere((o) => o.$2 == v);
        onChanged(match.$1);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TABLE CARD
// ─────────────────────────────────────────────────────────────
class _TableCard extends StatelessWidget {
  final InvestmentController ctrl;
  const _TableCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final invs        = ctrl.investments;
    final total       = ctrl.totalCurrent;
    final textColor   = Theme.of(context).textTheme.bodyMedium?.color;
    final borderColor = Theme.of(context).dividerColor;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Text('Carteira de Investimentos',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${invs.length} ativos',
                    style: TextStyle(
                        color: textColor?.withOpacity(0.4),
                        fontSize: 10,
                        fontFamily: _C.mono)),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          LayoutBuilder(builder: (context, constraints) {
            final tableWidth = math.max(constraints.maxWidth, 800.0);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: borderColor))),
                      child: const Row(
                        children: [
                          Expanded(flex: 3, child: _TH('ATIVO')),
                          Expanded(flex: 2, child: _TH('TIPO')),
                          Expanded(flex: 3, child: _TH('INVESTIDO')),
                          Expanded(flex: 3, child: _TH('ATUAL')),
                          Expanded(flex: 3, child: _TH('RETORNO')),
                          Expanded(flex: 2, child: _TH('%')),
                          Expanded(flex: 3, child: _TH('PESO')),
                        ],
                      ),
                    ),
                    if (invs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Center(
                          child: Text('Nenhum ativo na carteira.',
                              style: TextStyle(
                                  color: textColor?.withOpacity(0.4),
                                  fontFamily: _C.mono,
                                  fontSize: 11)),
                        ),
                      )
                    else
                      ...invs.map((inv) => _TableRow(
                        inv: inv,
                        total: total,
                        onDelete: () =>
                            ctrl.removeInvestment(inv.id),
                        fmtC: ctrl.fmtCurrency,
                      )),
                  ],
                ),
              ),
            );
          }),   // fim LayoutBuilder
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Text(text,
        style: TextStyle(
            color: textColor?.withOpacity(0.4),
            fontSize: 8,
            fontFamily: _C.mono,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600));
  }
}

class _TableRow extends StatelessWidget {
  final InvestmentModel inv;
  final double total;
  final VoidCallback onDelete;
  final String Function(double) fmtC;

  const _TableRow({
    required this.inv,
    required this.total,
    required this.onDelete,
    required this.fmtC,
  });

  static const _chipColors = {
    InvestmentType.acoes:     (_C.blue,              'Ações'),
    InvestmentType.fii:       (_C.yellow,             'FII'),
    InvestmentType.cripto:    (Color(0xFFFF6B8A),     'Cripto'),
    InvestmentType.rendaFixa: (_C.green,              'Renda Fixa'),
    InvestmentType.etf:       (_C.purple,             'ETF'),
  };

  @override
  Widget build(BuildContext context) {
    final ret       = inv.totalReturn;
    final pct       = inv.returnPercent;
    final peso      = total > 0 ? inv.currentValue / total * 100 : 0.0;
    final isUp      = ret >= 0;
    final primary   = Theme.of(context).primaryColor;
    final retColor  = isUp ? primary : _C.red;
    final chip      = _chipColors[inv.type]!;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final borderColor = Theme.of(context).dividerColor;

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: borderColor.withOpacity(0.1)))),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(inv.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text(
                    '${inv.quantity % 1 == 0 ? inv.quantity.toInt() : inv.quantity.toStringAsFixed(2)} cotas',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: textColor?.withOpacity(0.4),
                        fontSize: 10,
                        fontFamily: _C.mono),
                  ),
                ],
              )),
          Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: chip.$1.withOpacity(.12),
                    borderRadius: BorderRadius.circular(4),
                    border:
                    Border.all(color: chip.$1.withOpacity(.3)),
                  ),
                  child: Text(chip.$2,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: chip.$1,
                          fontSize: 9,
                          fontFamily: _C.mono,
                          fontWeight: FontWeight.w700)),
                ),
              )),
          Expanded(
              flex: 3,
              child: Text(fmtC(inv.investedValue),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontFamily: _C.mono,
                      fontWeight: FontWeight.w600))),
          Expanded(
              flex: 3,
              child: Text(fmtC(inv.currentValue),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontFamily: _C.mono,
                      fontWeight: FontWeight.w600))),
          Expanded(
              flex: 3,
              child: Text(
                '${isUp ? '+' : ''}${fmtC(ret)}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    color: retColor,
                    fontSize: 11,
                    fontFamily: _C.mono),
              )),
          Expanded(
              flex: 2,
              child: Text(
                '${isUp ? '+' : ''}${pct.toStringAsFixed(2)}%',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    color: retColor,
                    fontSize: 11,
                    fontFamily: _C.mono),
              )),
          Expanded(
              flex: 3,
              child: Row(children: [
                Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: peso / 100,
                        backgroundColor:
                        borderColor.withOpacity(0.2),
                        valueColor:
                        AlwaysStoppedAnimation(retColor),
                        minHeight: 4,
                      ),
                    )),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.close,
                      color: textColor?.withOpacity(0.4),
                      size: 14),
                ),
              ])),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FOOTER STATS
// ─────────────────────────────────────────────────────────────
class _FooterStats extends StatelessWidget {
  final InvestmentController ctrl;
  const _FooterStats({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final best        = ctrl.bestPerformer;
    final big         = ctrl.biggestPosition;
    final avg         = ctrl.avgReturn;
    final primary     = Theme.of(context).primaryColor;
    final cardColor   = Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          final stats = [
            _FStat(
              label: 'MELHOR ATIVO',
              value: best != null
                  ? '${best.name} (${best.returnPercent.toStringAsFixed(2)}%)'
                  : '—',
              color: primary,
              showBorder: true,
            ),
            _FStat(
              label: 'MAIOR POSIÇÃO',
              value: big != null
                  ? '${big.name} — ${ctrl.fmtCurrency(big.currentValue)}'
                  : '—',
              color: Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.white,
              showBorder: true,
            ),
            _FStat(
              label: 'RENTABILIDADE MÉDIA',
              value: ctrl.fmtPercent(avg),
              color: avg >= 0 ? primary : _C.red,
              showBorder: false,
            ),
          ];

          if (isNarrow) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: stats
                    .map((s) => SizedBox(width: 160, child: s))
                    .toList(),
              ),
            );
          }

          return Row(
            children: stats.map((s) => Expanded(child: s)).toList(),
          );
        },
      ),
    );
  }
}

class _FStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final bool showBorder;
  const _FStat(
      {required this.label,
        required this.value,
        required this.color,
        required this.showBorder});

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final textColor   = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: showBorder
          ? BoxDecoration(
          border: Border(right: BorderSide(color: borderColor)))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: textColor?.withOpacity(0.4),
                  fontSize: 8,
                  fontFamily: _C.mono,
                  letterSpacing: 1.6)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.4)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: child,
  );
}

class _Pill extends StatelessWidget {
  final String text;
  final bool positive;
  final bool small;
  const _Pill(
      {required this.text, required this.positive, this.small = false});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final color   = positive ? primary : _C.red;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 5 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: color,
              fontSize: small ? 9 : 10,
              fontFamily: _C.mono,
              fontWeight: FontWeight.w700)),
    );
  }
}
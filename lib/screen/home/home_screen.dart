import 'dart:math' as math;

import 'package:finance/enums/perfil_usuario_enum.dart';
import 'package:finance/screen/cliente/cliente_screen.dart';
import 'package:finance/screen/contas_receber/contas_receber_screen.dart';
import 'package:finance/screen/entrada/entrada_screen.dart';
import 'package:finance/screen/fornecedor/fornecedor_screen.dart';
import 'package:finance/screen/saida/saida_screen.dart';
import 'package:finance/screen/usuario/usuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/theme_toggle_button.dart';

import '../contas_pagar/contas_pagar_screen.dart';
import '../desconto/desconto_screen.dart';
import '../investimento/investimento_screen.dart';
import '../relatorios/relatorios_screen.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
abstract class _DC {
  static const teal    = Color(0xFF00BFA5);
  static const green   = Color(0xFF00C853);
  static const red     = Color(0xFFE53935);
  static const blue    = Color(0xFF2196F3);
  static const amber   = Color(0xFFFFA726);
  static const mono    = 'monospace';
}

// ─────────────────────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme       = Theme.of(context);
    final isDark      = theme.brightness == Brightness.dark;
    final authService = context.watch<AuthService>();

    // Proteção contra dados nulos enquanto carrega ou se houver erro
    if (authService.userData == null && !authService.loading) {
       // Se não tem dados e não está carregando, pode ser que o stream ainda não emitiu
       // ou o documento no firestore não existe.
       return const Scaffold(
         body: Center(child: CircularProgressIndicator(color: _DC.teal)),
       );
    }

    final isAdmin     = authService.isAdmin;
    final isGerente   = authService.isGerente;
    final perfil      = authService.perfil;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: Row(
          children: [
            Container(
              width: 3,
              height: 22,
              decoration: const BoxDecoration(
                color: _DC.teal,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'DASHBOARD',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout, size: 20, color: _DC.red),
            onPressed: () => context.read<AuthService>().logout(),
            tooltip: 'Sair',
          ),
        ],
      ),

      body: authService.loading 
        ? const Center(child: CircularProgressIndicator(color: _DC.teal))
        : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + nome ─────────────────────────────────
            _UserHeader(authService: authService, perfil: perfil),
            const SizedBox(height: 20),

            // ── Grid de módulos ───────────────────────────────
            LayoutBuilder(builder: (context, constraints) {
              final double w             = constraints.maxWidth;
              final int    crossAxisCount = w > 600 ? 5 : 3;
              final double spacing        = 8.0;
              final double itemWidth =
                  (w - spacing * (crossAxisCount - 1)) / crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  if (isGerente)
                    _buildMenuCard(context, 'Contas Receber',
                        Icons.attach_money, _DC.blue,
                        const ContasReceberScreen(), width: itemWidth),
                  if (isGerente)
                    _buildMenuCard(context, 'Contas à Pagar',
                        Icons.money_off, _DC.red,
                        const ContasPagarScreen(), width: itemWidth),
                  if (perfil != PerfilUsuarioEnum.BASICO)
                    _buildMenuCard(context, 'Entradas',
                        Icons.trending_up, _DC.green,
                        const EntradaScreen(), width: itemWidth),
                  if (perfil != PerfilUsuarioEnum.BASICO)
                    _buildMenuCard(context, 'Saídas',
                        Icons.trending_down, _DC.amber,
                        const SaidaScreen(), width: itemWidth),
                  if (isAdmin)
                    _buildMenuCard(context, 'Investimentos',
                        Icons.show_chart, Colors.purple,
                        const InvestimentosScreen(), width: itemWidth),
                  if (isAdmin)
                    _buildMenuCard(context, 'Descontos',
                        Icons.percent, Colors.redAccent,
                        const DescontoScreen(), width: itemWidth),
                  if (isAdmin)
                    _buildMenuCard(context, 'Usuários',
                        Icons.people_alt, Colors.indigo,
                        const UsuarioScreen(), width: itemWidth),
                  _buildMenuCard(context, 'Fornecedor',
                      Icons.business, Colors.brown,
                      const FornecedorScreen(), width: itemWidth),
                  _buildMenuCard(context, 'Clientes',
                      Icons.person, _DC.teal,
                      const ClienteScreen(), width: itemWidth),
                  _buildMenuCard(context, 'Relatório',
                      Icons.newspaper, _DC.teal,
                      const RelatoriosScreen(), width: itemWidth),
                ],
              );
            }),

            const SizedBox(height: 28),

            // ══════════════════════════════════════════════════
            //  DASHBOARD PREMIUM
            // ══════════════════════════════════════════════════
            const _DashboardSection(),
          ],
        ),
      ),
    );
  }

  // ── Card de menu (inalterado) ─────────────────────────────
  Widget _buildMenuCard(BuildContext context, String title,
      IconData icon, Color color, Widget? screen,
      {required double width}) {
    return SizedBox(
      width: width,
      height: 90,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (screen != null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => screen));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Módulo em desenvolvimento')),
            );
          }
        },
        child: Card(
          elevation: 0,
          color: color.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 8),
                Text(title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  USER HEADER
// ─────────────────────────────────────────────────────────────
class _UserHeader extends StatelessWidget {
  final AuthService authService;
  final PerfilUsuarioEnum perfil;
  const _UserHeader({required this.authService, required this.perfil});

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final now       = DateTime.now();
    final greeting  = now.hour < 12
        ? 'Bom dia'
        : now.hour < 18
        ? 'Boa tarde'
        : 'Boa noite';

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _DC.teal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _DC.teal.withValues(alpha: 0.25)),
          ),
          child: const Icon(Icons.person_outline_rounded,
              color: _DC.teal, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting 👋',
                style: TextStyle(
                  fontSize: 11,
                  color: textColor?.withValues(alpha: 0.45),
                  fontFamily: _DC.mono,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                authService.userData?['email'] ?? 'Usuário',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        // Badge de perfil
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _DC.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _DC.teal.withValues(alpha: 0.25)),
          ),
          child: Text(
            perfil.label.toUpperCase(),
            style: const TextStyle(
              color: _DC.teal,
              fontSize: 9,
              fontFamily: _DC.mono,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DASHBOARD SECTION — tudo abaixo dos botões
// ─────────────────────────────────────────────────────────────
class _DashboardSection extends StatelessWidget {
  const _DashboardSection();

  // Dados mockados — substituir por controller real
  static const double _saldo    = 10000.0;
  static const double _receita  = 5000.0;
  static const double _despesa  = 2000.0;
  static const double _liquido  = _receita - _despesa;
  static const double _saude    = (_liquido / _receita) * 100; // 60%

  static final List<double> _spark = [
    8200, 8750, 9100, 8900, 9400, 9700, 9300, 9800, 10200, 10000
  ];

  static final List<_ActivityItem> _activities = [
    _ActivityItem(
      icon: Icons.flash_on_rounded,
      iconColor: _DC.amber,
      title: 'Conta de Luz',
      subtitle: 'Venc: 10/04',
      value: 'R\$ 200,00',
      isNegative: true,
      tag: 'PENDENTE',
      tagColor: _DC.amber,
    ),
    _ActivityItem(
      icon: Icons.payments_rounded,
      iconColor: _DC.green,
      title: 'Salário',
      subtitle: '05/04',
      value: 'R\$ 3.000,00',
      isNegative: false,
      tag: 'RECEBIDO',
      tagColor: _DC.green,
    ),
    _ActivityItem(
      icon: Icons.store_rounded,
      iconColor: _DC.blue,
      title: 'Fornecedor TechParts',
      subtitle: 'Venc: 15/04',
      value: 'R\$ 780,00',
      isNegative: true,
      tag: 'A PAGAR',
      tagColor: _DC.red,
    ),
    _ActivityItem(
      icon: Icons.trending_up_rounded,
      iconColor: Colors.purple,
      title: 'Rendimento FII',
      subtitle: '01/04',
      value: 'R\$ 312,00',
      isNegative: false,
      tag: 'INVESTIMENTO',
      tagColor: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label de seção ─────────────────────────────────
        _SectionHeader(
          label: 'Visão Financeira',
          icon: Icons.insights_rounded,
        ),
        const SizedBox(height: 12),

        // ── Cards de métricas (2 colunas) ──────────────────
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'SALDO ATUAL',
                value: 'R\$ ${_fmt(_saldo)}',
                valueColor: _DC.green,
                icon: Icons.account_balance_wallet_outlined,
                iconColor: _DC.green,
                sparkData: _spark,
                trend: '+8,2%',
                trendUp: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'RESULTADO',
                value: 'R\$ ${_fmt(_liquido)}',
                valueColor: _liquido >= 0 ? _DC.blue : _DC.red,
                icon: Icons.swap_vert_circle_outlined,
                iconColor: _DC.blue,
                sparkData: null,
                infoRows: [
                  _InfoRow(
                      label: 'Receitas',
                      value: 'R\$ ${_fmt(_receita)}',
                      color: _DC.green),
                  _InfoRow(
                      label: 'Despesas',
                      value: 'R\$ ${_fmt(_despesa)}',
                      color: _DC.red),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Card de saúde financeira (largura total) ───────
        _HealthCard(saude: _saude),

        const SizedBox(height: 24),

        // ── Atividades recentes ────────────────────────────
        _SectionHeader(
          label: 'Atividades Recentes',
          icon: Icons.receipt_long_rounded,
          action: 'Ver todas',
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: _activities
                .asMap()
                .entries
                .map((e) => _ActivityTile(
              item: e.value,
              isLast: e.key == _activities.length - 1,
            ))
                .toList(),
          ),
        ),

        const SizedBox(height: 20),

        // ── Alertas rápidos ────────────────────────────────
        _SectionHeader(
          label: 'Alertas',
          icon: Icons.notifications_none_rounded,
        ),
        const SizedBox(height: 12),
        const _AlertsCard(),
      ],
    );
  }

  static String _fmt(double v) =>
      v.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
      );
}

// ─────────────────────────────────────────────────────────────
//  SECTION HEADER
// ─────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? action;
  const _SectionHeader(
      {required this.label, required this.icon, this.action});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final primary   = Theme.of(context).primaryColor;

    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _DC.teal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 14, color: _DC.teal),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 1.8,
            fontFamily: _DC.mono,
          ),
        ),
        if (action != null) ...[
          const Spacer(),
          Text(
            action!,
            style: TextStyle(
              fontSize: 10,
              color: primary.withValues(alpha: 0.7),
              fontFamily: _DC.mono,
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  METRIC CARD
// ─────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String label, value;
  final Color valueColor, iconColor;
  final IconData icon;
  final List<double>? sparkData;
  final String? trend;
  final bool? trendUp;
  final List<_InfoRow>? infoRows;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
    required this.sparkData,
    this.trend,
    this.trendUp,
    this.infoRows,
  });

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final border    = theme.dividerColor;
    final cardColor = theme.cardColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone + label
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: _DC.mono,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                    color: textColor?.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Valor principal
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: _DC.mono,
                color: valueColor,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Trend badge
          if (trend != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (trendUp! ? _DC.green : _DC.red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${trendUp! ? '▲' : '▼'} $trend este mês',
                style: TextStyle(
                  fontSize: 9,
                  color: trendUp! ? _DC.green : _DC.red,
                  fontFamily: _DC.mono,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          // Sparkline
          if (sparkData != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ClipRect(
                child: CustomPaint(
                  painter: _SparkPainter(
                    data: sparkData!,
                    color: valueColor,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ],

          // Info rows
          if (infoRows != null) ...[
            const SizedBox(height: 10),
            ...infoRows!.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: textColor?.withValues(alpha: 0.5),
                        fontFamily: _DC.mono,
                      )),
                  Text(r.value,
                      style: TextStyle(
                        fontSize: 10,
                        color: r.color,
                        fontFamily: _DC.mono,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label, value;
  final Color color;
  const _InfoRow(
      {required this.label, required this.value, required this.color});
}

// ─────────────────────────────────────────────────────────────
//  HEALTH CARD — saúde financeira com barra animada
// ─────────────────────────────────────────────────────────────
class _HealthCard extends StatelessWidget {
  final double saude; // 0–100
  const _HealthCard({required this.saude});

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final border    = theme.dividerColor;

    final Color barColor;
    final String label;
    final IconData statusIcon;
    if (saude >= 70) {
      barColor   = _DC.green;
      label      = 'Excelente';
      statusIcon = Icons.sentiment_very_satisfied_rounded;
    } else if (saude >= 40) {
      barColor   = _DC.amber;
      label      = 'Moderado';
      statusIcon = Icons.sentiment_neutral_rounded;
    } else {
      barColor   = _DC.red;
      label      = 'Atenção';
      statusIcon = Icons.sentiment_dissatisfied_rounded;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, size: 17, color: barColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAÚDE FINANCEIRA',
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: _DC.mono,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                        color: textColor?.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Percentual grande
              Text(
                '${saude.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: _DC.mono,
                  fontWeight: FontWeight.w800,
                  color: barColor,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Barra de progresso segmentada
          _SegmentedBar(value: saude / 100, color: barColor),

          const SizedBox(height: 8),

          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BarLegend(label: 'Crítico', color: _DC.red),
              _BarLegend(label: 'Moderado', color: _DC.amber),
              _BarLegend(label: 'Saudável', color: _DC.green),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentedBar extends StatelessWidget {
  final double value; // 0–1
  final Color color;
  const _SegmentedBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    const int segments = 20;
    final int filled   = (value * segments).round();
    final border       = Theme.of(context).dividerColor;

    return Row(
      children: List.generate(segments, (i) {
        final isFilled = i < filled;
        // Determina cor do segmento por posição
        final Color segColor = i < 7
            ? _DC.red
            : i < 13
            ? _DC.amber
            : _DC.green;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            height: 6,
            decoration: BoxDecoration(
              color: isFilled
                  ? segColor.withValues(alpha: 0.85)
                  : border.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _BarLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _BarLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
              fontSize: 9,
              color: textColor?.withValues(alpha: 0.45),
              fontFamily: _DC.mono,
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ACTIVITY TILE
// ─────────────────────────────────────────────────────────────
class _ActivityItem {
  final IconData icon;
  final Color iconColor;
  final String title, subtitle, value, tag;
  final Color tagColor;
  final bool isNegative;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isNegative,
    required this.tag,
    required this.tagColor,
  });
}

class _ActivityTile extends StatelessWidget {
  final _ActivityItem item;
  final bool isLast;
  const _ActivityTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final border    = theme.dividerColor;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                      color: item.iconColor.withValues(alpha: 0.2)),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 18),
              ),
              const SizedBox(width: 12),

              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        )),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color:
                            item.tagColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: item.tagColor
                                    .withValues(alpha: 0.25)),
                          ),
                          child: Text(item.tag,
                              style: TextStyle(
                                fontSize: 8,
                                color: item.tagColor,
                                fontFamily: _DC.mono,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              )),
                        ),
                        const SizedBox(width: 6),
                        Text(item.subtitle,
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor?.withValues(alpha: 0.4),
                              fontFamily: _DC.mono,
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              // Valor
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.isNegative ? '−' : '+'} ${item.value}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: _DC.mono,
                      color: item.isNegative ? _DC.red : _DC.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              indent: 64,
              endIndent: 14,
              color: border.withValues(alpha: 0.5)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ALERTS CARD
// ─────────────────────────────────────────────────────────────
class _AlertsCard extends StatelessWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final border    = theme.dividerColor;

    const alerts = [
      _Alert(
        icon: Icons.warning_amber_rounded,
        color: _DC.amber,
        title: '2 contas vencem em 5 dias',
        subtitle: 'Conta de Luz · Fatura Cartão',
      ),
      _Alert(
        icon: Icons.trending_up_rounded,
        color: _DC.green,
        title: 'Meta de receita atingida',
        subtitle: '102% do planejado em abril',
      ),
      _Alert(
        icon: Icons.info_outline_rounded,
        color: _DC.blue,
        title: 'Relatório mensal disponível',
        subtitle: 'Gere o fechamento de março',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: alerts
            .asMap()
            .entries
            .map((e) => _AlertTile(
          alert: e.value,
          isLast: e.key == alerts.length - 1,
        ))
            .toList(),
      ),
    );
  }
}

class _Alert {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _Alert(
      {required this.icon,
        required this.color,
        required this.title,
        required this.subtitle});
}

class _AlertTile extends StatelessWidget {
  final _Alert alert;
  final bool isLast;
  const _AlertTile({required this.alert, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final border    = theme.dividerColor;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: alert.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(alert.icon, size: 16, color: alert.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        )),
                    const SizedBox(height: 2),
                    Text(alert.subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: textColor?.withValues(alpha: 0.45),
                          fontFamily: _DC.mono,
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 16, color: textColor?.withValues(alpha: 0.25)),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              indent: 60,
              endIndent: 14,
              color: border.withValues(alpha: 0.5)),
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
  const _SparkPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final mn  = data.reduce(math.min);
    final mx  = data.reduce(math.max);
    final rng = mx - mn;
    if (rng == 0) return;

    double tx(int i)    => i / (data.length - 1) * size.width;
    double ty(double v) =>
        size.height - (v - mn) / rng * (size.height - 4) - 2;

    final path = Path()..moveTo(tx(0), ty(data[0]));
    for (int i = 1; i < data.length; i++) {
      path.lineTo(tx(i), ty(data[i]));
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: .2),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.data != data;
}
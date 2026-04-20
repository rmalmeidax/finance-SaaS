import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/saida_controller.dart';
import '../../model/saida_model.dart';
import '../../widgets/custom_input_widget.dart';
import '../../widgets/dashboard_resumo_card_widget.dart';

// ══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ══════════════════════════════════════════════════════════════
abstract class _T {
  static const teal   = Color(0xFF00BFA5);
  static const green  = Color(0xFF43A047);
  static const orange = Color(0xFFEF6C00);
  static const blue   = Color(0xFF1565C0);
  static const red    = Color(0xFFC62828);
  static const mono   = 'monospace';

  static String fmtMoeda(double v) {
    final n = v.toStringAsFixed(2)
        .replaceAll('.', ',')
        .replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?=,))'),
          (m) => '${m[1]}.',
    );
    return 'R\$ $n';
  }

  static String fmtData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class SaidaScreen extends StatelessWidget {
  const SaidaScreen({super.key});

  double parseValor(String texto) =>
      double.tryParse(texto.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SaidaController>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: theme.primaryColor, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 3,
              height: 22,
              decoration: const BoxDecoration(
                color: _T.teal,
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "SAÍDAS",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range_outlined,
                color: theme.primaryColor, size: 20),
            tooltip: "Filtrar por período",
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: controller.periodoCustom,
                builder: (ctx, child) => Theme(
                  data: theme.copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: theme.primaryColor,
                      brightness: theme.brightness,
                      primary: theme.primaryColor,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (range != null) controller.setPeriodoCustom(range);
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
              onPressed: () => _showDialog(context, controller),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── SEARCH ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Buscar por descrição ou fornecedor...",
                  hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3), fontSize: 14),
                  prefixIcon: Icon(Icons.search,
                      color: theme.primaryColor, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: controller.setBusca,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── DASHBOARD ──
          _dashboard(context, controller),

          const SizedBox(height: 16),

          // ── FILTRO PERÍODO ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _periodoChip(context, "Hoje", FiltroPeriodoSaida.hoje, controller),
                const SizedBox(width: 8),
                _periodoChip(context, "Semana", FiltroPeriodoSaida.semana, controller),
                const SizedBox(width: 8),
                _periodoChip(context, "Mês", FiltroPeriodoSaida.mes, controller),
                const SizedBox(width: 8),
                _periodoChip(context, "Trimestre", FiltroPeriodoSaida.trimestre, controller),
                const SizedBox(width: 8),
                _periodoChip(context, "Todos", FiltroPeriodoSaida.todos, controller),
                if (controller.periodoCustom != null) ...[
                  const SizedBox(width: 8),
                  _customPeriodoChip(context, controller),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── FILTRO STATUS ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _statusChip(context, "Todos", FiltroStatusSaida.todos,
                    Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Colors.grey, controller),
                const SizedBox(width: 8),
                _statusChip(context, "Pago", FiltroStatusSaida.pago,
                    const Color(0xFF66BB6A), controller),
                const SizedBox(width: 8),
                _statusChip(context, "Pendente", FiltroStatusSaida.pendente,
                    const Color(0xFFFFB74D), controller),
                const SizedBox(width: 8),
                _statusChip(context, "Vencido", FiltroStatusSaida.vencido,
                    const Color(0xFFEF5350), controller),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── FILTRO TIPO + CATEGORIA ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Tipo
                _tipoChip(context, "Todas", null, controller),
                const SizedBox(width: 8),
                _tipoChip(context, "🔒 Fixas", TipoDespesa.fixa, controller),
                const SizedBox(width: 8),
                _tipoChip(context, "🔄 Variáveis", TipoDespesa.variavel, controller),
                const SizedBox(width: 16),
                Container(width: 1, height: 20, color: Theme.of(context).dividerColor),
                const SizedBox(width: 16),
                // Categorias
                _categoriaChip(context, null, "📋 Cat.", controller),
                ...CategoriaSaida.values.map((cat) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _categoriaChip(context, cat, cat.icon, controller),
                )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── LISTA ──
          Expanded(
            child: controller.saidas.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_down_outlined,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.12), size: 60),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhuma saída encontrada",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                        fontSize: 14,
                        letterSpacing: 1),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: controller.saidas.length,
              itemBuilder: (_, i) =>
                  _saidaCard(context, controller.saidas[i], controller),
            ),
          ),
        ],
      ),
    );
  }

  // ── DASHBOARD ──
  Widget _dashboard(BuildContext context, SaidaController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        final cards = [
          Expanded(
            flex: isMobile ? 1 : 2,
            child: DashboardResumoCardWidget(
              title: "TOTAL SAÍDAS",
              value: _T.fmtMoeda(controller.totalSaidas),
              color: _T.teal,
              icon: Icons.trending_down_outlined,
              isWide: !isMobile,
            ),
          ),
          Expanded(
            child: DashboardResumoCardWidget(
              title: "PAGO",
              value: _T.fmtMoeda(controller.totalPago),
              color: _T.green,
              icon: Icons.check_circle_outline,
            ),
          ),
          Expanded(
            child: DashboardResumoCardWidget(
              title: "PENDENTE",
              value: _T.fmtMoeda(controller.totalPendente),
              color: _T.orange,
              icon: Icons.schedule_outlined,
            ),
          ),
          Expanded(
            child: DashboardResumoCardWidget(
              title: "VARIÁVEIS",
              value: _T.fmtMoeda(controller.totalVariaveis),
              color: _T.blue,
              icon: Icons.sync_outlined,
            ),
          ),
          Expanded(
            child: DashboardResumoCardWidget(
              title: "FIXAS",
              value: _T.fmtMoeda(controller.totalFixas),
              color: const Color(0xFFB39DDB),
              icon: Icons.lock_outline,
            ),
          ),
          Expanded(
            child: DashboardResumoCardWidget(
              title: "REGISTROS",
              value: "${controller.saidas.length}",
              color: const Color(0xFF90A4AE),
              icon: Icons.receipt_long_outlined,
            ),
          ),
        ];

        if (isMobile) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(children: [cards[0]]),
                const SizedBox(height: 10),
                Row(children: [cards[1], const SizedBox(width: 10), cards[2]]),
                const SizedBox(height: 10),
                Row(children: [cards[3], const SizedBox(width: 10), cards[4]]),
                const SizedBox(height: 10),
                Row(children: [cards[5]]),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  cards[0],
                  const SizedBox(width: 10),
                  cards[1],
                  const SizedBox(width: 10),
                  cards[2],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  cards[3],
                  const SizedBox(width: 10),
                  cards[4],
                  const SizedBox(width: 10),
                  cards[5],
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  // ── CARD ──
  Widget _saidaCard(
      BuildContext context, Saida s, SaidaController controller) {
    final cor = _corCategoria(s.categoria);
    final statusColor = _corStatus(s.status);
    final isPago = s.status == 'Pago';
    final isVencido = s.status == 'Vencido';
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                  bottom: BorderSide(color: statusColor.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                // Ícone categoria
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(s.categoria.icon,
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.descricao.toUpperCase(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (s.fornecedor.isNotEmpty)
                        Text(s.fornecedor,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                fontSize: 11)),
                    ],
                  ),
                ),
                // Badge tipo
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: (s.tipoDespesa == TipoDespesa.fixa
                        ? const Color(0xFFB39DDB)
                        : _T.blue)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    s.tipoDespesa == TipoDespesa.fixa ? '🔒 FIXA' : '🔄 VAR.',
                    style: TextStyle(
                        color: s.tipoDespesa == TipoDespesa.fixa
                            ? const Color(0xFFB39DDB)
                            : _T.blue,
                        fontSize: 9,
                        fontFamily: _T.mono,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),
                // Badge status
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(s.status.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // Corpo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _infoItem(context, Icons.calendar_today_outlined, "Data",
                        _T.fmtData(s.data)),
                    _infoItem(
                        context,
                        Icons.event_outlined,
                        "Vencimento",
                        s.dataVencimento != null
                            ? _T.fmtData(s.dataVencimento!)
                            : '—'),
                    _infoItem(context, Icons.category_outlined, "Categoria",
                        s.categoria.label),
                  ],
                ),
                if (s.observacao.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notes_outlined,
                            size: 13,
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s.observacao,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("VALOR",
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5)),
                        Text(
                          _T.fmtMoeda(s.valor),
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 22,
                              fontFamily: _T.mono,
                              fontWeight: FontWeight.w800),
                        ),
                        if (isVencido)
                          Text("⚠️ Vencida",
                              style: TextStyle(
                                  color: _T.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      children: [
                        // Marcar como pago
                        if (!isPago)
                          _actionButton(
                            icon: Icons.check_rounded,
                            tooltip: "Marcar como Pago",
                            iconColor: _T.green,
                            onTap: () async =>
                            await controller.marcarComoPago(s.id),
                          ),
                        if (!isPago) const SizedBox(width: 8),
                        // Editar
                        _actionButton(
                          icon: Icons.edit_outlined,
                          tooltip: "Editar",
                          iconColor: _T.blue,
                          onTap: () =>
                              _showDialog(context, controller, saida: s),
                        ),
                        const SizedBox(width: 8),
                        // Excluir
                        _actionButton(
                          icon: Icons.delete_outline,
                          tooltip: "Excluir",
                          iconColor: _T.red,
                          onTap: () =>
                              _confirmDelete(context, s, controller),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _corCategoria(CategoriaSaida cat) {
    switch (cat) {
      case CategoriaSaida.aluguel:
        return const Color(0xFFB39DDB);
      case CategoriaSaida.folhaDePagamento:
        return _T.blue;
      case CategoriaSaida.impostos:
        return _T.red;
      case CategoriaSaida.fornecedores:
        return _T.orange;
      case CategoriaSaida.marketing:
        return const Color(0xFFFF80AB);
      case CategoriaSaida.utilities:
        return const Color(0xFFFFF176);
      case CategoriaSaida.manutencao:
        return const Color(0xFF80CBC4);
      case CategoriaSaida.transporte:
        return const Color(0xFF90CAF9);
      case CategoriaSaida.alimentacao:
        return _T.green;
      case CategoriaSaida.tecnologia:
        return const Color(0xFF80DEEA);
      case CategoriaSaida.outros:
        return const Color(0xFF90A4AE);
    }
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'Pago':
        return _T.green;
      case 'Vencido':
        return _T.red;
      default:
        return _T.orange;
    }
  }

  Widget _infoItem(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isMonospace = label.toLowerCase().contains("data") || 
                        label.toLowerCase().contains("vencimento") ||
                        label.toLowerCase().contains("valor") ||
                        label.toLowerCase().contains("id") ||
                        label.toLowerCase().contains("código");

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text(label.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.35),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 3),
          Text(value,
              style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: isMonospace ? _T.mono : null),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String tooltip,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        return Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconColor.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
          ),
        );
      }
    );
  }

  // ── CHIPS ──
  Widget _periodoChip(
      BuildContext context, String label, FiltroPeriodoSaida periodo, SaidaController c) {
    final selected = c.filtroPeriodo == periodo && c.periodoCustom == null;
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () => c.setFiltroPeriodo(periodo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? primaryColor
                  : Theme.of(context).dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? (primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

  Widget _customPeriodoChip(BuildContext context, SaidaController c) {
    final r = c.periodoCustom!;
    return GestureDetector(
      onTap: () => c.setFiltroPeriodo(FiltroPeriodoSaida.mes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _T.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: _T.orange.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.date_range, size: 12, color: _T.orange),
            const SizedBox(width: 6),
            Text(
              "${_T.fmtData(r.start)} → ${_T.fmtData(r.end)}",
              style: const TextStyle(
                  color: _T.orange,
                  fontSize: 11,
                  fontFamily: _T.mono,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 12, color: _T.orange),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(
      BuildContext context, String label, FiltroStatusSaida status, Color cor, SaidaController c) {
    final selected = c.filtroStatus == status;
    return GestureDetector(
      onTap: () => c.setFiltroStatus(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? cor : Theme.of(context).dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

  Widget _tipoChip(BuildContext context, String label, TipoDespesa? tipo, SaidaController c) {
    final selected = c.filtroTipo == tipo;
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: () => c.setFiltroTipo(tipo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? primaryColor.withValues(alpha: 0.15)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? primaryColor.withValues(alpha: 0.5)
                  : Theme.of(context).dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? primaryColor : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

  Widget _categoriaChip(
      BuildContext context, CategoriaSaida? cat, String label, SaidaController c) {
    final selected = c.filtroCategoria == cat;
    final primaryColor = Theme.of(context).primaryColor;
    final cor = cat != null ? _corCategoria(cat) : primaryColor;
    return GestureDetector(
      onTap: () => c.setFiltroCategoria(cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cor.withValues(alpha: 0.2) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? cor.withValues(alpha: 0.5)
                  : Theme.of(context).dividerColor),
        ),
        child: Tooltip(
          message: cat?.label ?? 'Todas categorias',
          child: Text(label,
              style: TextStyle(
                  color: selected ? cor : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  fontSize: cat != null ? 15 : 11,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400)),
        ),
      ),
    );
  }

  // ── CONFIRM DELETE ──
  void _confirmDelete(
      BuildContext context, Saida s, SaidaController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Theme.of(context).primaryColor, size: 40),
              const SizedBox(height: 12),
              Text("Excluir Saída",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text("Tem certeza que deseja excluir \"${s.descricao}\"?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Theme.of(context).dividerColor),
                        ),
                        child: Text("CANCELAR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await controller.excluir(s.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text("EXCLUIR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DIALOG ──
  void _showDialog(BuildContext context, SaidaController controller,
      {Saida? saida}) {
    final theme = Theme.of(context);
    final descricaoCtrl =
    TextEditingController(text: saida?.descricao ?? '');
    final fornecedorCtrl =
    TextEditingController(text: saida?.fornecedor ?? '');
    final valorCtrl = TextEditingController(
        text: saida != null
            ? saida.valor.toStringAsFixed(2).replaceAll('.', ',')
            : '');
    final obsCtrl =
    TextEditingController(text: saida?.observacao ?? '');

    CategoriaSaida categoria = saida?.categoria ?? CategoriaSaida.outros;
    TipoDespesa tipoDespesa = saida?.tipoDespesa ?? TipoDespesa.variavel;
    DateTime data = saida?.data ?? DateTime.now();
    DateTime? dataVencimento = saida?.dataVencimento;
    String status = saida?.status ?? 'Pendente';

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: StatefulBuilder(builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: theme.dialogBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _T.teal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        saida == null ? "NOVA SAÍDA" : "EDITAR SAÍDA",
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            fontSize: 14),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4), size: 20),
                      ),
                    ],
                  ),
                ),

                // Corpo
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _labelSection(context, "INFORMAÇÕES"),
                        const SizedBox(height: 10),
                        CustomInputWidget(
                          controller: descricaoCtrl,
                          label: "Descrição",
                          icon: Icons.description_outlined,
                        ),
                        const SizedBox(height: 10),
                        CustomInputWidget(
                          controller: fornecedorCtrl,
                          label: "Fornecedor / Origem",
                          icon: Icons.store_outlined,
                        ),
                        const SizedBox(height: 10),
                        CustomInputWidget(
                          controller: valorCtrl,
                          label: "Valor (ex: 1.500,00)",
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),
                        _labelSection(context, "TIPO DE DESPESA"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                        () => tipoDespesa = TipoDespesa.fixa),
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color: tipoDespesa == TipoDespesa.fixa
                                        ? const Color(0xFFB39DDB)
                                        : theme.scaffoldBackgroundColor,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                        tipoDespesa == TipoDespesa.fixa
                                            ? const Color(0xFFB39DDB)
                                            : theme.dividerColor),
                                  ),
                                  child: Text("🔒  Fixa",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                          tipoDespesa == TipoDespesa.fixa
                                              ? (const Color(0xFFB39DDB).computeLuminance() > 0.5 ? Colors.black : Colors.white)
                                              : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                        () => tipoDespesa = TipoDespesa.variavel),
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                    tipoDespesa == TipoDespesa.variavel
                                        ? _T.blue
                                        : theme.scaffoldBackgroundColor,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                        color: tipoDespesa ==
                                            TipoDespesa.variavel
                                            ? _T.blue
                                            : theme.dividerColor),
                                  ),
                                  child: Text("🔄  Variável",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: tipoDespesa ==
                                              TipoDespesa.variavel
                                              ? _T.blue.computeLuminance() > 0.5 ? Colors.black : Colors.white
                                              : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _labelSection(context, "CATEGORIA"),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: CategoriaSaida.values.map((cat) {
                            final sel = categoria == cat;
                            final cor = _corCategoria(cat);
                            return GestureDetector(
                              onTap: () => setState(() => categoria = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? cor.withValues(alpha: 0.2)
                                      : theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: sel
                                          ? cor
                                          : theme.dividerColor),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(cat.icon,
                                        style:
                                        const TextStyle(fontSize: 13)),
                                    const SizedBox(width: 5),
                                    Text(cat.label,
                                        style: TextStyle(
                                            color:
                                            sel ? cor : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                            fontSize: 11,
                                            fontWeight: sel
                                                ? FontWeight.w700
                                                : FontWeight.w400)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                        _labelSection(context, "DATAS E STATUS"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _datePicker(
                                context: context,
                                label: "Data",
                                icon: Icons.calendar_today_outlined,
                                data: data,
                                accentColor: theme.primaryColor,
                                onPicked: (d) => setState(() => data = d),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _datePicker(
                                context: context,
                                label: "Vencimento",
                                icon: Icons.event_outlined,
                                data: dataVencimento,
                                accentColor: _T.orange,
                                onPicked: (d) =>
                                    setState(() => dataVencimento = d),
                                nullable: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Status
                        Row(
                          children: ['Pendente', 'Pago'].map((s) {
                            final sel = status == s;
                            final cor = s == 'Pago'
                                ? _T.green
                                : _T.orange;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => status = s),
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 200),
                                  margin: EdgeInsets.only(
                                      right: s == 'Pendente' ? 5 : 0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  decoration: BoxDecoration(
                                    color: sel ? cor : theme.scaffoldBackgroundColor,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                        color: sel
                                            ? cor
                                            : theme.dividerColor),
                                  ),
                                  child: Text(s,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: sel
                                              ? (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                                              : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                          fontSize: 12,
                                          fontWeight: sel
                                              ? FontWeight.w700
                                              : FontWeight.w400)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        CustomInputWidget(
                          controller: obsCtrl,
                          label: "Observação (opcional)",
                          icon: Icons.notes_outlined,
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: theme.dividerColor),
                            ),
                            child: Text("CANCELAR",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () async {
                            final nova = Saida(
                              id: saida?.id ??
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              descricao: descricaoCtrl.text,
                              fornecedor: fornecedorCtrl.text,
                              categoria: categoria,
                              tipoDespesa: tipoDespesa,
                              data: data,
                              dataVencimento: dataVencimento,
                              valor: parseValor(valorCtrl.text),
                              observacao: obsCtrl.text,
                              status: status,
                            );
                            if (saida == null) {
                              await controller.salvar(nova);
                            } else {
                              await controller.atualizar(nova);
                            }
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              saida == null ? "SALVAR SAÍDA" : "ATUALIZAR",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _datePicker({
    required BuildContext context,
    required String label,
    required IconData icon,
    required DateTime? data,
    required Color accentColor,
    required void Function(DateTime) onPicked,
    bool nullable = false,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: data ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: accentColor,
                brightness: Theme.of(context).brightness,
                primary: accentColor,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
                          fontSize: 10)),
                  Text(
                    data != null ? _formatData(data) : 'Opcional',
                    style: TextStyle(
                        color: data != null
                            ? Theme.of(context).textTheme.bodyMedium?.color
                            : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.38),
                        fontSize: 13,
                        fontFamily: data != null ? 'monospace' : null),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Widget _labelSection(BuildContext context, String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _T.teal,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 8),
        Text(label.toUpperCase(),
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5)),
      ],
    );
  }
}

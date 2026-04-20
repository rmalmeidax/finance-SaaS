import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/entrada_controller.dart';
import '../../model/entrada_model.dart';
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

class EntradaScreen extends StatelessWidget {
  const EntradaScreen({super.key});

  double parseValor(String texto) =>
      double.tryParse(texto.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<EntradaController>(context);
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
              "ENTRADAS",
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
                  hintText: "Buscar por descrição ou cliente...",
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
                _periodoChip(context, "Hoje", FiltroPeriodo.hoje, controller),
                const SizedBox(width: 8),
                _periodoChip(context, "Semana", FiltroPeriodo.semana, controller),
                const SizedBox(width: 8),
                _periodoChip(context, "Mês", FiltroPeriodo.mes, controller),
                const SizedBox(width: 8),
                _periodoChip(context, "Trimestre", FiltroPeriodo.trimestre, controller),
                const SizedBox(width: 8),
                _periodoChip(context, "Todos", FiltroPeriodo.todos, controller),
                if (controller.periodoCustom != null) ...[
                  const SizedBox(width: 8),
                  _customPeriodoChip(context, controller),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── FILTRO CATEGORIA ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _categoriaChip(context, null, "Todas", controller),
                ...CategoriaEntrada.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _categoriaChip(context, cat, cat.label, controller),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── LISTA ──
          Expanded(
            child: controller.entradas.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up_outlined,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.12), size: 60),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhuma entrada encontrada",
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
              itemCount: controller.entradas.length,
              itemBuilder: (_, i) => _entradaCard(
                  context, controller.entradas[i], controller),
            ),
          ),
        ],
      ),
    );
  }

  // ── DASHBOARD ──
  Widget _dashboard(BuildContext context, EntradaController controller) {
    final hoje = DateTime.now();
    final totalMes = controller.entradas
        .where((e) =>
    e.data.year == hoje.year && e.data.month == hoje.month)
        .fold(0.0, (s, e) => s + e.valor);

    final maiorCategoria = controller.entradas.isEmpty 
        ? CategoriaEntrada.outros 
        : CategoriaEntrada.values.reduce((a, b) =>
            controller.totalPorCategoria(a) >= controller.totalPorCategoria(b) ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final cards = [
          Expanded(
            flex: isMobile ? 1 : 2,
            child: DashboardResumoCardWidget(
              title: "TOTAL FILTRADO",
              value: _T.fmtMoeda(controller.totalEntradas),
              color: _T.teal,
              icon: Icons.account_balance_wallet_outlined,
              isWide: !isMobile,
            ),
          ),
          Expanded(
            child: DashboardResumoCardWidget(
              title: "ESTE MÊS",
              value: _T.fmtMoeda(totalMes),
              color: const Color(0xFF4FC3F7),
              icon: Icons.calendar_month_outlined,
            ),
          ),
          Expanded(
            child: DashboardResumoCardWidget(
              title: "TOP CATEG.",
              value: "${maiorCategoria.icon} ${maiorCategoria.label}",
              color: const Color(0xFFFFB74D),
              icon: Icons.star_outline,
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
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              cards[0],
              const SizedBox(width: 10),
              cards[1],
              const SizedBox(width: 10),
              cards[2],
            ],
          ),
        );
      }
    );
  }

  // Card local removido em favor do widget global DashboardResumoCardWidget


  // ── CARD ──
  Widget _entradaCard(
      BuildContext context, Entrada e, EntradaController controller) {
    final cor = _corCategoria(e.categoria);
    final theme = Theme.of(context);
    final isRecebido = e.status == 'Recebido';
    final statusColor = isRecebido ? _T.green : _T.orange;

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
              color: cor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                  bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
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
                    child: Text(e.categoria.icon,
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.descricao.toUpperCase(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (e.cliente.isNotEmpty)
                        Text(e.cliente,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                fontSize: 11)),
                    ],
                  ),
                ),
                // Badge status
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(e.status.toUpperCase(),
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
                        _T.fmtData(e.data)),
                    _infoItem(context, Icons.person_outline, "Cliente",
                        e.cliente.isEmpty ? '—' : e.cliente),
                    _infoItem(context, Icons.category_outlined, "Categoria",
                        e.categoria.label),
                  ],
                ),
                if (e.observacao.isNotEmpty) ...[
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
                          child: Text(e.observacao,
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
                          _T.fmtMoeda(e.valor),
                          style: TextStyle(
                              color: isRecebido ? _T.green : _T.orange,
                              fontSize: 22,
                              fontFamily: _T.mono,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _actionButton(
                          icon: Icons.edit_outlined,
                          tooltip: "Editar",
                          iconColor: _T.blue,
                          onTap: () =>
                              _showDialog(context, controller, entrada: e),
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          icon: Icons.delete_outline,
                          tooltip: "Excluir",
                          iconColor: _T.red,
                          onTap: () =>
                              _confirmDelete(context, e, controller),
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

  Color _corCategoria(CategoriaEntrada cat) {
    switch (cat) {
      case CategoriaEntrada.salario:
        return _T.green;
      case CategoriaEntrada.vendas:
        return _T.blue;
      case CategoriaEntrada.servicos:
        return _T.orange;
      case CategoriaEntrada.alugueis:
        return const Color(0xFFB39DDB);
      case CategoriaEntrada.investimentos:
        return _T.teal;
      case CategoriaEntrada.outros:
        return const Color(0xFF90A4AE);
    }
  }

  Widget _infoItem(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isMonospace = label.toLowerCase().contains("data") || 
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
                fontFamily: isMonospace ? _T.mono : null,
              ),
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

  // ── CHIPS ──
  Widget _periodoChip(
      BuildContext context, String label, FiltroPeriodo periodo, EntradaController c) {
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

  Widget _customPeriodoChip(BuildContext context, EntradaController c) {
    final r = c.periodoCustom!;
    return GestureDetector(
      onTap: () => c.setFiltroPeriodo(FiltroPeriodo.mes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _T.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _T.orange.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.date_range,
                size: 12, color: _T.orange),
            const SizedBox(width: 6),
            Text("${_T.fmtData(r.start)} → ${_T.fmtData(r.end)}",
                style: const TextStyle(
                    color: _T.orange,
                    fontSize: 11,
                    fontFamily: _T.mono,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 12, color: _T.orange),
          ],
        ),
      ),
    );
  }

  Widget _categoriaChip(
      BuildContext context, CategoriaEntrada? cat, String label, EntradaController c) {
    final selected = c.filtroCategoria == cat;
    final primaryColor = Theme.of(context).primaryColor;
    final cor = cat != null ? _corCategoria(cat) : primaryColor;
    return GestureDetector(
      onTap: () => c.setFiltroCategoria(cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? cor : Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cat != null) ...[
              Text(cat.icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
            ],
            Text(label,
                style: TextStyle(
                    color: selected ? (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  // ── CONFIRM DELETE ──
  void _confirmDelete(
      BuildContext context, Entrada e, EntradaController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: _T.red, size: 40),
              const SizedBox(height: 12),
              Text("Excluir Entrada",
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text("Tem certeza que deseja excluir \"${e.descricao}\"?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      fontSize: 13)),
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
                        await controller.excluir(e.id);
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
  void _showDialog(BuildContext context, EntradaController controller,
      {Entrada? entrada}) {
    final theme = Theme.of(context);
    final descricaoCtrl =
    TextEditingController(text: entrada?.descricao ?? '');
    final clienteCtrl =
    TextEditingController(text: entrada?.cliente ?? '');
    final valorCtrl = TextEditingController(
        text: entrada != null
            ? entrada.valor.toStringAsFixed(2).replaceAll('.', ',')
            : '');
    final obsCtrl =
    TextEditingController(text: entrada?.observacao ?? '');

    CategoriaEntrada categoria =
        entrada?.categoria ?? CategoriaEntrada.outros;
    DateTime data = entrada?.data ?? DateTime.now();
    String status = entrada?.status ?? 'Recebido';

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
                        entrada == null ? "NOVA ENTRADA" : "EDITAR ENTRADA",
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
                          controller: clienteCtrl,
                          label: "Cliente / Origem",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 10),
                        CustomInputWidget(
                          controller: valorCtrl,
                          label: "Valor (ex: 1.500,00)",
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),
                        _labelSection(context, "CATEGORIA"),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: CategoriaEntrada.values.map((cat) {
                            final selected = categoria == cat;
                            final cor = _corCategoria(cat);
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => categoria = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? cor.withValues(alpha: 0.2)
                                      : theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: selected
                                          ? cor
                                          : theme.dividerColor),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(cat.icon,
                                        style: const TextStyle(
                                            fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(cat.label,
                                        style: TextStyle(
                                            color: selected
                                                ? cor
                                                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                            fontSize: 12,
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w400)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                        _labelSection(context, "DATA E STATUS"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Date picker
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: data,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
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
                                  if (picked != null)
                                    setState(() => data = picked);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: theme.scaffoldBackgroundColor,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                        color: theme.dividerColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color: theme.primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text("Data",
                                                style: TextStyle(
                                                    color: theme.textTheme.bodyMedium?.color
                                                        ?.withValues(alpha: 0.35),
                                                    fontSize: 10)),
                                            Text(_T.fmtData(data),
                                                style: TextStyle(
                                                    color: theme.textTheme.bodyMedium?.color,
                                                    fontSize: 13,
                                                    fontFamily: _T.mono)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Status toggle
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text("Status",
                                      style: TextStyle(
                                          color: theme.textTheme.bodyMedium?.color
                                              ?.withValues(alpha: 0.35),
                                          fontSize: 10)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: ['Recebido', 'Pendente']
                                        .map((s) {
                                      final sel = status == s;
                                      final cor = s == 'Recebido'
                                          ? _T.green
                                          : _T.orange;
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => status = s),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            margin:
                                            EdgeInsets.only(right: s == 'Recebido' ? 4 : 0),
                                            padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                              color: sel
                                                  ? cor
                                                  : theme.scaffoldBackgroundColor,
                                              borderRadius:
                                              BorderRadius.circular(8),
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
                                                    fontSize: 11,
                                                    fontWeight: sel
                                                        ? FontWeight.w700
                                                        : FontWeight.w400)),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                            final nova = Entrada(
                              id: entrada?.id ??
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                              descricao: descricaoCtrl.text,
                              cliente: clienteCtrl.text,
                              categoria: categoria,
                              data: data,
                              valor: parseValor(valorCtrl.text),
                              observacao: obsCtrl.text,
                              status: status,
                            );
                            if (entrada == null) {
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
                              entrada == null
                                  ? "SALVAR ENTRADA"
                                  : "ATUALIZAR",
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
}

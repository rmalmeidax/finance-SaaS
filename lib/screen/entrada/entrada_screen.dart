import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/entrada_controller.dart';
import '../../model/entrada_model.dart';
import '../../widgets/theme_toggle_button.dart';

class EntradaScreen extends StatelessWidget {
  const EntradaScreen({super.key});

  String formatar(double valor) =>
      valor.toStringAsFixed(2).replaceAll('.', ',');

  double parseValor(String texto) =>
      double.tryParse(texto.replaceAll(',', '.')) ?? 0;

  String _formatData(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<EntradaController>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).primaryColor, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 3,
              height: 22,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "ENTRADAS",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        actions: [
          const ThemeToggleButton(),
          // Filtro período customizado
          IconButton(
            icon: Icon(Icons.date_range_outlined,
                color: Theme.of(context).primaryColor, size: 20),
            tooltip: "Filtrar por período",
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: controller.periodoCustom,
                builder: (ctx, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Theme.of(context).primaryColor,
                      brightness: Theme.of(context).brightness,
                      primary: Theme.of(context).primaryColor,
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
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: Icon(Icons.add, color: Theme.of(context).primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: TextField(
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Buscar por descrição ou cliente...",
                  hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3), fontSize: 14),
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context).primaryColor, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: controller.setBusca,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── DASHBOARD ──
          _dashboard(controller),

          const SizedBox(height: 16),

          // ── FILTRO PERÍODO ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _periodoChip("Hoje", FiltroPeriodo.hoje, controller),
                const SizedBox(width: 8),
                _periodoChip("Semana", FiltroPeriodo.semana, controller),
                const SizedBox(width: 8),
                _periodoChip("Mês", FiltroPeriodo.mes, controller),
                const SizedBox(width: 8),
                _periodoChip("Trimestre", FiltroPeriodo.trimestre, controller),
                const SizedBox(width: 8),
                _periodoChip("Todos", FiltroPeriodo.todos, controller),
                if (controller.periodoCustom != null) ...[
                  const SizedBox(width: 8),
                  _customPeriodoChip(controller),
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
                _categoriaChip(null, "Todas", controller),
                ...CategoriaEntrada.values.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _categoriaChip(cat, cat.label, controller),
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
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.12), size: 60),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhuma entrada encontrada",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
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
  Widget _dashboard(EntradaController controller) {
    final hoje = DateTime.now();
    final totalMes = controller.entradas
        .where((e) =>
    e.data.year == hoje.year && e.data.month == hoje.month)
        .fold(0.0, (s, e) => s + e.valor);

    final maiorCategoria = CategoriaEntrada.values.reduce((a, b) =>
    controller.totalPorCategoria(a) >= controller.totalPorCategoria(b)
        ? a
        : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 500;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  _dashCard(
                    "TOTAL FILTRADO",
                    "R\$ ${formatar(controller.totalEntradas)}",
                    Theme.of(context).primaryColor,
                    Icons.account_balance_wallet_outlined,
                    wide: true,
                  ),
                  if (!isSmall) ...[
                    const SizedBox(width: 10),
                    _dashCard(
                      "ESTE MÊS",
                      "R\$ ${formatar(totalMes)}",
                      const Color(0xFF4FC3F7),
                      Icons.calendar_month_outlined,
                    ),
                  ],
                ],
              ),
              if (isSmall) const SizedBox(height: 10),
              Row(
                children: [
                  if (isSmall) ...[
                    _dashCard(
                      "ESTE MÊS",
                      "R\$ ${formatar(totalMes)}",
                      const Color(0xFF4FC3F7),
                      Icons.calendar_month_outlined,
                    ),
                    const SizedBox(width: 10),
                  ],
                  _dashCard(
                    "TOP CATEG.",
                    "${maiorCategoria.icon} ${maiorCategoria.label}",
                    const Color(0xFFFFB74D),
                    Icons.star_outline,
                    wide: isSmall,
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _dashCard(String titulo, String valor, Color cor, IconData icon,
      {bool wide = false}) {
    return Expanded(
      flex: wide ? 2 : 1,
      child: Builder(
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cor.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 13, color: cor),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(titulo,
                          style: TextStyle(
                              color: cor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(valor,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: wide ? 14 : 12,
                        fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        }
      ),
    );
  }

  // ── CARD ──
  Widget _entradaCard(
      BuildContext context, Entrada e, EntradaController controller) {
    final cor = _corCategoria(e.categoria);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border:
              Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                // Ícone categoria
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.12),
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
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (e.cliente.isNotEmpty)
                        Text(e.cliente,
                            style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                                fontSize: 11)),
                    ],
                  ),
                ),
                // Badge categoria
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: cor.withOpacity(0.3)),
                  ),
                  child: Text(e.categoria.label,
                      style: TextStyle(
                          color: cor,
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
                    _infoItem(Icons.calendar_today_outlined, "Data",
                        _formatData(e.data)),
                    _infoItem(Icons.person_outline, "Cliente",
                        e.cliente.isEmpty ? '—' : e.cliente),
                    _infoItem(Icons.info_outline, "Status", e.status),
                  ],
                ),
                if (e.observacao.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notes_outlined,
                            size: 13,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.35)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e.observacao,
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
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
                            style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
                                fontSize: 9,
                                letterSpacing: 1.5)),
                        Text(
                          "R\$ ${formatar(e.valor)}",
                          style: const TextStyle(
                              color: Color(0xFF66BB6A),
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _actionButton(
                          icon: Icons.edit_outlined,
                          tooltip: "Editar",
                          color: const Color(0xFF4FC3F7).withOpacity(0.1),
                          iconColor: const Color(0xFF4FC3F7),
                          onTap: () =>
                              _showDialog(context, controller, entrada: e),
                        ),
                        const SizedBox(width: 8),
                        _actionButton(
                          icon: Icons.delete_outline,
                          tooltip: "Excluir",
                          color: Colors.red.withOpacity(0.1),
                          iconColor: Colors.red.withOpacity(0.6),
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
        return const Color(0xFF66BB6A);
      case CategoriaEntrada.vendas:
        return const Color(0xFF4FC3F7);
      case CategoriaEntrada.servicos:
        return const Color(0xFFFFB74D);
      case CategoriaEntrada.alugueis:
        return const Color(0xFFB39DDB);
      case CategoriaEntrada.investimentos:
        return const Color(0xFF26A69A);
      case CategoriaEntrada.outros:
        return const Color(0xFF90A4AE);
    }
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Builder(
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 11, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 4),
                  Text(label,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.35),
                          fontSize: 9,
                          letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 3),
              Text(value,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 12),
                  overflow: TextOverflow.ellipsis),
            ],
          );
        }
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
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
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconColor.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
      ),
    );
  }

  // ── CHIPS ──
  Widget _periodoChip(
      String label, FiltroPeriodo periodo, EntradaController c) {
    return Builder(
      builder: (context) {
        final selected =
            c.filtroPeriodo == periodo && c.periodoCustom == null;
        return GestureDetector(
          onTap: () => c.setFiltroPeriodo(periodo),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: selected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).dividerColor),
            ),
            child: Text(label,
                style: TextStyle(
                    color: selected ? (Theme.of(context).primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54),
                    fontSize: 11,
                    fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w400)),
          ),
        );
      }
    );
  }

  Widget _customPeriodoChip(EntradaController c) {
    final r = c.periodoCustom!;
    final label =
        "${_formatData(r.start)} → ${_formatData(r.end)}";
    return GestureDetector(
      onTap: () => c.setFiltroPeriodo(FiltroPeriodo.mes),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB74D).withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFFB74D).withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.date_range,
                size: 12, color: Color(0xFFFFB74D)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFFFFB74D),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 12, color: Color(0xFFFFB74D)),
          ],
        ),
      ),
    );
  }

  Widget _categoriaChip(
      CategoriaEntrada? cat, String label, EntradaController c) {
    return Builder(
      builder: (context) {
        final selected = c.filtroCategoria == cat;
        final cor = cat != null ? _corCategoria(cat) : Theme.of(context).primaryColor;
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
                        color: selected ? (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54),
                        fontSize: 11,
                        fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w400)),
              ],
            ),
          ),
        );
      }
    );
  }

  // ── CONFIRM DELETE ──
  void _confirmDelete(
      BuildContext context, Entrada e, EntradaController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFE53935), size: 40),
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
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
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
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Theme.of(context).dividerColor),
                        ),
                        child: Text("CANCELAR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54),
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
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text("EXCLUIR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor),
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
                        bottom: BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        entrada == null ? "NOVA ENTRADA" : "EDITAR ENTRADA",
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            fontSize: 14),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4), size: 20),
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
                        _labelSection("INFORMAÇÕES"),
                        const SizedBox(height: 10),
                        _inputField(descricaoCtrl, "Descrição",
                            Icons.description_outlined),
                        const SizedBox(height: 10),
                        _inputField(clienteCtrl, "Cliente / Origem",
                            Icons.person_outline),
                        const SizedBox(height: 10),
                        _inputField(
                          valorCtrl,
                          "Valor (ex: 1.500,00)",
                          Icons.attach_money,
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),
                        _labelSection("CATEGORIA"),
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
                                      ? cor
                                      : Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: selected
                                          ? cor
                                          : Theme.of(context).dividerColor),
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
                                                ? (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                                                : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54),
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
                        _labelSection("DATA E STATUS"),
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
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.fromSeed(
                                          seedColor: Theme.of(context).primaryColor,
                                          brightness: Theme.of(context).brightness,
                                          primary: Theme.of(context).primaryColor,
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
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Theme.of(context).dividerColor),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color: Theme.of(context).primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text("Data",
                                                style: TextStyle(
                                                    color: Theme.of(context).textTheme.bodyMedium?.color
                                                        ?.withOpacity(0.35),
                                                    fontSize: 10)),
                                            Text(_formatData(data),
                                                style: TextStyle(
                                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                                    fontSize: 13)),
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
                                          color: Theme.of(context).textTheme.bodyMedium?.color
                                              ?.withOpacity(0.35),
                                          fontSize: 10)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: ['Recebido', 'Pendente']
                                        .map((s) {
                                      final sel = status == s;
                                      final cor = s == 'Recebido'
                                          ? const Color(0xFF66BB6A)
                                          : const Color(0xFFFFB74D);
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
                                                  : Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius:
                                              BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: sel
                                                      ? cor
                                                      : Theme.of(context).dividerColor),
                                            ),
                                            child: Text(s,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: sel
                                                        ? (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                                                        : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54),
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
                        _inputField(obsCtrl, "Observação (opcional)",
                            Icons.notes_outlined),
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor)),
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
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Theme.of(context).dividerColor),
                            ),
                            child: Text("CANCELAR",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.54),
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
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              entrada == null
                                  ? "SALVAR ENTRADA"
                                  : "ATUALIZAR",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
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

  Widget _labelSection(String label) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Container(
              width: 2,
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2)),
          ],
        );
      }
    );
  }

  Widget _inputField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Builder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.35), fontSize: 12),
              prefixIcon:
              Icon(icon, size: 16, color: Theme.of(context).primaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 12),
            ),
          ),
        );
      }
    );
  }
}
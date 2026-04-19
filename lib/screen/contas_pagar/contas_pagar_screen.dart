import 'package:finance/model/conta_pagar_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/conta_pagar_controller.dart';

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

class ContasPagarScreen extends StatelessWidget {
  const ContasPagarScreen({super.key});

  double parseValor(String texto) {
    return double.tryParse(texto.replaceAll(',', '.')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ContaPagarController>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.primaryColor, size: 18),
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
              "CONTAS A PAGAR",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        actions: [
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
                borderRadius: BorderRadius.circular(14), // Standard 14px
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Buscar fornecedor ou descrição...",
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search, color: theme.primaryColor, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: controller.setBusca,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── DASHBOARD ──
          _dashboard(context, controller),

          const SizedBox(height: 20),

          // ── FILTROS ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filtroChip(context, "Todas", FiltroStatus.todos, controller),
                  const SizedBox(width: 8),
                  _filtroChip(context, "A pagar", FiltroStatus.aVencer, controller),
                  const SizedBox(width: 8),
                  _filtroChip(context, "Vencidas", FiltroStatus.vencidos, controller),
                  const SizedBox(width: 8),
                  _filtroChip(context, "Pagas", FiltroStatus.pagos, controller),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── LISTA ──
          Expanded(
            child: controller.contas.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.15), size: 56),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhuma conta encontrada",
                    style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                        fontSize: 14,
                        letterSpacing: 1),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: controller.contas.length,
              itemBuilder: (_, index) {
                final conta = controller.contas[index];
                return _contaCard(context, conta, controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── CARD ──
  Widget _contaCard(
      BuildContext context, ContaPagar conta, ContaPagarController controller) {
    final theme = Theme.of(context);
    final hoje = DateTime.now();
    final vencida = hoje.isAfter(conta.dataVencimento) && conta.status != "Pago" && conta.status != "Recebido";
    final paga = conta.status == "Pago" || conta.status == "Recebido";

    Color statusColor = paga
        ? _T.green
        : vencida
        ? _T.red
        : _T.teal;

    String statusLabel = paga
        ? "PAGO"
        : vencida
        ? "VENCIDO"
        : "A PAGAR";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho colorido (Standardized)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.05), // Standard 0.05 opacity
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: statusColor.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    conta.descricao.toUpperCase(),
                    style: TextStyle(
                      color: theme.textTheme.titleMedium?.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
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
                    _infoItem(context, Icons.store_outlined, "Fornecedor", conta.fornecedor),
                    _infoItem(context, Icons.description_outlined, "Documento", conta.numeroDocumento),
                    _infoItem(context, Icons.category_outlined, "Tipo", conta.tipoDocumento.name),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _infoItem(context, Icons.calendar_today_outlined, "Emissão",
                        _T.fmtData(conta.dataEmissao)),
                    _infoItem(context, Icons.event_outlined, "Vencimento",
                        _T.fmtData(conta.dataVencimento)),
                    _infoItem(context, Icons.percent_outlined, "Juros/Multa",
                        "${conta.juros.toStringAsFixed(1)}% / ${conta.multa.toStringAsFixed(1)}%"),
                  ],
                ),
                const SizedBox(height: 14),
                // Valor + Ações
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "VALOR ATUALIZADO",
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          _T.fmtMoeda(conta.valorAtualizado),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            fontFamily: _T.mono,
                          ),
                        ),
                        if (conta.valorAtualizado != conta.valorBoleto)
                          Text(
                            "Original: ${_T.fmtMoeda(conta.valorBoleto)}",
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              fontFamily: _T.mono,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        // Recalcular
                        _actionButton(
                          context,
                          icon: Icons.refresh_rounded,
                          tooltip: "Recalcular",
                          color: theme.dividerColor.withValues(alpha: 0.05),
                          iconColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5) ?? Colors.grey,
                          onTap: () async {
                            conta.valorAtualizado =
                                controller.calcularValorAtualizado(conta);
                            await controller.service.atualizar(conta);
                          },
                        ),
                        const SizedBox(width: 8),
                        // Editar
                        _actionButton(
                          context,
                          icon: Icons.edit_outlined,
                          tooltip: "Editar",
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          iconColor: theme.primaryColor,
                          onTap: () => _showDialog(context, controller, conta: conta),
                        ),
                        const SizedBox(width: 8),
                        // Pagar
                        if (!paga)
                          _actionButton(
                            context,
                            icon: Icons.check_rounded,
                            tooltip: "Marcar como Pago",
                            color: _T.green.withValues(alpha: 0.1),
                            iconColor: _T.green,
                            onTap: () async {
                              await controller.service.marcarComoPago(conta.id);
                            },
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

  Widget _infoItem(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isMonospace = label == "Emissão" || label == "Vencimento" || label == "Juros/Multa" || label == "Documento";
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.35),
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 12,
                fontFamily: isMonospace ? _T.mono : null),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
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
            border: Border.all(color: iconColor.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
      ),
    );
  }

  // ── FILTRO CHIP ──
  Widget _filtroChip(BuildContext context, String label, FiltroStatus filtro, ContaPagarController c) {
    final theme = Theme.of(context);
    final selecionado = c.filtroAtual == filtro;
    return GestureDetector(
      onTap: () => c.setFiltro(filtro),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: selecionado ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selecionado
                ? theme.primaryColor
                : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selecionado 
                ? theme.colorScheme.onPrimary
                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
            fontSize: 11,
            fontWeight: selecionado ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ── DASHBOARD (Responsive Grid) ──
  Widget _dashboard(BuildContext context, ContaPagarController controller) {
    final theme = Theme.of(context);
    double total = 0, vencido = 0, aPagar = 0;
    final hoje = DateTime.now();
    for (var c in controller.contas) {
      total += c.valorAtualizado;
      if (c.dataVencimento.isBefore(hoje) &&
          c.status != "Pago" &&
          c.status != "Recebido") {
        vencido += c.valorAtualizado;
      } else if (c.dataVencimento.isAfter(hoje)) {
        aPagar += c.valorAtualizado;
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;

      if (isMobile) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _dashCard(context, "TOTAL", total, _T.teal, Icons.account_balance_wallet_outlined, isFullWidth: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  _dashCard(context, "VENCIDO", vencido, _T.red, Icons.warning_amber_outlined),
                  const SizedBox(width: 10),
                  _dashCard(context, "A PAGAR", aPagar, _T.blue, Icons.schedule_outlined),
                ],
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _dashCard(context, "TOTAL", total, _T.teal, Icons.account_balance_wallet_outlined),
            const SizedBox(width: 10),
            _dashCard(context, "VENCIDO", vencido, _T.red, Icons.warning_amber_outlined),
            const SizedBox(width: 10),
            _dashCard(context, "A PAGAR", aPagar, _T.blue, Icons.schedule_outlined),
          ],
        ),
      );
    });
  }

  Widget _dashCard(BuildContext context, String titulo, double valor, Color cor, IconData icon, {bool isFullWidth = false}) {
    final theme = Theme.of(context);
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: cor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: cor),
              const SizedBox(width: 5),
              Text(
                titulo,
                style: TextStyle(
                  color: cor,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _T.fmtMoeda(valor),
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: _T.mono,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return isFullWidth ? card : Expanded(child: card);
  }

  // ── DIALOG ──
  void _showDialog(BuildContext context, ContaPagarController controller,
      {ContaPagar? conta}) {
    final theme = Theme.of(context);
    final fornecedor = TextEditingController(text: conta?.fornecedor ?? '');
    final descricao = TextEditingController(text: conta?.descricao ?? '');
    final numero = TextEditingController(text: conta?.numeroDocumento ?? '');
    final valor = TextEditingController(
        text: conta != null ? conta.valorBoleto.toStringAsFixed(2) : '');
    final jurosMensal = TextEditingController(
        text: conta != null ? conta.juros.toStringAsFixed(2) : '');
    final multaCtrl = TextEditingController(
        text: conta != null ? conta.multa.toStringAsFixed(2) : '');

    TipoDocumento tipo = conta?.tipoDocumento ?? TipoDocumento.boleto;
    DateTime dataEmissao = conta?.dataEmissao ?? DateTime.now();
    DateTime dataVencimento = conta?.dataVencimento ?? DateTime.now();

    // Taxa diária derivada do mensal — calculada reativamente no StatefulBuilder
    double _taxaDiaria(String mensal) {
      final m = double.tryParse(mensal.replaceAll(',', '.')) ?? 0;
      return m / 30;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: theme.dividerColor),
                      ),
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
                          conta == null ? "NOVA CONTA" : "EDITAR CONTA",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4), size: 20),
                        ),
                      ],
                    ),
                  ),

                  // Campos
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelSection(context, "INFORMAÇÕES GERAIS"),
                          const SizedBox(height: 10),
                          _inputField(context, fornecedor, "Fornecedor", Icons.store_outlined),
                          const SizedBox(height: 10),
                          _inputField(context, descricao, "Descrição", Icons.description_outlined),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _inputField(context, numero, "Nº Documento", Icons.tag)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _dropdownTipo(context, tipo, (v) => setState(() => tipo = v!)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          _labelSection(context, "DATAS"),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _datePicker(
                                  context: context,
                                  label: "Data de Emissão",
                                  icon: Icons.calendar_today_outlined,
                                  data: dataEmissao,
                                  onPicked: (d) => setState(() => dataEmissao = d),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _datePicker(
                                  context: context,
                                  label: "Data de Vencimento",
                                  icon: Icons.event_outlined,
                                  data: dataVencimento,
                                  onPicked: (d) => setState(() => dataVencimento = d),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          _labelSection(context, "VALORES"),
                          const SizedBox(height: 10),
                          _inputField(context, valor, "Valor (ex: 1000,50)", Icons.attach_money,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(
                                  context,
                                  jurosMensal,
                                  "Juros Mensal (%)",
                                  Icons.trending_up,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.show_chart, size: 13, color: theme.primaryColor),
                                          const SizedBox(width: 5),
                                          Text(
                                            "TAXA DIÁRIA",
                                            style: TextStyle(
                                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                                              fontSize: 9,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${_taxaDiaria(jurosMensal.text).toStringAsFixed(4)}%",
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: _T.mono,
                                        ),
                                      ),
                                      Text(
                                        "ao dia",
                                        style: TextStyle(
                                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _inputField(context, multaCtrl, "Multa (%)", Icons.gavel_outlined,
                              keyboardType: TextInputType.number),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: theme.dividerColor)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: theme.dividerColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Text(
                                "CANCELAR",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () async {
                              final valorBoleto = parseValor(valor.text);
                              final jurosValor = parseValor(jurosMensal.text);
                              final multaValor = parseValor(multaCtrl.text);

                              if (conta == null) {
                                // Nova conta
                                final nova = ContaPagar(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  fornecedor: fornecedor.text,
                                  descricao: descricao.text,
                                  numeroDocumento: numero.text,
                                  tipoDocumento: tipo,
                                  dataEmissao: dataEmissao,
                                  dataVencimento: dataVencimento,
                                  valorBoleto: valorBoleto,
                                  valorAtualizado: valorBoleto,
                                  juros: jurosValor,
                                  multa: multaValor,
                                  status: "Pendente",
                                );
                                nova.valorAtualizado =
                                    controller.calcularValorAtualizado(nova);
                                await controller.adicionar(nova);
                              } else {
                                // Editar
                                final atualizada = ContaPagar(
                                  id: conta.id,
                                  fornecedor: fornecedor.text,
                                  descricao: descricao.text,
                                  numeroDocumento: numero.text,
                                  tipoDocumento: tipo,
                                  dataEmissao: dataEmissao,
                                  dataVencimento: dataVencimento,
                                  valorBoleto: valorBoleto,
                                  valorAtualizado: valorBoleto,
                                  juros: jurosValor,
                                  multa: multaValor,
                                  status: conta.status,
                                );
                                atualizada.valorAtualizado =
                                    controller.calcularValorAtualizado(atualizada);
                                await controller.atualizar(atualizada);
                              }

                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                conta == null ? "SALVAR CONTA" : "ATUALIZAR",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
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
          },
        ),
      ),
    );
  }

  Widget _labelSection(BuildContext context, String label) {
    final theme = Theme.of(context);
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
        Text(
          label,
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _inputField(
      BuildContext context,
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        void Function(String)? onChanged,
      }) {
    final theme = Theme.of(context);
    final isMonospace = label.contains("Valor") || label.contains("Juros") || label.contains("Multa") || label.contains("Nº Documento");
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 14,
            fontFamily: isMonospace ? _T.mono : null),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
            fontSize: 12,
          ),
          prefixIcon: Icon(icon, size: 16, color: theme.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _dropdownTipo(
      BuildContext context,
      TipoDocumento valor, void Function(TipoDocumento?) onChanged) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TipoDocumento>(
          value: valor,
          dropdownColor: theme.cardColor,
          icon: Icon(Icons.keyboard_arrow_down, color: theme.primaryColor, size: 18),
          style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13),
          items: TipoDocumento.values.map((t) {
            return DropdownMenuItem(
              value: t,
              child: Text(t.name,
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _datePicker({
    required BuildContext context,
    required String label,
    required IconData icon,
    required DateTime data,
    required void Function(DateTime) onPicked,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: data,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: theme.primaryColor,
                onPrimary: theme.colorScheme.onPrimary,
                surface: theme.cardColor,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: theme.primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.35),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    _T.fmtData(data),
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13, fontFamily: _T.mono),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

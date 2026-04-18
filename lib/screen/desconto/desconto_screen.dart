import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../controllers/desconto_controller.dart';
import '../../../model/desconto_model.dart';
import '../../../widgets/theme_toggle_button.dart';

class DescontoScreen extends StatelessWidget {
  const DescontoScreen({super.key});

  String formatar(double valor) =>
      valor.toStringAsFixed(2).replaceAll('.', ',');

  String _formatData(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<DescontoController>(context);
    final theme = Theme.of(context);
    final state = controller.state;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "DESCONTOS",
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
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: Icon(Icons.add,
                  color: theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
              onPressed: () {
                // Implementar _showDialog futuramente
              },
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Buscar título ou cliente...",
                  hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3), fontSize: 14),
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

          // ── FILTROS DE STATUS ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _statusChip(context, "Todos", null, controller),
                const SizedBox(width: 8),
                _statusChip(context, "Ativos", DescontoStatus.ativo, controller),
                const SizedBox(width: 8),
                _statusChip(context, "Expirando", DescontoStatus.expirando, controller),
                const SizedBox(width: 8),
                _statusChip(context, "Agendados", DescontoStatus.agendado, controller),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── LISTA ──
          Expanded(
            child: state.carregando
                ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                : state.descontos.isEmpty
                ? _emptyState(context)
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: state.descontos.length,
              itemBuilder: (_, i) => _descontoCard(
                  context, state.descontos[i], controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboard(BuildContext context, DescontoController controller) {
    final resumo = controller.state.resumo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _dashCard(context, "LÍQUIDO TOTAL", "R\$ ${formatar(resumo?.totalLiquido ?? 0)}",
              const Color(0xFF66BB6A), Icons.account_balance_wallet_outlined, wide: true),
          const SizedBox(width: 10),
          _dashCard(context, "TÍTULOS", "${resumo?.ativos ?? 0}",
              const Color(0xFF4FC3F7), Icons.description_outlined),
        ],
      ),
    );
  }

  Widget _dashCard(BuildContext context, String titulo, String valor, Color cor, IconData icon, {bool wide = false}) {
    return Expanded(
      flex: wide ? 2 : 1,
      child: Container(
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
                Icon(icon, size: 12, color: cor),
                const SizedBox(width: 5),
                Text(titulo, style: TextStyle(color: cor, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 6),
            Text(valor, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: wide ? 15 : 13, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _descontoCard(BuildContext context, DescontoModel d, DescontoController controller) {
    final theme = Theme.of(context);
    final corStatus = d.status == DescontoStatus.ativo ? const Color(0xFF66BB6A) : const Color(0xFFEF6C00);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: corStatus.withOpacity(0.05),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Icon(d.tipo == TipoTitulo.cheque ? Icons.fact_check_outlined : Icons.description_outlined,
                    size: 16, color: theme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(d.titulo.toUpperCase(),
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: corStatus.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(d.status.name.toUpperCase(),
                      style: TextStyle(color: corStatus, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoItem(context, "VALOR BRUTO", "R\$ ${formatar(d.valorNominal)}", isDim: true),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: theme.dividerColor),
                    _infoItem(context, "VALOR LÍQUIDO", "R\$ ${formatar(d.valorLiquido)}", color: const Color(0xFF66BB6A), isBold: true),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      child: Text(d.iniciaisCliente, style: TextStyle(fontSize: 8, color: theme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(d.nomeCliente, style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                    const Spacer(),
                    Text("Venc. ${_formatData(d.validade)}", style: TextStyle(fontSize: 11, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(BuildContext context, String label, String value, {Color? color, bool isDim = false, bool isBold = false}) {
    final theme = Theme.of(context);
    final baseColor = color ?? theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(
          color: isDim ? baseColor.withOpacity(0.4) : baseColor,
          fontSize: isBold ? 17 : 14,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          decoration: isDim ? TextDecoration.lineThrough : null,
        )),
      ],
    );
  }

  Widget _statusChip(BuildContext context, String label, DescontoStatus? status, DescontoController c) {
    final selected = c.state.filtroAtivo == status;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => c.aplicarFiltro(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? theme.primaryColor : theme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.discount_outlined, color: Theme.of(context).dividerColor, size: 60),
          const SizedBox(height: 12),
          const Text("Nenhum desconto encontrado", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
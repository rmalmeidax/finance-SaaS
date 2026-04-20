import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/clientes_controller.dart';
import '../../model/clientes_model.dart';
import '../../widgets/dashboard_resumo_card_widget.dart';
import '../../widgets/custom_input_widget.dart';

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

  static String fmtData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class ClienteScreen extends StatelessWidget {
  const ClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ClienteController>(context);
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
              decoration: BoxDecoration(
                color: _T.teal,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "CLIENTES",
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
                borderRadius: BorderRadius.circular(14),
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
                  hintText: "Buscar por nome, fantasia ou documento...",
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

          // ── FILTROS TIPO ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _chip(context, "Todos", controller.filtroTipo == FiltroTipoCliente.todos,
                        () => controller.setFiltroTipo(FiltroTipoCliente.todos)),
                const SizedBox(width: 8),
                _chip(context, "Pessoa Jurídica",
                    controller.filtroTipo == FiltroTipoCliente.pj,
                        () => controller.setFiltroTipo(FiltroTipoCliente.pj)),
                const SizedBox(width: 8),
                _chip(context, "Pessoa Física",
                    controller.filtroTipo == FiltroTipoCliente.pf,
                        () => controller.setFiltroTipo(FiltroTipoCliente.pf)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── FILTROS STATUS ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _chipColor(
                  context,
                  "Ativo",
                  controller.filtroStatus == FiltroStatusCliente.ativo,
                  _T.green,
                      () =>
                      controller.setFiltroStatus(FiltroStatusCliente.ativo),
                ),
                const SizedBox(width: 8),
                _chipColor(
                  context,
                  "Inativo",
                  controller.filtroStatus == FiltroStatusCliente.inativo,
                  _T.red,
                      () => controller
                      .setFiltroStatus(FiltroStatusCliente.inativo),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── LISTA ──
          Expanded(
            child: controller.clientes.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.12),
                              size: 60),
                          const SizedBox(height: 12),
                          Text(
                            "Nenhum cliente encontrado",
                            style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                                fontSize: 14,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: controller.clientes.length,
                    itemBuilder: (_, i) => _clienteCard(context, controller.clientes[i], controller),
                  ),
          ),
        ],
      ),
    );
  }

  // ── DASHBOARD (Responsive Grid) ──
  Widget _dashboard(BuildContext context, ClienteController controller) {
    final total = controller.clientes.length;
    final ativos =
        controller.clientes.where((c) => c.status == 'Ativo').length;
    final pj = controller.clientes
        .where((c) => c.tipoPessoa == TipoPessoaCliente.juridica)
        .length;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: isMobile
            ? Column(
                children: [
                  DashboardResumoCardWidget(title: "TOTAL", value: "$total", color: _T.teal, icon: Icons.people_outline),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: DashboardResumoCardWidget(title: "ATIVOS", value: "$ativos", color: _T.green, icon: Icons.check_circle_outline)),
                      const SizedBox(width: 10),
                      Expanded(child: DashboardResumoCardWidget(title: "PJ", value: "$pj", color: _T.blue, icon: Icons.business_outlined)),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: DashboardResumoCardWidget(title: "TOTAL", value: "$total", color: _T.teal, icon: Icons.people_outline)),
                  const SizedBox(width: 10),
                  Expanded(child: DashboardResumoCardWidget(title: "ATIVOS", value: "$ativos", color: _T.green, icon: Icons.check_circle_outline)),
                  const SizedBox(width: 10),
                  Expanded(child: DashboardResumoCardWidget(title: "PJ", value: "$pj", color: _T.blue, icon: Icons.business_outlined)),
                ],
              ),
      );
    });
  }

  // ── CARD ──
  Widget _clienteCard(
      BuildContext context, Cliente c, ClienteController controller) {
    final theme = Theme.of(context);
    final isPj = c.tipoPessoa == TipoPessoaCliente.juridica;
    final isAtivo = c.status == 'Ativo';
    final statusColor = isAtivo ? _T.green : _T.red;
    final tipoColor = isPj ? _T.blue : _T.orange;

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
          // Header (Standardized)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      c.nome.isNotEmpty ? c.nome[0].toUpperCase() : '?',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nome.toUpperCase(),
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (c.fantasia.isNotEmpty)
                        Text(c.fantasia,
                            style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                                fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tipoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: tipoColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(isPj ? "PJ" : "PF",
                      style: TextStyle(
                          color: tipoColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(c.status.toUpperCase(),
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
            child: LayoutBuilder(builder: (context, cardConstraints) {
              final isSmall = cardConstraints.maxWidth < 400;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoItem(context, Icons.badge_outlined, isPj ? "CNPJ" : "CPF", c.documento),
                      const SizedBox(width: 8),
                      _infoItem(context, Icons.phone_outlined, "Telefone", c.telefone.isEmpty ? '—' : c.telefone),
                      if (!isSmall) ...[
                        const SizedBox(width: 8),
                        _infoItem(context, Icons.email_outlined, "E-mail", c.email.isEmpty ? '—' : c.email),
                      ],
                    ],
                  ),
                  if (isSmall) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _infoItem(context, Icons.email_outlined, "E-mail", c.email.isEmpty ? '—' : c.email),
                      ],
                    ),
                  ],
                  if (c.cidade.isNotEmpty || c.estado.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoItem(context, Icons.location_on_outlined, "Cidade / UF",
                            "${c.cidade}${c.estado.isNotEmpty ? ' - ${c.estado}' : ''}"),
                        const SizedBox(width: 8),
                        _infoItem(context, Icons.map_outlined, "Bairro", c.bairro.isEmpty ? '—' : c.bairro),
                        if (!isSmall) ...[
                          const SizedBox(width: 8),
                          _infoItem(context, Icons.markunread_mailbox_outlined, "CEP", c.cep.isEmpty ? '—' : c.cep),
                        ],
                      ],
                    ),
                    if (isSmall) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _infoItem(context, Icons.markunread_mailbox_outlined, "CEP", c.cep.isEmpty ? '—' : c.cep),
                        ],
                      ),
                    ],
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _actionButton(
                        icon: Icons.edit_outlined,
                        tooltip: "Editar",
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        iconColor: theme.primaryColor,
                        onTap: () => _showDialog(context, controller, cliente: c),
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: isAtivo ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
                        tooltip: isAtivo ? "Inativar" : "Ativar",
                        color: isAtivo ? _T.red.withValues(alpha: 0.1) : _T.green.withValues(alpha: 0.1),
                        iconColor: isAtivo ? _T.red : _T.green,
                        onTap: () async => await controller.alterarStatus(c.id, isAtivo ? 'Inativo' : 'Ativo'),
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        icon: Icons.delete_outline,
                        tooltip: "Excluir",
                        color: _T.red.withValues(alpha: 0.1),
                        iconColor: _T.red,
                        onTap: () => _confirmDelete(context, c, controller),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isMonospace = label == "CNPJ" || label == "CPF" || label == "Telefone" || label == "CEP";
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: theme.primaryColor),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
                      fontSize: 9,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
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

  Widget _chip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
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
                color: selected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.3)),
      ),
    );
  }

  Widget _chipColor(
      BuildContext context, String label, bool selected, Color cor, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cor : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? cor : theme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

  // ── CONFIRM DELETE ──
  void _confirmDelete(
      BuildContext context, Cliente c, ClienteController controller) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: _T.red, size: 40),
              const SizedBox(height: 12),
              Text("Excluir Cliente",
                  style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text("Tem certeza que deseja excluir ${c.nome}?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.dividerColor),
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
                    child: GestureDetector(
                      onTap: () async {
                        await controller.excluir(c.id);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _T.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text("EXCLUIR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5)),
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
  void _showDialog(BuildContext context, ClienteController controller,
      {Cliente? cliente}) {
    final theme = Theme.of(context);
    final docCtrl = TextEditingController(text: cliente?.documento ?? '');
    final nomeCtrl = TextEditingController(text: cliente?.nome ?? '');
    final fantasiaCtrl = TextEditingController(text: cliente?.fantasia ?? '');
    final logradouroCtrl = TextEditingController(text: cliente?.logradouro ?? '');
    final numeroCtrl = TextEditingController(text: cliente?.numero ?? '');
    final complementoCtrl = TextEditingController(text: cliente?.complemento ?? '');
    final bairroCtrl = TextEditingController(text: cliente?.bairro ?? '');
    final cidadeCtrl = TextEditingController(text: cliente?.cidade ?? '');
    final estadoCtrl = TextEditingController(text: cliente?.estado ?? '');
    final cepCtrl = TextEditingController(text: cliente?.cep ?? '');
    final telefoneCtrl = TextEditingController(text: cliente?.telefone ?? '');
    final emailCtrl = TextEditingController(text: cliente?.email ?? '');

    TipoPessoaCliente tipo = cliente?.tipoPessoa ?? TipoPessoaCliente.juridica;
    bool buscando = false;
    String? erroCnpj;
    bool dadosCarregados = cliente != null;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: StatefulBuilder(builder: (context, setState) {
          Future<void> buscarCnpj() async {
            setState(() { buscando = true; erroCnpj = null; });
            final data = await controller.buscarCnpj(docCtrl.text);
            setState(() { buscando = false; });
            if (data == null) {
              setState(() => erroCnpj = 'CNPJ não encontrado ou inválido.');
              return;
            }
            nomeCtrl.text = data['razao_social'] ?? '';
            fantasiaCtrl.text = data['nome_fantasia'] ?? '';
            telefoneCtrl.text = data['ddd_telefone_1'] ?? '';
            emailCtrl.text = data['email'] ?? '';
            cepCtrl.text = data['cep'] ?? '';
            logradouroCtrl.text = data['logradouro'] ?? '';
            numeroCtrl.text = data['numero'] ?? '';
            complementoCtrl.text = data['complemento'] ?? '';
            bairroCtrl.text = data['bairro'] ?? '';
            cidadeCtrl.text = data['municipio'] ?? '';
            estadoCtrl.text = data['uf'] ?? '';
            setState(() => dadosCarregados = true);
          }

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
                    border: Border(bottom: BorderSide(color: theme.dividerColor)),
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
                        cliente == null ? "NOVO CLIENTE" : "EDITAR CLIENTE",
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

                // Corpo
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _labelSection(context, "TIPO DE PESSOA"),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  tipo = TipoPessoaCliente.juridica;
                                  dadosCarregados = false;
                                  erroCnpj = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: tipo == TipoPessoaCliente.juridica ? theme.primaryColor : theme.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: tipo == TipoPessoaCliente.juridica ? theme.primaryColor : theme.dividerColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.business,
                                          size: 16,
                                          color: tipo == TipoPessoaCliente.juridica ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Pessoa Jurídica",
                                        style: TextStyle(
                                            color: tipo == TipoPessoaCliente.juridica ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  tipo = TipoPessoaCliente.fisica;
                                  dadosCarregados = false;
                                  erroCnpj = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: tipo == TipoPessoaCliente.fisica ? _T.orange : theme.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: tipo == TipoPessoaCliente.fisica ? _T.orange : theme.dividerColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person,
                                          size: 16,
                                          color: tipo == TipoPessoaCliente.fisica ? Colors.white : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Pessoa Física",
                                        style: TextStyle(
                                            color: tipo == TipoPessoaCliente.fisica ? Colors.white : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _labelSection(context, tipo == TipoPessoaCliente.juridica ? "CNPJ" : "CPF"),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: CustomInputWidget(
                                controller: docCtrl,
                                label: tipo == TipoPessoaCliente.juridica ? "CNPJ" : "CPF",
                                hint: tipo == TipoPessoaCliente.juridica ? "Digite o CNPJ" : "Digite o CPF",
                                icon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            if (tipo == TipoPessoaCliente.juridica) ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: buscando ? null : buscarCnpj,
                                child: Container(
                                  height: 52,
                                  width: 52,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: buscando
                                      ? Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                                  )
                                      : Icon(Icons.search, color: theme.colorScheme.onPrimary, size: 20),
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (erroCnpj != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _T.red.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _T.red.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: _T.red, size: 14),
                                const SizedBox(width: 8),
                                Text(erroCnpj!, style: const TextStyle(color: _T.red, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],

                        if (tipo == TipoPessoaCliente.juridica && !dadosCarregados) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: theme.primaryColor, size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Digite o CNPJ e clique em 🔍 para buscar os dados na Receita Federal automaticamente.",
                                    style: TextStyle(color: theme.primaryColor, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (tipo == TipoPessoaCliente.fisica || dadosCarregados) ...[
                          const SizedBox(height: 20),
                          _labelSection(context, "INFORMAÇÕES GERAIS"),
                          const SizedBox(height: 10),
                          CustomInputWidget(
                              controller: nomeCtrl,
                              label: tipo == TipoPessoaCliente.juridica ? "Razão Social" : "Nome Completo",
                              icon: Icons.person_outline),
                          if (tipo == TipoPessoaCliente.juridica) ...[
                            const SizedBox(height: 10),
                            CustomInputWidget(controller: fantasiaCtrl, label: "Nome Fantasia", icon: Icons.storefront_outlined),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInputWidget(controller: telefoneCtrl, label: "Telefone", icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomInputWidget(controller: emailCtrl, label: "E-mail", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          _labelSection(context, "ENDEREÇO"),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CustomInputWidget(controller: cepCtrl, label: "CEP", icon: Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: CustomInputWidget(controller: logradouroCtrl, label: "Logradouro", icon: Icons.signpost_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInputWidget(controller: numeroCtrl, label: "Número", icon: Icons.tag),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: CustomInputWidget(controller: complementoCtrl, label: "Complemento", icon: Icons.home_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: CustomInputWidget(controller: bairroCtrl, label: "Bairro", icon: Icons.map_outlined),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: CustomInputWidget(controller: cidadeCtrl, label: "Cidade", icon: Icons.location_city_outlined),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                child: CustomInputWidget(controller: estadoCtrl, label: "UF", icon: Icons.flag_outlined),
                              ),
                            ],
                          ),
                        ],
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
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: theme.dividerColor),
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
                            final novo = Cliente(
                              id: cliente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              tipoPessoa: tipo,
                              nome: nomeCtrl.text,
                              fantasia: fantasiaCtrl.text,
                              documento: docCtrl.text,
                              logradouro: logradouroCtrl.text,
                              numero: numeroCtrl.text,
                              complemento: complementoCtrl.text,
                              bairro: bairroCtrl.text,
                              cidade: cidadeCtrl.text,
                              estado: estadoCtrl.text,
                              cep: cepCtrl.text,
                              telefone: telefoneCtrl.text,
                              email: emailCtrl.text,
                              status: cliente?.status ?? 'Ativo',
                            );
                            await controller.salvar(novo);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              cliente == null ? "SALVAR CLIENTE" : "ATUALIZAR",
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
        Text(label,
            style: TextStyle(
                color: theme.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5)),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/clientes_controller.dart';
import '../../model/clientes_model.dart';
import '../../widgets/theme_toggle_button.dart';



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
              "CLIENTES",
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontFamily: 'serif',
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
              icon: Icon(Icons.add, color: theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TextField(
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Buscar por nome, fantasia ou documento...",
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
                  const Color(0xFF4CAF50),
                      () =>
                      controller.setFiltroStatus(FiltroStatusCliente.ativo),
                ),
                const SizedBox(width: 8),
                _chipColor(
                  context,
                  "Inativo",
                  controller.filtroStatus == FiltroStatusCliente.inativo,
                  const Color(0xFFE53935),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.12), size: 60),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhum cliente encontrado",
                    style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                        fontSize: 14,
                        letterSpacing: 1),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: controller.clientes.length,
              itemBuilder: (_, i) => _clienteCard(
                  context, controller.clientes[i], controller),
            ),
          ),
        ],
      ),
    );
  }

  // ── DASHBOARD ──
  Widget _dashboard(BuildContext context, ClienteController controller) {
    final theme = Theme.of(context);
    final total = controller.clientes.length;
    final ativos =
        controller.clientes.where((c) => c.status == 'Ativo').length;
    final pj = controller.clientes
        .where((c) => c.tipoPessoa == TipoPessoaCliente.juridica)
        .length;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 500;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: isMobile
            ? Column(
                children: [
                  _dashCard(context, "TOTAL", "$total", theme.primaryColor, Icons.people_outline, isFullWidth: true),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _dashCard(context, "ATIVOS", "$ativos", const Color(0xFF4CAF50), Icons.check_circle_outline),
                      const SizedBox(width: 10),
                      _dashCard(context, "PJ", "$pj", const Color(0xFF4FC3F7), Icons.business_outlined),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  _dashCard(context, "TOTAL", "$total", theme.primaryColor, Icons.people_outline),
                  const SizedBox(width: 10),
                  _dashCard(context, "ATIVOS", "$ativos", const Color(0xFF4CAF50), Icons.check_circle_outline),
                  const SizedBox(width: 10),
                  _dashCard(context, "PJ", "$pj", const Color(0xFF4FC3F7), Icons.business_outlined),
                ],
              ),
      );
    });
  }

  Widget _dashCard(BuildContext context, String titulo, String valor, Color cor, IconData icon, {bool isFullWidth = false}) {
    final theme = Theme.of(context);
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.05),
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
              Text(titulo,
                  style: TextStyle(
                      color: cor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5)),
          ],
        ),
        const SizedBox(height: 6),
        Text(valor,
            style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
      ],
    ),
  );

  return isFullWidth ? card : Expanded(child: card);
}

  // ── CARD ──
  Widget _clienteCard(
      BuildContext context, Cliente c, ClienteController controller) {
    final theme = Theme.of(context);
    final isPj = c.tipoPessoa == TipoPessoaCliente.juridica;
    final isAtivo = c.status == 'Ativo';
    final statusColor =
    isAtivo ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final tipoColor =
    isPj ? const Color(0xFF4FC3F7) : const Color(0xFFFFB74D);

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
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                  bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.12),
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
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                                fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tipoColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: tipoColor.withOpacity(0.3)),
                  ),
                  child: Text(isPj ? "PJ" : "PF",
                      style: TextStyle(
                          color: tipoColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
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
            child: Column(
              children: [
                Row(
                  children: [
                    _infoItem(context, Icons.badge_outlined, isPj ? "CNPJ" : "CPF",
                        c.documento),
                    _infoItem(context, Icons.phone_outlined, "Telefone",
                        c.telefone.isEmpty ? '—' : c.telefone),
                    _infoItem(context, Icons.email_outlined, "E-mail",
                        c.email.isEmpty ? '—' : c.email),
                  ],
                ),
                if (c.cidade.isNotEmpty || c.estado.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoItem(
                          context,
                          Icons.location_on_outlined,
                          "Cidade / UF",
                          "${c.cidade}${c.estado.isNotEmpty ? ' - ${c.estado}' : ''}"),
                      _infoItem(context, Icons.map_outlined, "Bairro",
                          c.bairro.isEmpty ? '—' : c.bairro),
                      _infoItem(context, Icons.markunread_mailbox_outlined, "CEP",
                          c.cep.isEmpty ? '—' : c.cep),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionButton(
                      icon: Icons.edit_outlined,
                      tooltip: "Editar",
                      color: theme.primaryColor.withOpacity(0.1),
                      iconColor: theme.primaryColor,
                      onTap: () =>
                          _showDialog(context, controller, cliente: c),
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      icon: isAtivo
                          ? Icons.toggle_on_outlined
                          : Icons.toggle_off_outlined,
                      tooltip: isAtivo ? "Inativar" : "Ativar",
                      color: isAtivo
                          ? const Color(0xFFE53935).withOpacity(0.1)
                          : const Color(0xFF4CAF50).withOpacity(0.1),
                      iconColor: isAtivo
                          ? const Color(0xFFE53935)
                          : const Color(0xFF4CAF50),
                      onTap: () async => await controller.alterarStatus(
                          c.id, isAtivo ? 'Inativo' : 'Ativo'),
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      icon: Icons.delete_outline,
                      tooltip: "Excluir",
                      color: Colors.red.withOpacity(0.1),
                      iconColor: Colors.red,
                      onTap: () => _confirmDelete(context, c, controller),
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
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.35),
                      fontSize: 9,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 12),
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
            border: Border.all(color: iconColor.withOpacity(0.2)),
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
          color:
          selected ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? theme.primaryColor
                  : theme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? (theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : theme.textTheme.bodyMedium?.color?.withOpacity(0.54),
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400,
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
          border: Border.all(
              color: selected ? cor : theme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : theme.textTheme.bodyMedium?.color?.withOpacity(0.54),
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400)),
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
        backgroundColor: theme.scaffoldBackgroundColor,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFE53935), size: 40),
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
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 13)),
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
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: theme.dividerColor),
                        ),
                        child: Text("CANCELAR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.54),
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
                        await controller.excluir(c.id);
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
  void _showDialog(BuildContext context, ClienteController controller,
      {Cliente? cliente}) {
    final theme = Theme.of(context);
    final docCtrl =
    TextEditingController(text: cliente?.documento ?? '');
    final nomeCtrl = TextEditingController(text: cliente?.nome ?? '');
    final fantasiaCtrl =
    TextEditingController(text: cliente?.fantasia ?? '');
    final logradouroCtrl =
    TextEditingController(text: cliente?.logradouro ?? '');
    final numeroCtrl =
    TextEditingController(text: cliente?.numero ?? '');
    final complementoCtrl =
    TextEditingController(text: cliente?.complemento ?? '');
    final bairroCtrl =
    TextEditingController(text: cliente?.bairro ?? '');
    final cidadeCtrl =
    TextEditingController(text: cliente?.cidade ?? '');
    final estadoCtrl =
    TextEditingController(text: cliente?.estado ?? '');
    final cepCtrl = TextEditingController(text: cliente?.cep ?? '');
    final telefoneCtrl =
    TextEditingController(text: cliente?.telefone ?? '');
    final emailCtrl =
    TextEditingController(text: cliente?.email ?? '');

    TipoPessoaCliente tipo =
        cliente?.tipoPessoa ?? TipoPessoaCliente.juridica;
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
              setState(() =>
              erroCnpj = 'CNPJ não encontrado ou inválido.');
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
                        height: 18,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cliente == null
                            ? "NOVO CLIENTE"
                            : "EDITAR CLIENTE",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                            size: 20),
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
                                  duration:
                                  const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color: tipo ==
                                        TipoPessoaCliente.juridica
                                        ? theme.primaryColor
                                        : theme.scaffoldBackgroundColor,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                      color: tipo ==
                                          TipoPessoaCliente.juridica
                                          ? theme.primaryColor
                                          : theme.dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.business,
                                          size: 16,
                                          color: tipo ==
                                              TipoPessoaCliente
                                                  .juridica
                                              ? (theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                                              : theme.textTheme.bodyMedium?.color?.withOpacity(0.54)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Pessoa Jurídica",
                                        style: TextStyle(
                                            color: tipo ==
                                                TipoPessoaCliente
                                                    .juridica
                                                ? (theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                                                : theme.textTheme.bodyMedium?.color?.withOpacity(0.54),
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
                                  duration:
                                  const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                    tipo == TipoPessoaCliente.fisica
                                        ? const Color(0xFFFFB74D)
                                        : theme.scaffoldBackgroundColor,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                      color: tipo ==
                                          TipoPessoaCliente.fisica
                                          ? const Color(0xFFFFB74D)
                                          : theme.dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person,
                                          size: 16,
                                          color: tipo ==
                                              TipoPessoaCliente
                                                  .fisica
                                              ? Colors.white
                                              : theme.textTheme.bodyMedium?.color?.withOpacity(0.54)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Pessoa Física",
                                        style: TextStyle(
                                            color: tipo ==
                                                TipoPessoaCliente
                                                    .fisica
                                                ? Colors.white
                                                : theme.textTheme.bodyMedium?.color?.withOpacity(0.54),
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
                        _labelSection(context, tipo == TipoPessoaCliente.juridica
                            ? "CNPJ"
                            : "CPF"),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _inputField(
                                context,
                                docCtrl,
                                tipo == TipoPessoaCliente.juridica
                                    ? "Digite o CNPJ"
                                    : "Digite o CPF",
                                Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            if (tipo == TipoPessoaCliente.juridica) ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: buscando ? null : buscarCnpj,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: buscando
                                      ? Padding(
                                    padding: const EdgeInsets.all(13),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                                  )
                                      : Icon(Icons.search,
                                      color: theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (erroCnpj != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A0D0D),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFE53935)
                                      .withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Color(0xFFE53935), size: 14),
                                const SizedBox(width: 8),
                                Text(erroCnpj!,
                                    style: const TextStyle(
                                        color: Color(0xFFE53935),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],

                        if (tipo == TipoPessoaCliente.juridica &&
                            !dadosCarregados) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: theme.primaryColor
                                      .withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: theme.primaryColor, size: 14),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Digite o CNPJ e clique em 🔍 para buscar os dados na Receita Federal automaticamente.",
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (tipo == TipoPessoaCliente.fisica ||
                            dadosCarregados) ...[
                          const SizedBox(height: 20),
                          _labelSection(context, "INFORMAÇÕES GERAIS"),
                          const SizedBox(height: 10),
                          _inputField(
                              context,
                              nomeCtrl,
                              tipo == TipoPessoaCliente.juridica
                                  ? "Razão Social"
                                  : "Nome Completo",
                              Icons.person_outline),
                          if (tipo == TipoPessoaCliente.juridica) ...[
                            const SizedBox(height: 10),
                            _inputField(context, fantasiaCtrl, "Nome Fantasia",
                                Icons.storefront_outlined),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(context, telefoneCtrl, "Telefone",
                                    Icons.phone_outlined,
                                    keyboardType: TextInputType.phone),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _inputField(context, emailCtrl, "E-mail",
                                    Icons.email_outlined,
                                    keyboardType:
                                    TextInputType.emailAddress),
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
                                child: _inputField(context, cepCtrl, "CEP",
                                    Icons.markunread_mailbox_outlined,
                                    keyboardType: TextInputType.number),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: _inputField(context, logradouroCtrl,
                                    "Logradouro",
                                    Icons.signpost_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(
                                    context, numeroCtrl, "Número", Icons.tag),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _inputField(context, complementoCtrl,
                                    "Complemento", Icons.home_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(context, bairroCtrl, "Bairro",
                                    Icons.map_outlined),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _inputField(context, cidadeCtrl, "Cidade",
                                    Icons.location_city_outlined),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 60,
                                child: _inputField(context, estadoCtrl, "UF",
                                    Icons.flag_outlined),
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
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: theme.dividerColor),
                            ),
                            child: Text("CANCELAR",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.54),
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
                              id: cliente?.id ??
                                  DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
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
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              cliente == null
                                  ? "SALVAR CLIENTE"
                                  : "ATUALIZAR",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
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
          width: 2,
          height: 12,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: theme.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2)),
      ],
    );
  }

  Widget _inputField(
      BuildContext context,
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.35), fontSize: 12),
          prefixIcon:
          Icon(icon, size: 16, color: theme.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}
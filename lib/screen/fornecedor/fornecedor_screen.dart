import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/fornecedor_controller.dart';
import '../../model/fornecedor_model.dart';

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
}

class FornecedorScreen extends StatelessWidget {
  const FornecedorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FornecedorController>(context);
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
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6), size: 18),
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
              "FORNECEDORES",
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
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
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
                  hintText: "Buscar por nome, fantasia ou documento...",
                  hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                      fontSize: 14),
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

          // ── FILTROS ──
          // Tipo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _chip(context, "Todos", controller.filtroTipo == FiltroTipo.todos,
                        () => controller.setFiltroTipo(FiltroTipo.todos)),
                const SizedBox(width: 8),
                _chip(context, "Pessoa Jurídica",
                    controller.filtroTipo == FiltroTipo.pj,
                        () => controller.setFiltroTipo(FiltroTipo.pj)),
                const SizedBox(width: 8),
                _chip(context, "Pessoa Física",
                    controller.filtroTipo == FiltroTipo.pf,
                        () => controller.setFiltroTipo(FiltroTipo.pf)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _chipColor(
                  context,
                  "Ativo",
                  controller.filtroStatus == FiltroStatusF.ativo,
                  _T.green,
                      () => controller.setFiltroStatus(FiltroStatusF.ativo),
                ),
                const SizedBox(width: 8),
                _chipColor(
                  context,
                  "Inativo",
                  controller.filtroStatus == FiltroStatusF.inativo,
                  _T.red,
                      () => controller.setFiltroStatus(FiltroStatusF.inativo),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── LISTA ──
          Expanded(
            child: controller.fornecedores.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business_outlined,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.12),
                      size: 60),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhum fornecedor encontrado",
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
              itemCount: controller.fornecedores.length,
              itemBuilder: (_, i) {
                return _fornecedorCard(
                    context, controller.fornecedores[i], controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── DASHBOARD ──
  Widget _dashboard(BuildContext context, FornecedorController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = controller.fornecedores.length;
        final ativos =
            controller.fornecedores.where((f) => f.status == 'Ativo').length;
        final pj = controller.fornecedores
            .where((f) => f.tipoPessoa == TipoPessoa.juridica)
            .length;

        final isMobile = constraints.maxWidth < 600;

        final cards = [
          _dashCard(context, "TOTAL", "$total", Theme.of(context).primaryColor,
              Icons.people_outline, wide: !isMobile),
          _dashCard(
              context, "ATIVOS", "$ativos", _T.green, Icons.check_circle_outline),
          _dashCard(context, "PJ", "$pj", const Color(0xFF4FC3F7),
              Icons.business_outlined),
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

  Widget _dashCard(BuildContext context, String titulo, String valor, Color cor, IconData icon, {bool wide = false}) {
    final theme = Theme.of(context);
    return Expanded(
      flex: wide ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: cor.withValues(alpha: 0.03),
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
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(icon, size: 12, color: cor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(titulo,
                      style: TextStyle(
                          color: cor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(valor,
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: wide ? 22 : 18,
                    fontFamily: _T.mono,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  // ── CARD ──
  Widget _fornecedorCard(BuildContext context, Fornecedor f,
      FornecedorController controller) {
    final theme = Theme.of(context);
    final isPj = f.tipoPessoa == TipoPessoa.juridica;
    final isAtivo = f.status == 'Ativo';
    final statusColor = isAtivo ? _T.green : _T.red;
    final tipoColor = isPj ? const Color(0xFF4FC3F7) : _T.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                  bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      f.nome.isNotEmpty ? f.nome[0].toUpperCase() : '?',
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
                        f.nome.toUpperCase(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (f.fantasia.isNotEmpty)
                        Text(f.fantasia,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                fontSize: 11)),
                    ],
                  ),
                ),
                // Badges
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tipoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: tipoColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    isPj ? "PJ" : "PF",
                    style: TextStyle(
                        color: tipoColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    f.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
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
                    _infoItem(
                        context,
                        Icons.badge_outlined,
                        isPj ? "CNPJ" : "CPF",
                        f.documento),
                    _infoItem(context, Icons.phone_outlined, "Telefone",
                        f.telefone.isEmpty ? '—' : f.telefone),
                    _infoItem(context, Icons.email_outlined, "E-mail",
                        f.email.isEmpty ? '—' : f.email),
                  ],
                ),
                if (f.cidade.isNotEmpty || f.estado.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoItem(
                          context,
                          Icons.location_on_outlined,
                          "Cidade / UF",
                          "${f.cidade}${f.estado.isNotEmpty ? ' - ${f.estado}' : ''}"),
                      _infoItem(context, Icons.map_outlined, "Bairro",
                          f.bairro.isEmpty ? '—' : f.bairro),
                      _infoItem(context, Icons.markunread_mailbox_outlined, "CEP",
                          f.cep.isEmpty ? '—' : f.cep),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                // Ações
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionButton(
                      context: context,
                      icon: Icons.edit_outlined,
                      tooltip: "Editar",
                      iconColor: _T.blue,
                      onTap: () =>
                          _showDialog(context, controller, fornecedor: f),
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      context: context,
                      icon: isAtivo
                          ? Icons.toggle_on_outlined
                          : Icons.toggle_off_outlined,
                      tooltip: isAtivo ? "Inativar" : "Ativar",
                      iconColor: statusColor,
                      onTap: () async {
                        await controller.alterarStatus(
                            f.id, isAtivo ? 'Inativo' : 'Ativo');
                      },
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      context: context,
                      icon: Icons.delete_outline,
                      tooltip: "Excluir",
                      iconColor: _T.red,
                      onTap: () => _confirmDelete(context, f, controller),
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
                  fontFamily: _T.mono),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
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
          border: Border.all(
              color: selected ? theme.primaryColor : theme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
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
                color: selected ? Colors.white : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

  // ── CONFIRM DELETE ──
  void _confirmDelete(BuildContext context, Fornecedor f,
      FornecedorController controller) {
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
              const Icon(Icons.warning_amber_rounded,
                  color: _T.red, size: 40),
              const SizedBox(height: 12),
              Text("Excluir Fornecedor",
                  style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text("Tem certeza que deseja excluir ${f.nome}?",
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
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
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
                        await controller.excluir(f.id);
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

  // ── DIALOG CADASTRO ──
  void _showDialog(BuildContext context, FornecedorController controller,
      {Fornecedor? fornecedor}) {
    final theme = Theme.of(context);
    final docCtrl = TextEditingController(text: fornecedor?.documento ?? '');
    final nomeCtrl = TextEditingController(text: fornecedor?.nome ?? '');
    final fantasiaCtrl = TextEditingController(text: fornecedor?.fantasia ?? '');
    final logradouroCtrl = TextEditingController(text: fornecedor?.logradouro ?? '');
    final numeroCtrl = TextEditingController(text: fornecedor?.numero ?? '');
    final complementoCtrl = TextEditingController(text: fornecedor?.complemento ?? '');
    final bairroCtrl = TextEditingController(text: fornecedor?.bairro ?? '');
    final cidadeCtrl = TextEditingController(text: fornecedor?.cidade ?? '');
    final estadoCtrl = TextEditingController(text: fornecedor?.estado ?? '');
    final cepCtrl = TextEditingController(text: fornecedor?.cep ?? '');
    final telefoneCtrl = TextEditingController(text: fornecedor?.telefone ?? '');
    final emailCtrl = TextEditingController(text: fornecedor?.email ?? '');

    TipoPessoa tipo = fornecedor?.tipoPessoa ?? TipoPessoa.juridica;
    bool buscando = false;
    String? erroCnpj;
    bool dadosCarregados = fornecedor != null;

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
                // ── Header ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _T.teal,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        fornecedor == null ? "NOVO FORNECEDOR" : "EDITAR FORNECEDOR",
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
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4), size: 20),
                      ),
                    ],
                  ),
                ),

                // ── Corpo ──
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
                                  tipo = TipoPessoa.juridica;
                                  dadosCarregados = false;
                                  erroCnpj = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: tipo == TipoPessoa.juridica ? theme.primaryColor : theme.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: tipo == TipoPessoa.juridica ? theme.primaryColor : theme.dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.business,
                                          size: 16,
                                          color: tipo == TipoPessoa.juridica ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Pessoa Jurídica",
                                        style: TextStyle(
                                            color: tipo == TipoPessoa.juridica ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
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
                                  tipo = TipoPessoa.fisica;
                                  dadosCarregados = false;
                                  erroCnpj = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: tipo == TipoPessoa.fisica ? _T.orange : theme.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: tipo == TipoPessoa.fisica ? _T.orange : theme.dividerColor,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person,
                                          size: 16,
                                          color: tipo == TipoPessoa.fisica ? Colors.white : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54)),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Pessoa Física",
                                        style: TextStyle(
                                            color: tipo == TipoPessoa.fisica ? Colors.white : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
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
                        _labelSection(context, tipo == TipoPessoa.juridica ? "CNPJ" : "CPF"),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _inputField(
                                context,
                                docCtrl,
                                tipo == TipoPessoa.juridica ? "Digite o CNPJ" : "Digite o CPF",
                                Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            if (tipo == TipoPessoa.juridica) ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: buscando ? null : buscarCnpj,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: buscando
                                      ? Padding(
                                    padding: const EdgeInsets.all(13),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.onPrimary),
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
                              color: _T.red.withValues(alpha: 0.1),
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

                        if (tipo == TipoPessoa.juridica && !dadosCarregados) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF4FC3F7).withValues(alpha: 0.2)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Color(0xFF4FC3F7), size: 14),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Digite o CNPJ e clique em 🔍 para buscar os dados na Receita Federal automaticamente.",
                                    style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (tipo == TipoPessoa.fisica || dadosCarregados) ...[
                          const SizedBox(height: 20),
                          _labelSection(context, "INFORMAÇÕES GERAIS"),
                          const SizedBox(height: 10),
                          _inputField(context, nomeCtrl,
                              tipo == TipoPessoa.juridica ? "Razão Social" : "Nome Completo",
                              Icons.person_outline),
                          if (tipo == TipoPessoa.juridica) ...[
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
                                    keyboardType: TextInputType.emailAddress),
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
                                    "Logradouro", Icons.signpost_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(context, numeroCtrl, "Número", Icons.tag),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _inputField(context, complementoCtrl, "Complemento", Icons.home_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(context, bairroCtrl, "Bairro", Icons.map_outlined),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _inputField(context, cidadeCtrl, "Cidade", Icons.location_city_outlined),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 60,
                                child: _inputField(context, estadoCtrl, "UF", Icons.flag_outlined),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Footer ──
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
                            final novo = Fornecedor(
                              id: fornecedor?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
                              status: fornecedor?.status ?? 'Ativo',
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
                              fornecedor == null ? "SALVAR FORNECEDOR" : "ATUALIZAR",
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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: _T.teal,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5)),
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
    final isMono = keyboardType == TextInputType.number || keyboardType == TextInputType.phone;
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 14,
            fontFamily: isMono ? _T.mono : null
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
              fontSize: 12),
          prefixIcon: Icon(icon, size: 16, color: theme.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}

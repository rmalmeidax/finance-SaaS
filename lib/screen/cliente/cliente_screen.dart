import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


import '../../controllers/clientes_controller.dart';
import '../../model/clientes_model.dart';

class ClienteScreen extends StatelessWidget {
  const ClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ClienteController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF26A69A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 3,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF26A69A),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "CLIENTES",
              style: TextStyle(
                color: Colors.white,
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
              color: const Color(0xFF26A69A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.add, color: Colors.black),
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
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Buscar por nome, fantasia ou documento...",
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF26A69A), size: 18),
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

          // ── FILTROS TIPO ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _chip("Todos", controller.filtroTipo == FiltroTipoCliente.todos,
                        () => controller.setFiltroTipo(FiltroTipoCliente.todos)),
                const SizedBox(width: 8),
                _chip("Pessoa Jurídica",
                    controller.filtroTipo == FiltroTipoCliente.pj,
                        () => controller.setFiltroTipo(FiltroTipoCliente.pj)),
                const SizedBox(width: 8),
                _chip("Pessoa Física",
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
                _chip(
                    "Qualquer status",
                    controller.filtroStatus == FiltroStatusCliente.todos,
                        () => controller
                        .setFiltroStatus(FiltroStatusCliente.todos)),
                const SizedBox(width: 8),
                _chipColor(
                  "Ativo",
                  controller.filtroStatus == FiltroStatusCliente.ativo,
                  const Color(0xFF4CAF50),
                      () =>
                      controller.setFiltroStatus(FiltroStatusCliente.ativo),
                ),
                const SizedBox(width: 8),
                _chipColor(
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
                      color: Colors.white.withOpacity(0.12), size: 60),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhum cliente encontrado",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
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
  Widget _dashboard(ClienteController controller) {
    final total = controller.clientes.length;
    final ativos =
        controller.clientes.where((c) => c.status == 'Ativo').length;
    final pj = controller.clientes
        .where((c) => c.tipoPessoa == TipoPessoaCliente.juridica)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _dashCard("TOTAL", "$total", const Color(0xFF26A69A),
              Icons.people_outline),
          const SizedBox(width: 10),
          _dashCard("ATIVOS", "$ativos", const Color(0xFF4CAF50),
              Icons.check_circle_outline),
          const SizedBox(width: 10),
          _dashCard(
              "PJ", "$pj", const Color(0xFF4FC3F7), Icons.business_outlined),
        ],
      ),
    );
  }

  Widget _dashCard(String titulo, String valor, Color cor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
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
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  // ── CARD ──
  Widget _clienteCard(
      BuildContext context, Cliente c, ClienteController controller) {
    final isPj = c.tipoPessoa == TipoPessoaCliente.juridica;
    final isAtivo = c.status == 'Ativo';
    final statusColor =
    isAtivo ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final tipoColor =
    isPj ? const Color(0xFF4FC3F7) : const Color(0xFFFFB74D);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: const Border(
                  bottom: BorderSide(color: Color(0xFF1E1E1E))),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      c.nome.isNotEmpty ? c.nome[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: Color(0xFF26A69A),
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
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (c.fantasia.isNotEmpty)
                        Text(c.fantasia,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
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
                    _infoItem(Icons.badge_outlined, isPj ? "CNPJ" : "CPF",
                        c.documento),
                    _infoItem(Icons.phone_outlined, "Telefone",
                        c.telefone.isEmpty ? '—' : c.telefone),
                    _infoItem(Icons.email_outlined, "E-mail",
                        c.email.isEmpty ? '—' : c.email),
                  ],
                ),
                if (c.cidade.isNotEmpty || c.estado.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoItem(
                          Icons.location_on_outlined,
                          "Cidade / UF",
                          "${c.cidade}${c.estado.isNotEmpty ? ' - ${c.estado}' : ''}"),
                      _infoItem(Icons.map_outlined, "Bairro",
                          c.bairro.isEmpty ? '—' : c.bairro),
                      _infoItem(Icons.markunread_mailbox_outlined, "CEP",
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
                      color: const Color(0xFF0D1A2E),
                      iconColor: const Color(0xFF4FC3F7),
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
                          ? const Color(0xFF1A0D0D)
                          : const Color(0xFF0A1F0A),
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
                      color: const Color(0xFF1A0D0D),
                      iconColor: Colors.red.withOpacity(0.6),
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

  Widget _infoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: const Color(0xFF26A69A)),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 9,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
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

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:
          selected ? const Color(0xFF26A69A) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? const Color(0xFF26A69A)
                  : const Color(0xFF2A2A2A)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.black : Colors.white54,
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.3)),
      ),
    );
  }

  Widget _chipColor(
      String label, bool selected, Color cor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cor : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? cor : const Color(0xFF2A2A2A)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.black : Colors.white54,
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

  // ── CONFIRM DELETE ──
  void _confirmDelete(
      BuildContext context, Cliente c, ClienteController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF111111),
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
              const Text("Excluir Cliente",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text("Tem certeza que deseja excluir ${c.nome}?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 13)),
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
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF2A2A2A)),
                        ),
                        child: const Text("CANCELAR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white54,
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
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Color(0xFF1E1E1E))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        cliente == null
                            ? "NOVO CLIENTE"
                            : "EDITAR CLIENTE",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close,
                            color: Colors.white.withOpacity(0.4),
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
                        _labelSection("TIPO DE PESSOA"),
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
                                        ? const Color(0xFF26A69A)
                                        : const Color(0xFF161616),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                      color: tipo ==
                                          TipoPessoaCliente.juridica
                                          ? const Color(0xFF26A69A)
                                          : const Color(0xFF2A2A2A),
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
                                              ? Colors.black
                                              : Colors.white54),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Pessoa Jurídica",
                                        style: TextStyle(
                                            color: tipo ==
                                                TipoPessoaCliente
                                                    .juridica
                                                ? Colors.black
                                                : Colors.white54,
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
                                        : const Color(0xFF161616),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                      color: tipo ==
                                          TipoPessoaCliente.fisica
                                          ? const Color(0xFFFFB74D)
                                          : const Color(0xFF2A2A2A),
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
                                              ? Colors.black
                                              : Colors.white54),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Pessoa Física",
                                        style: TextStyle(
                                            color: tipo ==
                                                TipoPessoaCliente
                                                    .fisica
                                                ? Colors.black
                                                : Colors.white54,
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
                        _labelSection(tipo == TipoPessoaCliente.juridica
                            ? "CNPJ"
                            : "CPF"),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: _inputField(
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
                                    color: const Color(0xFF26A69A),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: buscando
                                      ? const Padding(
                                    padding: EdgeInsets.all(13),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black),
                                  )
                                      : const Icon(Icons.search,
                                      color: Colors.black, size: 20),
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
                              color: const Color(0xFF0D1520),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFF26A69A)
                                      .withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Color(0xFF26A69A), size: 14),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    "Digite o CNPJ e clique em 🔍 para buscar os dados na Receita Federal automaticamente.",
                                    style: TextStyle(
                                        color: Color(0xFF26A69A),
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
                          _labelSection("INFORMAÇÕES GERAIS"),
                          const SizedBox(height: 10),
                          _inputField(
                              nomeCtrl,
                              tipo == TipoPessoaCliente.juridica
                                  ? "Razão Social"
                                  : "Nome Completo",
                              Icons.person_outline),
                          if (tipo == TipoPessoaCliente.juridica) ...[
                            const SizedBox(height: 10),
                            _inputField(fantasiaCtrl, "Nome Fantasia",
                                Icons.storefront_outlined),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(telefoneCtrl, "Telefone",
                                    Icons.phone_outlined,
                                    keyboardType: TextInputType.phone),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _inputField(emailCtrl, "E-mail",
                                    Icons.email_outlined,
                                    keyboardType:
                                    TextInputType.emailAddress),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          _labelSection("ENDEREÇO"),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _inputField(cepCtrl, "CEP",
                                    Icons.markunread_mailbox_outlined,
                                    keyboardType: TextInputType.number),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: _inputField(logradouroCtrl,
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
                                    numeroCtrl, "Número", Icons.tag),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _inputField(complementoCtrl,
                                    "Complemento", Icons.home_outlined),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(bairroCtrl, "Bairro",
                                    Icons.map_outlined),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _inputField(cidadeCtrl, "Cidade",
                                    Icons.location_city_outlined),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 60,
                                child: _inputField(estadoCtrl, "UF",
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
                  decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xFF1E1E1E))),
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
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFF2A2A2A)),
                            ),
                            child: const Text("CANCELAR",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white54,
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
                              color: const Color(0xFF26A69A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              cliente == null
                                  ? "SALVAR CLIENTE"
                                  : "ATUALIZAR",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.black,
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
    return Row(
      children: [
        Container(
          width: 2,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF26A69A),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF26A69A),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2)),
      ],
    );
  }

  Widget _inputField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.35), fontSize: 12),
          prefixIcon:
          Icon(icon, size: 16, color: const Color(0xFF26A69A)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}
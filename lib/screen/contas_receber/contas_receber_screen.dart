import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/conta_receber_controller.dart';
import '../../model/conta_receber_model.dart';

class ContasReceberScreen extends StatelessWidget {
  const ContasReceberScreen({super.key});

  double parseValor(String texto) {
    return double.tryParse(texto.replaceAll(',', '.')) ?? 0;
  }

  String formatar(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ContaReceberController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF4FC3F7), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 3,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF4FC3F7),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "CONTAS A RECEBER",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'serif',
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
              color: const Color(0xFF4FC3F7),
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
                  hintText: "Buscar cliente ou descrição...",
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF4FC3F7), size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: controller.setBusca,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── DASHBOARD ──
          _dashboard(controller),

          const SizedBox(height: 20),

          // ── FILTROS ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _filtroChip("Todas", FiltroStatus.todos, controller),
                const SizedBox(width: 8),
                _filtroChip("A vencer", FiltroStatus.aVencer, controller),
                const SizedBox(width: 8),
                _filtroChip("Vencidas", FiltroStatus.vencidos, controller),
                const SizedBox(width: 8),
                _filtroChip("Recebidas", FiltroStatus.pagos, controller),
              ],
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
                      color: Colors.white.withOpacity(0.15), size: 56),
                  const SizedBox(height: 12),
                  Text(
                    "Nenhuma conta encontrada",
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
  Widget _contaCard(BuildContext context, ContaReceber conta,
      ContaReceberController controller) {
    final hoje = DateTime.now();
    final vencida = hoje.isAfter(conta.dataVencimento) &&
        conta.status != "Recebido";
    final recebida = conta.status == "Recebido";

    Color statusColor = recebida
        ? const Color(0xFF4CAF50)
        : vencida
        ? const Color(0xFFE53935)
        : const Color(0xFF4FC3F7);

    String statusLabel = recebida
        ? "RECEBIDO"
        : vencida
        ? "VENCIDO"
        : "A RECEBER";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Column(
        children: [
          // Cabeçalho
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.07),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(color: statusColor.withOpacity(0.2)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    conta.descricao.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                    Border.all(color: statusColor.withOpacity(0.4)),
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
                    _infoItem(Icons.person_outline, "Cliente", conta.cliente),
                    _infoItem(Icons.description_outlined, "Documento",
                        conta.numeroDocumento),
                    _infoItem(Icons.category_outlined, "Tipo",
                        conta.tipoDocumento.name),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _infoItem(Icons.calendar_today_outlined, "Emissão",
                        _formatData(conta.dataEmissao)),
                    _infoItem(Icons.event_outlined, "Vencimento",
                        _formatData(conta.dataVencimento)),
                    _infoItem(
                        Icons.percent_outlined,
                        "Juros/Multa",
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
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 9,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          "R\$ ${formatar(conta.valorAtualizado)}",
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (conta.valorAtualizado != conta.valorBoleto)
                          Text(
                            "Original: R\$ ${formatar(conta.valorBoleto)}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        // Recalcular
                        _actionButton(
                          icon: Icons.refresh_rounded,
                          tooltip: "Recalcular",
                          color: const Color(0xFF1E1E1E),
                          iconColor: Colors.white60,
                          onTap: () async {
                            conta.valorAtualizado =
                                controller.calcularValorAtualizado(conta);
                            await controller.service.atualizar(conta);
                          },
                        ),
                        const SizedBox(width: 8),
                        // Editar
                        _actionButton(
                          icon: Icons.edit_outlined,
                          tooltip: "Editar",
                          color: const Color(0xFF0D1A2E),
                          iconColor: const Color(0xFF4FC3F7),
                          onTap: () =>
                              _showDialog(context, controller, conta: conta),
                        ),
                        const SizedBox(width: 8),
                        // Receber
                        if (!recebida)
                          _actionButton(
                            icon: Icons.check_rounded,
                            tooltip: "Marcar como Recebido",
                            color: const Color(0xFF0A1F0A),
                            iconColor: const Color(0xFF4CAF50),
                            onTap: () async {
                              await controller.service
                                  .marcarComoRecebido(conta.id);
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

  Widget _infoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: const Color(0xFF4FC3F7)),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
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

  // ── FILTRO CHIP ──
  Widget _filtroChip(
      String label, FiltroStatus filtro, ContaReceberController c) {
    final selecionado = c.filtroAtual == filtro;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.setFiltro(filtro),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selecionado
                ? const Color(0xFF4FC3F7)
                : const Color(0xFF161616),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selecionado
                  ? const Color(0xFF4FC3F7)
                  : const Color(0xFF2A2A2A),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selecionado ? Colors.black : Colors.white54,
              fontSize: 11,
              fontWeight:
              selecionado ? FontWeight.w700 : FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  // ── DASHBOARD ──
  Widget _dashboard(ContaReceberController controller) {
    double total = 0, vencido = 0, aVencer = 0;
    final hoje = DateTime.now();
    for (var c in controller.contas) {
      total += c.valorAtualizado;
      if (c.dataVencimento.isBefore(hoje) && c.status != "Recebido") {
        vencido += c.valorAtualizado;
      } else if (c.dataVencimento.isAfter(hoje)) {
        aVencer += c.valorAtualizado;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _dashCard("TOTAL", total, const Color(0xFF4FC3F7),
              Icons.account_balance_wallet_outlined),
          const SizedBox(width: 10),
          _dashCard("VENCIDO", vencido, const Color(0xFFE53935),
              Icons.warning_amber_outlined),
          const SizedBox(width: 10),
          _dashCard("A RECEBER", aVencer, const Color(0xFF66BB6A),
              Icons.schedule_outlined),
        ],
      ),
    );
  }

  Widget _dashCard(
      String titulo, double valor, Color cor, IconData icon) {
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
              "R\$",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 10),
            ),
            Text(
              formatar(valor),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatData(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  // ── DIALOG ──
  void _showDialog(BuildContext context, ContaReceberController controller,
      {ContaReceber? conta}) {
    final cliente =
    TextEditingController(text: conta?.cliente ?? '');
    final descricao =
    TextEditingController(text: conta?.descricao ?? '');
    final numero =
    TextEditingController(text: conta?.numeroDocumento ?? '');
    final valor = TextEditingController(
        text: conta != null
            ? conta.valorBoleto.toStringAsFixed(2)
            : '');
    final jurosMensal = TextEditingController(
        text: conta != null ? conta.juros.toStringAsFixed(2) : '');
    final multaCtrl = TextEditingController(
        text: conta != null ? conta.multa.toStringAsFixed(2) : '');

    TipoDocumento tipo =
        conta?.tipoDocumento ?? TipoDocumento.boleto;
    DateTime dataEmissao = conta?.dataEmissao ?? DateTime.now();
    DateTime dataVencimento =
        conta?.dataVencimento ?? DateTime.now();

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
                          bottom:
                          BorderSide(color: Color(0xFF1E1E1E))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3F7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          conta == null
                              ? "NOVA CONTA"
                              : "EDITAR CONTA",
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

                  // Campos
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _labelSection("INFORMAÇÕES GERAIS"),
                          const SizedBox(height: 10),
                          _inputField(cliente, "Cliente",
                              Icons.person_outline),
                          const SizedBox(height: 10),
                          _inputField(descricao, "Descrição",
                              Icons.description_outlined),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                  child: _inputField(numero,
                                      "Nº Documento", Icons.tag)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _dropdownTipo(tipo,
                                        (v) => setState(() => tipo = v!)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          _labelSection("DATAS"),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _datePicker(
                                  context: context,
                                  label: "Data de Emissão",
                                  icon: Icons.calendar_today_outlined,
                                  data: dataEmissao,
                                  onPicked: (d) => setState(
                                          () => dataEmissao = d),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _datePicker(
                                  context: context,
                                  label: "Data de Vencimento",
                                  icon: Icons.event_outlined,
                                  data: dataVencimento,
                                  onPicked: (d) => setState(
                                          () => dataVencimento = d),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          _labelSection("VALORES"),
                          const SizedBox(height: 10),
                          _inputField(
                              valor, "Valor (ex: 1000,50)",
                              Icons.attach_money,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _inputField(
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
                                    color: const Color(0xFF0D1A0D),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                        const Color(0xFF1E3A1E)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.show_chart,
                                              size: 13,
                                              color:
                                              Color(0xFF4CAF50)),
                                          const SizedBox(width: 5),
                                          Text(
                                            "TAXA DIÁRIA",
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.4),
                                              fontSize: 9,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${_taxaDiaria(jurosMensal.text).toStringAsFixed(4)}%",
                                        style: const TextStyle(
                                          color: Color(0xFF4CAF50),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        "ao dia",
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.3),
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
                          _inputField(multaCtrl, "Multa (%)",
                              Icons.gavel_outlined,
                              keyboardType: TextInputType.number),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFF2A2A2A)),
                              ),
                              child: const Text(
                                "CANCELAR",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
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
                              final valorBoleto =
                              parseValor(valor.text);
                              final jurosValor =
                              parseValor(jurosMensal.text);
                              final multaValor =
                              parseValor(multaCtrl.text);

                              if (conta == null) {
                                final nova = ContaReceber(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  cliente: cliente.text,
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
                                nova.valorAtualizado = controller
                                    .calcularValorAtualizado(nova);
                                await controller.adicionar(nova);
                              } else {
                                final atualizada = ContaReceber(
                                  id: conta.id,
                                  cliente: cliente.text,
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
                                atualizada.valorAtualizado = controller
                                    .calcularValorAtualizado(atualizada);
                                await controller.atualizar(atualizada);
                              }

                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4FC3F7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                conta == null
                                    ? "SALVAR CONTA"
                                    : "ATUALIZAR",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
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

  Widget _labelSection(String label) {
    return Row(
      children: [
        Container(
          width: 2,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF4FC3F7),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4FC3F7),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _inputField(
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        void Function(String)? onChanged,
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
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 12,
          ),
          prefixIcon:
          Icon(icon, size: 16, color: const Color(0xFF4FC3F7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _dropdownTipo(
      TipoDocumento valor, void Function(TipoDocumento?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TipoDocumento>(
          value: valor,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF4FC3F7), size: 18),
          style:
          const TextStyle(color: Colors.white, fontSize: 13),
          items: TipoDocumento.values.map((t) {
            return DropdownMenuItem(
              value: t,
              child: Text(t.name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13)),
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
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: data,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4FC3F7),
                onPrimary: Colors.black,
                surface: Color(0xFF1A1A1A),
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF4FC3F7)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}",
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
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
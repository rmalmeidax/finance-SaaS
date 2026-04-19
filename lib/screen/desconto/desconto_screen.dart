// lib/features/desconto/screen/desconto_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/desconto_controller.dart';
import '../../model/desconto_model.dart';


// ══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ══════════════════════════════════════════════════════════════
abstract class _T {
  // Cores semânticas
  static const teal   = Color(0xFF00BFA5);
  static const green  = Color(0xFF43A047);
  static const orange = Color(0xFFEF6C00);
  static const blue   = Color(0xFF1565C0);
  static const red    = Color(0xFFC62828);
  static const mono   = 'monospace';

  // Cor por status
  static Color corStatus(DescontoStatus s) {
    switch (s) {
      case DescontoStatus.ativo:     return green;
      case DescontoStatus.expirando: return orange;
      case DescontoStatus.agendado:  return blue;
      case DescontoStatus.expirado:  return const Color(0xFF9E9E9E);
    }
  }

  // Cor por tipo de documento
  static Color corTipo(TipoDocumento t) {
    switch (t) {
      case TipoDocumento.duplicata:       return const Color(0xFF1565C0);
      case TipoDocumento.cheque:          return const Color(0xFF6A1B9A);
      case TipoDocumento.notaPromissoria: return const Color(0xFF00695C);
      case TipoDocumento.cce:             return const Color(0xFFE65100);
      case TipoDocumento.cpr:             return const Color(0xFF558B2F);
      case TipoDocumento.outros:          return const Color(0xFF546E7A);
    }
  }

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
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  static String fmtPct(double v) =>
      '${v.toStringAsFixed(2).replaceAll('.', ',')}%';
}

// ══════════════════════════════════════════════════════════════
// TELA PRINCIPAL
// ══════════════════════════════════════════════════════════════
class DescontoScreen extends StatefulWidget {
  const DescontoScreen({super.key});
  @override
  State<DescontoScreen> createState() => _DescontoScreenState();
}

class _DescontoScreenState extends State<DescontoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _formExpandido = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DescontoController>().carregarDescontos();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _DescontoAppBar(
        onAdicionar: () => setState(() => _formExpandido = !_formExpandido),
        formAberto: _formExpandido,
      ),
      body: Column(
        children: [
          // ── Form de lançamento (expansível) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
            child: _formExpandido
                ? _DescontoFormCard(
              onInserido: () => setState(() => _formExpandido = false),
            )
                : const SizedBox.shrink(),
          ),

          // ── Dashboard ──
          const _DescontoDashboard(),
          const SizedBox(height: 2),

          // ── TabBar ──
          _DescontoTabBar(controller: _tab),

          // ── Conteúdo da tab ──
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [
                _DescontoGridView(),
                _DescontoListaView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// APPBAR
// ══════════════════════════════════════════════════════════════
class _DescontoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAdicionar;
  final bool formAberto;

  const _DescontoAppBar({
    required this.onAdicionar,
    required this.formAberto,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 0.5);

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    return AppBar(
      backgroundColor: theme.cardColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          // Botão voltar
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Icon(Icons.chevron_left,
                  size: 24, color: textColor?.withValues(alpha: 0.55)),
            ),
          ),
          // Barra teal
          Container(
            width: 2, height: 18,
            decoration: BoxDecoration(
                color: _T.teal, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text(
            'DESCONTO DE TÍTULOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 1.8,
              fontFamily: _T.mono,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 8),
          // Botão inserir título
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: formAberto
                  ? theme.dividerColor
                  : theme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: onAdicionar,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      formAberto ? Icons.close : Icons.add,
                      size: 14,
                      color: formAberto
                          ? textColor
                          : (theme.primaryColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formAberto ? 'Fechar' : 'Inserir Título',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: formAberto
                            ? textColor
                            : (theme.primaryColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: theme.dividerColor),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// FORM CARD — Lançamento de título
// ══════════════════════════════════════════════════════════════
class _DescontoFormCard extends StatefulWidget {
  final VoidCallback onInserido;
  const _DescontoFormCard({required this.onInserido});
  @override
  State<_DescontoFormCard> createState() => _DescontoFormCardState();
}

class _DescontoFormCardState extends State<_DescontoFormCard> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _numDoc      = TextEditingController();
  final _nomeCliente = TextEditingController();
  final _valorNom    = TextEditingController();
  final _taxaJuros   = TextEditingController(text: '1.8');
  final _taxaIof     = TextEditingController(text: '0.38');
  final _taxaDesc    = TextEditingController(text: '2.1');

  TipoDocumento _tipo    = TipoDocumento.duplicata;
  DateTime _dataEmissao  = DateTime.now();
  DateTime _dataVenc     = DateTime.now().add(const Duration(days: 30));
  String? _msgFeedback;
  bool _sucesso = false;

  @override
  void dispose() {
    _numDoc.dispose(); _nomeCliente.dispose(); _valorNom.dispose();
    _taxaJuros.dispose(); _taxaIof.dispose(); _taxaDesc.dispose();
    super.dispose();
  }

  double get _vNominal  => double.tryParse(_valorNom.text.replaceAll(',', '.')) ?? 0;
  double get _vJuros    => (_vNominal * (double.tryParse(_taxaJuros.text.replaceAll(',','.')) ?? 0) / 100) * (_dias / 30);
  double get _vIof      => _vNominal * (double.tryParse(_taxaIof.text.replaceAll(',','.')) ?? 0) / 100;
  double get _vDesc     => (_vNominal * (double.tryParse(_taxaDesc.text.replaceAll(',','.')) ?? 0) / 100) * (_dias / 30);
  double get _vLiquido  => _vNominal - _vDesc - _vIof - _vJuros;
  int    get _dias      => _dataVenc.difference(_dataEmissao).inDays;

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    final bg        = theme.scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header do form ──
              Row(
                children: [
                  Container(
                    width: 3, height: 14,
                    decoration: BoxDecoration(
                      color: _T.teal,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DADOS DO TÍTULO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: textColor?.withValues(alpha: 0.5),
                      letterSpacing: 1.5,
                      fontFamily: _T.mono,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Linha 1: Nº Doc / Tipo / Cliente ──
              LayoutBuilder(builder: (_, c) {
                final narrow = c.maxWidth < 600;
                final fields = [
                  _FormField(
                    label: 'Nº DOCUMENTO',
                    child: _Input(
                      ctrl: _numDoc,
                      hint: 'Ex: DUP-2024-00341',
                      validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
                    ),
                    flex: 2,
                  ),
                  _FormField(
                    label: 'TIPO',
                    child: _DropTipo(
                      value: _tipo,
                      onChanged: (t) => setState(() => _tipo = t),
                    ),
                    flex: 2,
                  ),
                  _FormField(
                    label: 'SACADO / CLIENTE',
                    child: _Input(
                      ctrl: _nomeCliente,
                      hint: 'Nome do sacado',
                      validator: (v) => (v?.isEmpty ?? true) ? 'Obrigatório' : null,
                    ),
                    flex: 3,
                  ),
                ];
                return narrow
                    ? Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList())
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: _intersperse(fields, const SizedBox(width: 10)));
              }),

              const SizedBox(height: 10),

              // ── Linha 2: Datas / Valor ──
              LayoutBuilder(builder: (_, c) {
                final narrow = c.maxWidth < 600;
                final fields = [
                  _FormField(
                    label: 'EMISSÃO',
                    child: _DatePicker(
                      date: _dataEmissao,
                      onPicked: (d) => setState(() => _dataEmissao = d),
                    ),
                  ),
                  _FormField(
                    label: 'VENCIMENTO',
                    child: _DatePicker(
                      date: _dataVenc,
                      onPicked: (d) => setState(() => _dataVenc = d),
                      firstDate: _dataEmissao,
                    ),
                  ),
                  _FormField(
                    label: 'VALOR NOMINAL (R\$)',
                    child: _Input(
                      ctrl: _valorNom,
                      hint: '0,00',
                      isNum: true,
                      validator: (v) {
                        final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                        if (n == null || n <= 0) return 'Valor inválido';
                        return null;
                      },
                    ),
                    flex: 2,
                  ),
                ];
                return narrow
                    ? Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList())
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: _intersperse(fields, const SizedBox(width: 10)));
              }),

              const SizedBox(height: 10),

              // ── Linha 3: Taxas ──
              LayoutBuilder(builder: (_, c) {
                final narrow = c.maxWidth < 500;
                final fields = [
                  _FormField(
                    label: 'TAXA JUROS (% a.m.)',
                    child: _Input(ctrl: _taxaJuros, hint: '0,00', isNum: true),
                  ),
                  _FormField(
                    label: 'TAXA IOF (%)',
                    child: _Input(ctrl: _taxaIof, hint: '0,38', isNum: true),
                  ),
                  _FormField(
                    label: 'TAXA DESCONTO (% a.m.)',
                    child: _Input(ctrl: _taxaDesc, hint: '0,00', isNum: true),
                  ),
                ];
                return narrow
                    ? Column(children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f)).toList())
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: _intersperse(fields, const SizedBox(width: 10)));
              }),

              const SizedBox(height: 16),

              // ── Prévia de valores calculados ──
              if (_vNominal > 0) ...[
                _SimulacaoPrevia(
                  valorNominal: _vNominal,
                  valorJuros:   _vJuros,
                  valorIof:     _vIof,
                  valorDesconto: _vDesc,
                  valorLiquido:  _vLiquido,
                  dias:          _dias,
                ),
                const SizedBox(height: 14),
              ],

              // ── Rodapé do form ──
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    if (_msgFeedback != null) ...[
                      Icon(
                        _sucesso ? Icons.check_circle_outline : Icons.error_outline,
                        size: 14,
                        color: _sucesso ? _T.green : _T.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _msgFeedback!,
                        style: TextStyle(
                          fontSize: 11,
                          color: _sucesso ? _T.green : _T.orange,
                          fontFamily: _T.mono,
                        ),
                      ),
                    ],
                    const Spacer(),
                    OutlinedButton(
                      onPressed: _limpar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor?.withValues(alpha: 0.5),
                        side: BorderSide(color: theme.dividerColor),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Limpar', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _submeter,
                      icon: const Icon(Icons.upload_file_outlined, size: 16),
                      label: const Text('Inserir Título'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.primaryColor.computeLuminance() > 0.5
                            ? Colors.black : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submeter() {
    if (!_formKey.currentState!.validate()) return;

    final iniciais = _nomeCliente.text.trim().split(' ')
        .take(2).map((p) => p[0].toUpperCase()).join();

    context.read<DescontoController>().inserirTitulo(
      DescontoModel(
        id:              DateTime.now().millisecondsSinceEpoch.toString(),
        numeroDocumento: _numDoc.text.trim(),
        tipoDocumento:   _tipo,
        dataEmissao:     _dataEmissao,
        dataVencimento:  _dataVenc,
        valorNominal:    _vNominal,
        taxaJuros:       double.tryParse(_taxaJuros.text.replaceAll(',', '.')) ?? 0,
        taxaIof:         double.tryParse(_taxaIof.text.replaceAll(',', '.')) ?? 0,
        taxaDesconto:    double.tryParse(_taxaDesc.text.replaceAll(',', '.')) ?? 0,
        nomeCliente:     _nomeCliente.text.trim(),
        iniciaisCliente: iniciais,
        status:          DescontoStatus.ativo,
      ),
    );

    setState(() { _msgFeedback = '✓ Título inserido com sucesso!'; _sucesso = true; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _msgFeedback = null);
        widget.onInserido();
      }
    });
  }

  void _limpar() {
    _numDoc.clear(); _nomeCliente.clear(); _valorNom.clear();
    _taxaJuros.text = '1.8'; _taxaIof.text = '0.38'; _taxaDesc.text = '2.1';
    setState(() {
      _tipo = TipoDocumento.duplicata;
      _dataEmissao = DateTime.now();
      _dataVenc = DateTime.now().add(const Duration(days: 30));
      _msgFeedback = null;
    });
  }

  List<Widget> _intersperse(List<Widget> list, Widget sep) {
    final result = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      if (i > 0) result.add(sep);
      result.add(list[i] is _FormField
          ? Expanded(flex: (list[i] as _FormField).flex, child: list[i])
          : list[i]);
    }
    return result;
  }
}

// ── Prévia de simulação ──────────────────────────────────────
class _SimulacaoPrevia extends StatelessWidget {
  final double valorNominal, valorJuros, valorIof, valorDesconto, valorLiquido;
  final int dias;
  const _SimulacaoPrevia({
    required this.valorNominal, required this.valorJuros,
    required this.valorIof, required this.valorDesconto,
    required this.valorLiquido, required this.dias,
  });

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _T.teal.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.calculate_outlined, size: 12, color: _T.teal),
            const SizedBox(width: 6),
            Text('SIMULAÇÃO — $dias dias corridos',
                style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: _T.teal, letterSpacing: 1.2, fontFamily: _T.mono,
                )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _SimItem(label: 'NOMINAL',   valor: _T.fmtMoeda(valorNominal), cor: textColor),
            const _Seta(),
            _SimItem(label: 'JUROS',     valor: '− ${_T.fmtMoeda(valorJuros)}',   cor: _T.orange),
            _SimItem(label: 'IOF',       valor: '− ${_T.fmtMoeda(valorIof)}',     cor: _T.orange),
            _SimItem(label: 'DESCONTO',  valor: '− ${_T.fmtMoeda(valorDesconto)}', cor: _T.orange),
            const _Seta(),
            _SimItem(
              label: 'LÍQUIDO',
              valor: _T.fmtMoeda(valorLiquido),
              cor: valorLiquido > 0 ? _T.green : _T.red,
              destaque: true,
            ),
          ]),
        ],
      ),
    );
  }
}

class _SimItem extends StatelessWidget {
  final String label, valor;
  final Color? cor;
  final bool destaque;
  const _SimItem({required this.label, required this.valor, this.cor, this.destaque = false});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 8, color: Colors.grey, letterSpacing: 0.8, fontFamily: _T.mono)),
        const SizedBox(height: 2),
        Text(
          valor,
          style: TextStyle(
            fontSize: destaque ? 13 : 11,
            fontWeight: destaque ? FontWeight.w800 : FontWeight.w500,
            color: cor,
          ),
        ),
      ],
    ),
  );
}

class _Seta extends StatelessWidget {
  const _Seta();
  @override
  Widget build(BuildContext context) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 2, right: 4),
        child: Icon(Icons.arrow_forward_ios_rounded,
            size: 10, color: Theme.of(context).dividerColor),
      );
}

// ══════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════
class _DescontoDashboard extends StatelessWidget {
  const _DescontoDashboard();

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<DescontoController>().state;
    final resumo  = state.resumo;
    final theme   = Theme.of(context);

    return Container(
      color: theme.cardColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(children: [
        _DashTile(
          label: 'LÍQUIDO TOTAL',
          valor: _T.fmtMoeda(resumo?.totalLiquido ?? 0),
          cor: _T.teal,
          icon: Icons.account_balance_wallet_outlined,
          flex: 3,
        ),
        const SizedBox(width: 10),
        _DashTile(
          label: 'NOMINAL',
          valor: _T.fmtMoeda(resumo?.totalNominal ?? 0),
          cor: _T.blue,
          icon: Icons.description_outlined,
          flex: 3,
        ),
        const SizedBox(width: 10),
        _DashTile(
          label: 'ATIVOS',
          valor: '${resumo?.ativos ?? 0}',
          cor: _T.green,
          icon: Icons.check_circle_outline,
          flex: 2,
        ),
        const SizedBox(width: 10),
        _DashTile(
          label: 'EXPIRAM',
          valor: '${resumo?.expirando ?? 0}',
          cor: _T.orange,
          icon: Icons.timer_outlined,
          flex: 2,
        ),
      ]),
    );
  }
}

class _DashTile extends StatelessWidget {
  final String label, valor;
  final Color cor;
  final IconData icon;
  final int flex;

  const _DashTile({
    required this.label, required this.valor,
    required this.cor, required this.icon, this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 10, color: cor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8, color: cor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      fontFamily: _T.mono,
                    )),
              ),
            ]),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(valor,
                  style: TextStyle(
                    fontSize: flex >= 3 ? 14 : 18,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyMedium?.color,
                    letterSpacing: -0.3,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TAB BAR (Filtros + Busca)
// ══════════════════════════════════════════════════════════════
class _DescontoTabBar extends StatefulWidget {
  final TabController controller;
  const _DescontoTabBar({required this.controller});
  @override
  State<_DescontoTabBar> createState() => _DescontoTabBarState();
}

class _DescontoTabBarState extends State<_DescontoTabBar> {
  @override
  Widget build(BuildContext context) {
    final theme   = Theme.of(context);
    final ctrl    = context.watch<DescontoController>();

    return Container(
      color: theme.cardColor,
      child: Column(
        children: [
          // Abas Grid / Lista
          TabBar(
            controller: widget.controller,
            indicatorColor: theme.primaryColor,
            indicatorWeight: 2,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'GRID DE TÍTULOS'),
              Tab(text: 'DETALHES'),
            ],
          ),
          // Filtros + busca
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Row(
              children: [
                // Filtros chips
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _FChip(label: 'Todos',     status: null,                    ctrl: ctrl),
                      const SizedBox(width: 6),
                      _FChip(label: 'Ativos',    status: DescontoStatus.ativo,    ctrl: ctrl),
                      const SizedBox(width: 6),
                      _FChip(label: 'Expirando', status: DescontoStatus.expirando, ctrl: ctrl),
                      const SizedBox(width: 6),
                      _FChip(label: 'Agendados', status: DescontoStatus.agendado, ctrl: ctrl),
                    ]),
                  ),
                ),
                // Busca compacta
                const SizedBox(width: 10),
                SizedBox(
                  width: 180,
                  height: 34,
                  child: TextField(
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3)),
                      prefixIcon: Icon(Icons.search,
                          size: 16, color: theme.primaryColor),
                      isDense: true,
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.dividerColor)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.dividerColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.primaryColor, width: 1.2)),
                    ),
                    onChanged: ctrl.setBusca,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),
        ],
      ),
    );
  }
}

class _FChip extends StatelessWidget {
  final String label;
  final DescontoStatus? status;
  final DescontoController ctrl;
  const _FChip({required this.label, required this.status, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final selected = ctrl.state.filtroAtivo == status &&
        (label != 'Todos' || ctrl.state.filtroAtivo == null);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => ctrl.aplicarFiltro(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? theme.primaryColor : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: selected ? theme.primaryColor : theme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected
                  ? Colors.white
                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            )),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GRID VIEW — tabela estilo banco
// ══════════════════════════════════════════════════════════════
class _DescontoGridView extends StatelessWidget {
  const _DescontoGridView();

  static const _cols = [
    ('Nº DOC.',    3),
    ('TIPO',       2),
    ('EMISSÃO',    2),
    ('VENCIMENTO', 2),
    ('NOMINAL',    3),
    ('TAXA DESC.', 2),
    ('IOF',        2),
    ('LÍQUIDO',    3),
    ('STATUS',     2),
    ('',           1), // ações
  ];

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<DescontoController>().state;
    final theme   = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color;

    if (state.carregando) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }
    if (state.estaVazio) return const _EmptyState();

    return Column(
      children: [
        // ── Cabeçalho da tabela ──
        Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            children: _cols.map((c) => Expanded(
              flex: c.$2,
              child: Text(c.$1,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: textColor?.withValues(alpha: 0.35),
                    letterSpacing: 0.8,
                    fontFamily: _T.mono,
                  )),
            )).toList(),
          ),
        ),
        Divider(height: 1, color: theme.dividerColor),
        // ── Linhas ──
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: state.descontos.length,
            separatorBuilder: (_, __) => Divider(
                height: 1, color: theme.dividerColor.withValues(alpha: 0.6)),
            itemBuilder: (_, i) => _GridRow(
              desconto: state.descontos[i],
              onExcluir: () => context
                  .read<DescontoController>()
                  .excluirDesconto(state.descontos[i].id),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridRow extends StatelessWidget {
  final DescontoModel desconto;
  final VoidCallback onExcluir;
  const _GridRow({required this.desconto, required this.onExcluir});

  @override
  Widget build(BuildContext context) {
    final d       = desconto;
    final theme   = Theme.of(context);
    final tc      = theme.textTheme.bodyMedium?.color;
    final corS    = _T.corStatus(d.status);
    final corT    = _T.corTipo(d.tipoDocumento);
    final opac    = d.status == DescontoStatus.expirado ? 0.5 : 1.0;

    return Opacity(
      opacity: opac,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              // Nº Doc
              Expanded(flex: 3, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.numeroDocumento,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, color: tc)),
                  Text(d.nomeCliente,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 9, color: tc?.withValues(alpha: 0.4),
                          fontFamily: _T.mono)),
                ],
              )),
              // Tipo
              Expanded(flex: 2, child: _TipoBadge(tipo: d.tipoDocumento)),
              // Emissão
              Expanded(flex: 2, child: Text(_T.fmtData(d.dataEmissao),
                  style: TextStyle(fontSize: 10, color: tc?.withValues(alpha: 0.6),
                      fontFamily: _T.mono))),
              // Vencimento
              Expanded(flex: 2, child: Text(_T.fmtData(d.dataVencimento),
                  style: TextStyle(fontSize: 10, color: tc?.withValues(alpha: 0.6),
                      fontFamily: _T.mono))),
              // Nominal
              Expanded(flex: 3, child: Text(_T.fmtMoeda(d.valorNominal),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: tc, fontFamily: _T.mono))),
              // Taxa desconto
              Expanded(flex: 2, child: Text(_T.fmtPct(d.taxaDesconto),
                  style: TextStyle(fontSize: 10, color: _T.orange,
                      fontFamily: _T.mono, fontWeight: FontWeight.w600))),
              // IOF
              Expanded(flex: 2, child: Text(_T.fmtPct(d.taxaIof),
                  style: TextStyle(fontSize: 10, color: tc?.withValues(alpha: 0.5),
                      fontFamily: _T.mono))),
              // Líquido
              Expanded(flex: 3, child: Text(_T.fmtMoeda(d.valorLiquido),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: _T.green, fontFamily: _T.mono))),
              // Status
              Expanded(flex: 2, child: _StatusBadge(status: d.status)),
              // Ações
              Expanded(flex: 1, child: GestureDetector(
                onTap: onExcluir,
                child: Icon(Icons.close, size: 14,
                    color: tc?.withValues(alpha: 0.25)),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// LISTA VIEW — cards detalhados
// ══════════════════════════════════════════════════════════════
class _DescontoListaView extends StatelessWidget {
  const _DescontoListaView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DescontoController>().state;
    final theme = Theme.of(context);

    if (state.carregando) {
      return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    }
    if (state.estaVazio) return const _EmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: state.descontos.length,
      itemBuilder: (_, i) => _DetalheCard(
        desconto: state.descontos[i],
        onExcluir: () => context
            .read<DescontoController>()
            .excluirDesconto(state.descontos[i].id),
      ),
    );
  }
}

class _DetalheCard extends StatelessWidget {
  final DescontoModel desconto;
  final VoidCallback onExcluir;
  const _DetalheCard({required this.desconto, required this.onExcluir});

  @override
  Widget build(BuildContext context) {
    final d     = desconto;
    final theme = Theme.of(context);
    final tc    = theme.textTheme.bodyMedium?.color;
    final corS  = _T.corStatus(d.status);
    final opac  = d.status == DescontoStatus.expirado ? 0.55 : 1.0;

    return Opacity(
      opacity: opac,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            splashColor: corS.withValues(alpha: 0.05),
            onTap: () {},
            child: Column(children: [
              // ── Cabeçalho ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: corS.withValues(alpha: 0.04),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                  border: Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(children: [
                  _TipoBadge(tipo: d.tipoDocumento),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(d.numeroDocumento,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: tc, letterSpacing: 0.3)),
                  ),
                  _StatusBadge(status: d.status),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onExcluir,
                    child: Icon(Icons.close, size: 14,
                        color: tc?.withValues(alpha: 0.25)),
                  ),
                ]),
              ),
              // ── Corpo ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  // Linha valores
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DetalheItem(label: 'VALOR NOMINAL',
                          valor: _T.fmtMoeda(d.valorNominal),
                          color: tc, tachado: true),
                      Icon(Icons.arrow_forward, size: 14,
                          color: theme.dividerColor),
                      _DetalheItem(label: 'VALOR LÍQUIDO',
                          valor: _T.fmtMoeda(d.valorLiquido),
                          color: _T.green, bold: true, fontSize: 16),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Grid de taxas
                  Row(children: [
                    _DetalheItem(label: 'EMISSÃO',
                        valor: _T.fmtData(d.dataEmissao), color: tc),
                    _DetalheItem(label: 'VENCIMENTO',
                        valor: _T.fmtData(d.dataVencimento), color: tc),
                    _DetalheItem(label: 'TAXA DESC.',
                        valor: _T.fmtPct(d.taxaDesconto), color: _T.orange),
                    _DetalheItem(label: 'IOF',
                        valor: _T.fmtPct(d.taxaIof), color: tc),
                    _DetalheItem(label: 'JUROS',
                        valor: _T.fmtPct(d.taxaJuros), color: tc),
                  ]),
                  const SizedBox(height: 12),
                  // Barra de desconto
                  _BarraDesconto(d: d),
                  const SizedBox(height: 12),
                  // Rodapé cliente
                  Row(children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                      child: Text(d.iniciaisCliente,
                          style: TextStyle(
                              fontSize: 9, color: theme.primaryColor,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(d.nomeCliente,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: tc?.withValues(alpha: 0.65))),
                    ),
                    Text('${d.diasCorridos.toInt()} dias',
                        style: TextStyle(
                            fontSize: 10, color: tc?.withValues(alpha: 0.4),
                            fontFamily: _T.mono)),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _BarraDesconto extends StatelessWidget {
  final DescontoModel d;
  const _BarraDesconto({required this.d});
  @override
  Widget build(BuildContext context) {
    final pct = d.valorNominal > 0
        ? (d.valorLiquido / d.valorNominal).clamp(0.0, 1.0)
        : 0.0;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Aproveitamento líquido',
                style: TextStyle(
                    fontSize: 9,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                    fontFamily: _T.mono)),
            Text('${(pct * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: _T.green, fontFamily: _T.mono)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation(_T.green),
          ),
        ),
      ],
    );
  }
}

class _DetalheItem extends StatelessWidget {
  final String label, valor;
  final Color? color;
  final bool bold, tachado;
  final double fontSize;

  const _DetalheItem({
    required this.label, required this.valor,
    this.color, this.bold = false,
    this.tachado = false, this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
            fontSize: 8, color: Colors.grey,
            fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(valor,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: color,
              decoration: tachado ? TextDecoration.lineThrough : null,
              decorationColor: color,
            )),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// WIDGETS ATÔMICOS
// ══════════════════════════════════════════════════════════════
class _TipoBadge extends StatelessWidget {
  final TipoDocumento tipo;
  const _TipoBadge({required this.tipo});
  @override
  Widget build(BuildContext context) {
    final cor = _T.corTipo(tipo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
      ),
      child: Text(tipo.label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: cor, fontFamily: _T.mono)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DescontoStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final cor = _T.corStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 5, height: 5,
            decoration: BoxDecoration(
                color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(status.label,
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w700,
                color: cor, fontFamily: _T.mono)),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.receipt_long_outlined,
          size: 56, color: Theme.of(context).dividerColor),
      const SizedBox(height: 12),
      const Text('Nenhum título encontrado',
          style: TextStyle(color: Colors.grey, fontSize: 14)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// FORM HELPERS: _FormField, _Input, _DatePicker, _DropTipo
// ══════════════════════════════════════════════════════════════
class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  final int flex;
  const _FormField({required this.label, required this.child, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    final tc = Theme.of(context).textTheme.bodyMedium?.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 8, fontWeight: FontWeight.w700,
                color: tc?.withValues(alpha: 0.4),
                letterSpacing: 1.2, fontFamily: _T.mono)),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isNum;
  final String? Function(String?)? validator;

  const _Input({
    required this.ctrl, required this.hint,
    this.isNum = false, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tc    = theme.textTheme.bodyMedium?.color;
    return TextFormField(
      controller: ctrl,
      validator: validator,
      keyboardType: isNum
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNum
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : [],
      style: TextStyle(fontSize: 12, color: tc, fontFamily: _T.mono),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontSize: 12, color: tc?.withValues(alpha: 0.3),
            fontFamily: _T.mono),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: theme.dividerColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: theme.dividerColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: theme.primaryColor, width: 1.2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: Color(0xFFC62828))),
        errorStyle: const TextStyle(fontSize: 9),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onPicked;
  final DateTime? firstDate;

  const _DatePicker({required this.date, required this.onPicked, this.firstDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tc    = theme.textTheme.bodyMedium?.color;
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: theme.primaryColor),
            ),
            child: child!,
          ),
        );
        if (d != null) onPicked(d);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(children: [
          Icon(Icons.calendar_today_outlined,
              size: 13, color: theme.primaryColor),
          const SizedBox(width: 8),
          Text(_T.fmtData(date),
              style: TextStyle(
                  fontSize: 12, color: tc, fontFamily: _T.mono)),
        ]),
      ),
    );
  }
}

class _DropTipo extends StatelessWidget {
  final TipoDocumento value;
  final ValueChanged<TipoDocumento> onChanged;
  const _DropTipo({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tc    = theme.textTheme.bodyMedium?.color;
    return DropdownButtonFormField<TipoDocumento>(
      value: value,
      dropdownColor: theme.cardColor,
      style: TextStyle(fontSize: 12, color: tc, fontFamily: _T.mono),
      icon: Icon(Icons.keyboard_arrow_down,
          size: 16, color: tc?.withValues(alpha: 0.4)),
      isDense: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        isDense: true,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: theme.dividerColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: theme.dividerColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(color: theme.primaryColor, width: 1.2)),
      ),
      items: TipoDocumento.values.map((t) => DropdownMenuItem(
        value: t,
        child: Row(children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
                color: _T.corTipo(t), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(t.label, overflow: TextOverflow.ellipsis),
        ]),
      )).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}
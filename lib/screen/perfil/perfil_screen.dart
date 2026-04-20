// ─────────────────────────────────────────────
// perfil_screen.dart
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../controllers/perfil_controller.dart';
import '../../model/perfil_model.dart';

// ══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ══════════════════════════════════════════════════════════════
abstract class _T {
  static const teal   = Color(0xFF00BFA5);
  static const green  = Color(0xFF43A047);
  static const orange = Color(0xFFEF6C00);
  static const red    = Color(0xFFC62828);
  static const blue   = Color(0xFF4FC3F7);
  static const mono   = 'monospace';
}

// ══════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════
class PerfilScreen extends StatefulWidget {
  /// [userId] deve ser passado pela rota após o login.
  const PerfilScreen({super.key, required this.userId});

  final String userId;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // ── Modo edição ───────────────────────────────────────
  bool _editando = false;

  // ── Controllers de texto ─────────────────────────────
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _sobrenomeCtrl;
  late final TextEditingController _telCtrl;
  late final TextEditingController _cepCtrl;
  late final TextEditingController _logradouroCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _complementoCtrl;
  late final TextEditingController _bairroCtrl;
  late final TextEditingController _municipioCtrl;
  late final TextEditingController _estadoCtrl;

  DateTime? _dataNascimento;

  @override
  void initState() {
    super.initState();
    _nomeCtrl        = TextEditingController();
    _sobrenomeCtrl   = TextEditingController();
    _telCtrl         = TextEditingController();
    _cepCtrl         = TextEditingController();
    _logradouroCtrl  = TextEditingController();
    _numeroCtrl      = TextEditingController();
    _complementoCtrl = TextEditingController();
    _bairroCtrl      = TextEditingController();
    _municipioCtrl   = TextEditingController();
    _estadoCtrl      = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerfilController>().carregarPerfil(widget.userId);
    });
  }

  @override
  void dispose() {
    for (final c in [
      _nomeCtrl, _sobrenomeCtrl, _telCtrl, _cepCtrl,
      _logradouroCtrl, _numeroCtrl, _complementoCtrl,
      _bairroCtrl, _municipioCtrl, _estadoCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Popula os controllers com os dados do perfil ──────
  void _preencherControllers(PerfilModel p) {
    _nomeCtrl.text        = p.nome;
    _sobrenomeCtrl.text   = p.sobrenome;
    _telCtrl.text         = p.telefone ?? '';
    _cepCtrl.text         = _fmtCep(p.endereco.cep);
    _logradouroCtrl.text  = p.endereco.logradouro;
    _numeroCtrl.text      = p.endereco.numero;
    _complementoCtrl.text = p.endereco.complemento;
    _bairroCtrl.text      = p.endereco.bairro;
    _municipioCtrl.text   = p.endereco.municipio;
    _estadoCtrl.text      = p.endereco.estado;
    _dataNascimento       = p.dataNascimento;
  }

  // ── Constrói um PerfilModel a partir dos controllers ──
  PerfilModel _perfilAtualizado(PerfilModel original) =>
      original.copyWith(
        nome: _nomeCtrl.text.trim(),
        sobrenome: _sobrenomeCtrl.text.trim(),
        telefone: _telCtrl.text.trim(),
        dataNascimento: _dataNascimento,
        endereco: original.endereco.copyWith(
          cep: _cepCtrl.text.replaceAll(RegExp(r'\D'), ''),
          logradouro: _logradouroCtrl.text.trim(),
          numero: _numeroCtrl.text.trim(),
          complemento: _complementoCtrl.text.trim(),
          bairro: _bairroCtrl.text.trim(),
          municipio: _municipioCtrl.text.trim(),
          estado: _estadoCtrl.text.trim(),
        ),
      );

  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ctrl   = context.watch<PerfilController>();

    // Preenche ao carregar pela primeira vez
    if (ctrl.perfil != null && !_editando &&
        _nomeCtrl.text.isEmpty) {
      _preencherControllers(ctrl.perfil!);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _appBar(context, theme, isDark, ctrl),
      body: ctrl.carregando
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : ctrl.perfil == null
          ? _erroState(context, ctrl)
          : _body(context, theme, ctrl),
    );
  }

  // ══════════════════════════════════════════════════════
  //  APP BAR
  // ══════════════════════════════════════════════════════
  PreferredSizeWidget _appBar(
      BuildContext context,
      ThemeData theme,
      bool isDark,
      PerfilController ctrl,
      ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle:
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new,
            color: theme.primaryColor, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(children: [
        Container(
          width: 3, height: 22,
          decoration: BoxDecoration(
            color: _T.teal,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'MEU PERFIL',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
      ]),
      actions: [
        if (!_editando)
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: _T.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _T.teal.withValues(alpha: 0.3)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: const Icon(Icons.edit_outlined, color: _T.teal),
              onPressed: () => setState(() => _editando = true),
              tooltip: 'Editar perfil',
            ),
          )
        else ...[
          // Cancelar
          GestureDetector(
            onTap: () {
              _preencherControllers(ctrl.perfil!);
              setState(() => _editando = false);
            },
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Center(
                child: Text('CANCELAR',
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.54),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    )),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Salvar
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ctrl.salvando
                ? const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
                : IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: Icon(
                Icons.check,
                color: theme.primaryColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              ),
              onPressed: () => _salvar(context, ctrl),
              tooltip: 'Salvar alterações',
            ),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  //  BODY
  // ══════════════════════════════════════════════════════
  Widget _body(BuildContext context, ThemeData theme, PerfilController ctrl) {
    final p = ctrl.perfil!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        const SizedBox(height: 8),
        _avatarSection(theme, p),
        const SizedBox(height: 20),
        _secaoLabel(context, 'INFORMAÇÕES PESSOAIS'),
        const SizedBox(height: 12),
        _camposGrid([
          _campo(context, _nomeCtrl, 'Nome', Icons.person_outline),
          _campo(context, _sobrenomeCtrl, 'Sobrenome', Icons.person_outline),
          _campoData(context, theme),
          _campo(context, _telCtrl, 'Telefone', Icons.phone_outlined,
              keyboard: TextInputType.phone,
              hint: '(00) 00000-0000',
              mono: true),
        ]),
        const SizedBox(height: 20),
        _secaoLabel(context, 'CREDENCIAIS DE ACESSO'),
        const SizedBox(height: 12),
        _campoEmail(context, theme, p.email),
        const SizedBox(height: 10),
        _campoSenha(context, theme, p),
        const SizedBox(height: 20),
        _secaoLabel(context, 'ENDEREÇO'),
        const SizedBox(height: 12),
        _camposGrid([
          _campoCep(context, theme, ctrl),
          _campo(context, _numeroCtrl, 'Número', Icons.tag_outlined,
              hint: 'Nº'),
        ]),
        const SizedBox(height: 10),
        _campo(context, _logradouroCtrl, 'Logradouro', Icons.signpost_outlined,
            hint: 'Rua, Av., Travessa...'),
        const SizedBox(height: 10),
        _camposGrid([
          _campo(context, _bairroCtrl, 'Bairro', Icons.location_on_outlined),
          _campo(context, _complementoCtrl, 'Complemento',
              Icons.apartment_outlined,
              hint: 'Apto, Bloco...'),
        ]),
        const SizedBox(height: 10),
        _camposGrid([
          _campoReadOnly(context, _municipioCtrl, 'Município',
              Icons.location_city_outlined),
          _campoReadOnly(context, _estadoCtrl, 'Estado',
              Icons.map_outlined),
        ]),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  //  AVATAR
  // ══════════════════════════════════════════════════════
  Widget _avatarSection(ThemeData theme, PerfilModel p) {
    final ctrl = context.read<PerfilController>();
    return Row(children: [
      Stack(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withValues(alpha: 0.8),
                  theme.primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              image: p.fotoUrl != null 
                ? DecorationImage(
                    image: NetworkImage(p.fotoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: p.fotoUrl == null 
              ? Center(
                  child: Text(
                    p.iniciais,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800),
                  ),
                )
              : null,
          ),
          if (ctrl.subindoFoto)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: -2,
            right: -2,
            child: GestureDetector(
              onTap: () => _pickImage(context, ctrl),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _T.teal,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                ),
                child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.nomeCompleto.toUpperCase(),
              style: TextStyle(
                color: theme.textTheme.titleMedium?.color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if ((p.cargo ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '${p.cargo}${(p.departamento ?? '').isNotEmpty ? ' · ${p.departamento}' : ''}',
                style: TextStyle(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.5),
                    fontSize: 12),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              p.email,
              style: TextStyle(
                  color: _T.blue,
                  fontSize: 12,
                  fontFamily: _T.mono),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════
  //  SEÇÃO LABEL
  // ══════════════════════════════════════════════════════
  Widget _secaoLabel(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Row(children: [
      Container(
        width: 3, height: 14,
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
    ]);
  }

  // ══════════════════════════════════════════════════════
  //  CAMPOS UTILITÁRIOS
  // ══════════════════════════════════════════════════════
  Widget _camposGrid(List<Widget> children) {
    return LayoutBuilder(builder: (_, c) {
      final isWide = c.maxWidth > 400;
      if (isWide) {
        return Row(children: children
            .asMap()
            .entries
            .map((e) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: e.key < children.length - 1 ? 10 : 0),
            child: e.value,
          ),
        ))
            .toList());
      }
      return Column(
        children: children
            .map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: w,
        ))
            .toList(),
      );
    });
  }

  Widget _campo(
      BuildContext context,
      TextEditingController ctrl,
      String label,
      IconData icon, {
        TextInputType keyboard = TextInputType.text,
        String? hint,
        bool mono = false,
      }) {
    final theme = Theme.of(context);
    return _fieldBox(
      theme,
      enabled: _editando,
      child: Row(children: [
        Icon(icon,
            size: 16,
            color: _editando
                ? theme.primaryColor
                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _fieldLabel(theme, label),
              TextField(
                controller: ctrl,
                enabled: _editando,
                keyboardType: keyboard,
                style: TextStyle(
                  color: _editando
                      ? theme.textTheme.bodyMedium?.color
                      : theme.textTheme.bodyMedium?.color
                      ?.withValues(alpha: 0.54),
                  fontSize: 13,
                  fontFamily: mono ? _T.mono : null,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.2),
                      fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _campoReadOnly(
      BuildContext context,
      TextEditingController ctrl,
      String label,
      IconData icon,
      ) {
    final theme = Theme.of(context);
    return _fieldBox(
      theme,
      enabled: false,
      readOnly: true,
      child: Row(children: [
        Icon(icon,
            size: 16,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.25)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _fieldLabel(theme, label),
              TextField(
                controller: ctrl,
                enabled: false,
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.54),
                    fontSize: 13),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _campoData(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: _editando
          ? () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dataNascimento ?? DateTime(1990),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          locale: const Locale('pt', 'BR'),
          builder: (ctx, child) => Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: _T.teal,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _dataNascimento = picked);
      }
          : null,
      child: _fieldBox(
        theme,
        enabled: _editando,
        child: Row(children: [
          Icon(Icons.cake_outlined,
              size: 16,
              color: _editando
                  ? theme.primaryColor
                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _fieldLabel(theme, 'Data de Nascimento'),
                Text(
                  _dataNascimento != null
                      ? '${_dataNascimento!.day.toString().padLeft(2, '0')}/'
                      '${_dataNascimento!.month.toString().padLeft(2, '0')}/'
                      '${_dataNascimento!.year}'
                      : 'DD/MM/AAAA',
                  style: TextStyle(
                    color: _dataNascimento != null
                        ? theme.textTheme.bodyMedium?.color
                        : theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.3),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (_editando)
            Icon(Icons.calendar_today_outlined,
                size: 14,
                color: _T.teal.withValues(alpha: 0.6)),
        ]),
      ),
    );
  }

  Widget _campoEmail(BuildContext context, ThemeData theme, String email) {
    return _fieldBox(
      theme,
      enabled: false,
      readOnly: true,
      child: Row(children: [
        Icon(Icons.email_outlined,
            size: 16,
            color:
            theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.25)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _fieldLabel(theme, 'E-MAIL (LOGIN)'),
              Text(
                email,
                style: TextStyle(
                    color: _T.blue,
                    fontSize: 12,
                    fontFamily: _T.mono),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: _T.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: _T.blue.withValues(alpha: 0.25)),
          ),
          child: Text('FIXO',
              style: TextStyle(
                  color: _T.blue,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
        ),
      ]),
    );
  }

  Widget _campoSenha(BuildContext context, ThemeData theme, PerfilModel p) {
    return _fieldBox(
      theme,
      enabled: false,
      readOnly: true,
      child: Row(children: [
        Icon(Icons.lock_outline,
            size: 16,
            color:
            theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.25)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _fieldLabel(theme, 'SENHA'),
              Text(
                '••••••••••••',
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.45),
                    fontSize: 16,
                    letterSpacing: 3,
                    fontFamily: _T.mono),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showAlterarSenha(context, p),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _T.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _T.orange.withValues(alpha: 0.25)),
            ),
            child: const Icon(Icons.lock_reset_outlined,
                size: 17, color: _T.orange),
          ),
        ),
      ]),
    );
  }

  Widget _campoCep(BuildContext context, ThemeData theme,
      PerfilController ctrl) {
    return _fieldBox(
      theme,
      enabled: _editando,
      child: Row(children: [
        Icon(Icons.location_on_outlined,
            size: 16,
            color: _editando
                ? theme.primaryColor
                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _fieldLabel(theme, 'CEP'),
              TextField(
                controller: _cepCtrl,
                enabled: _editando,
                keyboardType: TextInputType.number,
                inputFormatters: [_CepFormatter()],
                style: TextStyle(
                    color: _editando
                        ? theme.textTheme.bodyMedium?.color
                        : theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.54),
                    fontSize: 13,
                    fontFamily: _T.mono),
                decoration: const InputDecoration(
                    hintText: '00000-000',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
        ),
        if (_editando)
          GestureDetector(
            onTap: ctrl.buscandoCep
                ? null
                : () => _buscarCep(context, ctrl),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: ctrl.buscandoCep
                    ? _T.teal.withValues(alpha: 0.05)
                    : _T.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _T.teal.withValues(alpha: 0.25)),
              ),
              child: ctrl.buscandoCep
                  ? const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                    color: _T.teal, strokeWidth: 2),
              )
                  : const Icon(Icons.search, size: 16, color: _T.teal),
            ),
          ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════
  //  CAMPO BASE
  // ══════════════════════════════════════════════════════
  Widget _fieldBox(
      ThemeData theme, {
        required Widget child,
        bool enabled = true,
        bool readOnly = false,
      }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: readOnly
            ? theme.dividerColor.withValues(alpha: 0.04)
            : enabled
            ? theme.cardColor
            : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled && !readOnly
              ? theme.dividerColor
              : theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }

  Widget _fieldLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: TextStyle(
          color:
          theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }

  // ══════════════════════════════════════════════════════
  //  ESTADO DE ERRO (sem perfil)
  // ══════════════════════════════════════════════════════
  Widget _erroState(BuildContext context, PerfilController ctrl) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.15),
              size: 56),
          const SizedBox(height: 12),
          Text(
            ctrl.erro ?? 'Não foi possível carregar o perfil.',
            style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
                fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => ctrl.carregarPerfil(widget.userId),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Tentar novamente'),
            style: TextButton.styleFrom(foregroundColor: _T.teal),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  AÇÕES
  // ══════════════════════════════════════════════════════
  Future<void> _salvar(BuildContext context, PerfilController ctrl) async {
    final nome = _nomeCtrl.text.trim();
    final sob  = _sobrenomeCtrl.text.trim();
    if (nome.isEmpty || sob.isEmpty) {
      _showSnack(context, 'Nome e sobrenome são obrigatórios.', erro: true);
      return;
    }

    final atualizado = _perfilAtualizado(ctrl.perfil!);
    final ok = await ctrl.salvarPerfil(atualizado);

    if (!mounted) return;
    _showSnack(context,
        ok ? 'Perfil atualizado!' : ctrl.erro ?? 'Erro ao salvar',
        erro: !ok);
    if (ok) setState(() => _editando = false);
  }

  Future<void> _buscarCep(BuildContext context, PerfilController ctrl) async {
    final endereco = await ctrl.buscarCep(_cepCtrl.text);
    if (!mounted) return;
    if (endereco != null) {
      setState(() {
        _logradouroCtrl.text = endereco.logradouro;
        _bairroCtrl.text    = endereco.bairro;
        _municipioCtrl.text = endereco.municipio;
        _estadoCtrl.text    = endereco.estado;
      });
      _showSnack(context, 'Endereço preenchido!');
    } else {
      _showSnack(context, ctrl.erro ?? 'CEP não encontrado.', erro: true);
    }
  }

  Future<void> _pickImage(BuildContext context, PerfilController ctrl) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 512,
    );

    if (image != null) {
      final ok = await ctrl.uploadFoto(File(image.path));
      if (!mounted) return;
      _showSnack(context, ok ? 'Foto atualizada!' : (ctrl.erro ?? 'Erro no upload'), erro: !ok);
    }
  }

  // ══════════════════════════════════════════════════════
  //  MODAL ALTERAR SENHA
  // ══════════════════════════════════════════════════════
  void _showAlterarSenha(BuildContext context, PerfilModel p) {
    final theme   = Theme.of(context);
    final atualCtrl  = TextEditingController();
    final novaCtrl   = TextEditingController();
    final confirCtrl = TextEditingController();
    bool  obscAtual  = true;
    bool  obscNova   = true;
    bool  obscConf   = true;
    double forca     = 0;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: StatefulBuilder(builder: (ctx, setS) {
          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── Header ─────────────────────────────────
              _dialogHeader(context, 'ALTERAR SENHA',
                      () => Navigator.pop(ctx)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  // Ícone
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _T.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_outlined,
                        color: _T.orange, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A nova senha deve ter no mínimo 8 caracteres,\ncombinando letras, números e símbolos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.45),
                        fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  // Senha atual
                  _pwdField(
                    context,
                    ctrl: atualCtrl,
                    label: 'SENHA ATUAL',
                    icon: Icons.lock_outline,
                    obscure: obscAtual,
                    onToggle: () => setS(() => obscAtual = !obscAtual),
                  ),
                  const SizedBox(height: 10),

                  // Nova senha + barra de força
                  _pwdField(
                    context,
                    ctrl: novaCtrl,
                    label: 'NOVA SENHA',
                    icon: Icons.lock_open_outlined,
                    obscure: obscNova,
                    onToggle: () => setS(() => obscNova = !obscNova),
                    onChanged: (v) =>
                        setS(() => forca = _forca(v)),
                  ),
                  const SizedBox(height: 6),
                  _barraForca(forca),
                  const SizedBox(height: 10),

                  // Confirmar
                  _pwdField(
                    context,
                    ctrl: confirCtrl,
                    label: 'CONFIRMAR NOVA SENHA',
                    icon: Icons.check_circle_outline,
                    obscure: obscConf,
                    onToggle: () => setS(() => obscConf = !obscConf),
                  ),
                  const SizedBox(height: 24),

                  // Botões
                  Row(children: [
                    Expanded(
                        child: _btnCancelar(
                            context, () => Navigator.pop(ctx))),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: Consumer<PerfilController>(
                        builder: (_, ctrl, __) => _btnAcao(
                          context,
                          label: ctrl.alterandoSenha
                              ? 'AGUARDE...'
                              : 'CONFIRMAR',
                          cor: _T.orange,
                          onTap: ctrl.alterandoSenha
                              ? null
                              : () async {
                            final ok =
                            await ctrl.alterarSenha(
                              senhaAtual: atualCtrl.text,
                              novaSenha: novaCtrl.text,
                              confirmacao: confirCtrl.text,
                            );
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            _showSnack(
                              context,
                              ok
                                  ? 'Senha alterada com sucesso!'
                                  : ctrl.erro ?? 'Erro',
                              erro: !ok,
                            );
                          },
                        ),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  WIDGETS AUXILIARES DO DIALOG
  // ══════════════════════════════════════════════════════
  Widget _dialogHeader(
      BuildContext context, String titulo, VoidCallback onClose) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          border:
          Border(bottom: BorderSide(color: theme.dividerColor))),
      child: Row(children: [
        Container(
          width: 3, height: 20,
          decoration: BoxDecoration(
            color: _T.teal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(titulo,
            style: TextStyle(
                color: theme.textTheme.titleMedium?.color,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                fontSize: 13)),
        const Spacer(),
        GestureDetector(
          onTap: onClose,
          child: Icon(Icons.close,
              color: theme.textTheme.bodyMedium?.color
                  ?.withValues(alpha: 0.4),
              size: 20),
        ),
      ]),
    );
  }

  Widget _pwdField(
      BuildContext context, {
        required TextEditingController ctrl,
        required String label,
        required IconData icon,
        required bool obscure,
        required VoidCallback onToggle,
        ValueChanged<String>? onChanged,
      }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(children: [
        const SizedBox(width: 12),
        Icon(icon, size: 16, color: theme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(label,
                    style: TextStyle(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2)),
              ),
              TextField(
                controller: ctrl,
                obscureText: obscure,
                onChanged: onChanged,
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: 14,
                    fontFamily: _T.mono),
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                    EdgeInsets.only(bottom: 10)),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onToggle,
          iconSize: 16,
          icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: theme.textTheme.bodyMedium?.color
                  ?.withValues(alpha: 0.35)),
        ),
      ]),
    );
  }

  Widget _barraForca(double forca) {
    Color cor;
    String label;
    if (forca <= 0) {
      cor = Colors.transparent; label = '';
    } else if (forca < 0.4) {
      cor = _T.red;   label = 'Fraca';
    } else if (forca < 0.7) {
      cor = _T.orange; label = 'Média';
    } else if (forca < 1.0) {
      cor = const Color(0xFFFDD835); label = 'Boa';
    } else {
      cor = _T.green;  label = 'Forte';
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: forca,
          minHeight: 4,
          backgroundColor:
          const Color(0xFF9E9E9E).withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation(cor),
        ),
      ),
      if (label.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: cor, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    ]);
  }

  double _forca(String senha) {
    double s = 0;
    if (senha.length >= 8)                 s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(senha))  s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(senha))  s += 0.25;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(senha)) s += 0.25;
    return s;
  }

  // ══════════════════════════════════════════════════════
  //  BOTÕES REUTILIZÁVEIS
  // ══════════════════════════════════════════════════════
  Widget _btnCancelar(BuildContext context, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.dividerColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text('CANCELAR',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.54),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5)),
      ),
    );
  }

  Widget _btnAcao(
      BuildContext context, {
        required String label,
        required Color cor,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: onTap == null ? cor.withValues(alpha: 0.4) : cor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: onTap == null
                    ? Colors.black45
                    : (cor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  SNACKBAR
  // ══════════════════════════════════════════════════════
  void _showSnack(BuildContext context, String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          erro ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white, size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: erro ? _T.red : _T.green,
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ══════════════════════════════════════════════════════
  //  HELPERS GERAIS
  // ══════════════════════════════════════════════════════
  String _fmtCep(String cep) {
    final raw = cep.replaceAll(RegExp(r'\D'), '');
    if (raw.length == 8) {
      return '${raw.substring(0, 5)}-${raw.substring(5)}';
    }
    return cep;
  }
}

// ══════════════════════════════════════════════════════════════
// INPUT FORMATTER — CEP
// ══════════════════════════════════════════════════════════════
class _CepFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    final formatted = limited.length > 5
        ? '${limited.substring(0, 5)}-${limited.substring(5)}'
        : limited;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
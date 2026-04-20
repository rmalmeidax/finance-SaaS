import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/usuario_controller.dart';
import '../../widgets/dashboard_resumo_card_widget.dart';
import '../../model/usuario_model.dart';

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

  static Color corStatus(StatusUsuario s) {
    switch (s) {
      case StatusUsuario.ativo:     return green;
      case StatusUsuario.pendente:  return orange;
      case StatusUsuario.bloqueado: return const Color(0xFF9E9E9E);
      case StatusUsuario.inativo:   return red;
    }
  }

  static Color corPerfil(PerfilUsuario p) {
    switch (p) {
      case PerfilUsuario.administrador: return const Color(0xFFB39DDB);
      case PerfilUsuario.gerente:       return const Color(0xFF4FC3F7);
      case PerfilUsuario.operador:      return green;
      case PerfilUsuario.visualizador:  return const Color(0xFF9E9E9E);
    }
  }

  static String fmtInt(int v) => v.toString();
}

class UsuarioScreen extends StatelessWidget {
  const UsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UsuarioController>(context);
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
                color: _T.teal,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'USUÁRIOS',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
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
              icon: Icon(Icons.person_add_outlined, 
                  color: theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
              onPressed: () => _showDialog(context, controller),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── SEARCH ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor),
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
                  hintText: 'Buscar por nome, e-mail, cargo ou departamento...',
                  hintStyle:
                  TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3), fontSize: 14),
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

          // ── DASHBOARD ───────────────────────────────────
          _buildDashboard(context, controller),

          const SizedBox(height: 16),

          // ── FILTROS STATUS ───────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _chip(context, 'Todos',
                    controller.filtroStatus == FiltroStatusU.todos,
                        () => controller.setFiltroStatus(FiltroStatusU.todos)),
                const SizedBox(width: 8),
                _chipColor(context, 'Ativo', controller.filtroStatus == FiltroStatusU.ativo,
                    _T.green,
                        () => controller.setFiltroStatus(FiltroStatusU.ativo)),
                const SizedBox(width: 8),
                _chipColor(context, 'Inativo',
                    controller.filtroStatus == FiltroStatusU.inativo,
                    _T.red,
                        () => controller.setFiltroStatus(FiltroStatusU.inativo)),
                const SizedBox(width: 8),
                _chipColor(context, 'Pendente',
                    controller.filtroStatus == FiltroStatusU.pendente,
                    _T.orange,
                        () => controller.setFiltroStatus(FiltroStatusU.pendente)),
                const SizedBox(width: 8),
                _chipColor(context, 'Bloqueado',
                    controller.filtroStatus == FiltroStatusU.bloqueado,
                    const Color(0xFF9E9E9E),
                        () => controller.setFiltroStatus(FiltroStatusU.bloqueado)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── FILTROS PERFIL ───────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: PerfilUsuario.values.map((p) {
                final selecionado = controller.filtroPerfil.name == p.name;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _chip(context, p.label, selecionado,
                          () => controller.setFiltroPerfil(
                          FiltroPerfil.values.firstWhere(
                                (f) => f.name == p.name,
                            orElse: () => FiltroPerfil.todos,
                          ))),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── LISTA ────────────────────────────────────────
          Expanded(
            child: controller.carregando
                ? Center(
              child: CircularProgressIndicator(
                  color: theme.primaryColor),
            )
                : controller.usuarios.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.12),
                      size: 60),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum usuário encontrado',
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
              itemCount: controller.usuarios.length,
              itemBuilder: (_, i) => _buildCard(
                  context, controller.usuarios[i], controller),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  DASHBOARD
  // ══════════════════════════════════════════════════════════

  Widget _buildDashboard(BuildContext context, UsuarioController c) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600;
        
        if (isWide) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: DashboardResumoCardWidget(title: 'TOTAL', value: '${c.usuarios.length}', color: _T.teal, icon: Icons.people_outline)),
                const SizedBox(width: 10),
                Expanded(child: DashboardResumoCardWidget(title: 'ATIVOS', value: '${c.totalAtivos}', color: _T.green, icon: Icons.check_circle_outline)),
                const SizedBox(width: 10),
                Expanded(child: DashboardResumoCardWidget(title: 'ADMINS', value: '${c.totalAdmins}', color: const Color(0xFF4FC3F7), icon: Icons.admin_panel_settings_outlined)),
                const SizedBox(width: 10),
                Expanded(child: DashboardResumoCardWidget(title: 'PENDENTES', value: '${c.totalPendentes}', color: _T.orange, icon: Icons.hourglass_empty_outlined)),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: DashboardResumoCardWidget(title: 'TOTAL', value: '${c.usuarios.length}', color: _T.teal, icon: Icons.people_outline)),
                    const SizedBox(width: 10),
                    Expanded(child: DashboardResumoCardWidget(title: 'ATIVOS', value: '${c.totalAtivos}', color: _T.green, icon: Icons.check_circle_outline)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: DashboardResumoCardWidget(title: 'ADMINS', value: '${c.totalAdmins}', color: const Color(0xFF4FC3F7), icon: Icons.admin_panel_settings_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: DashboardResumoCardWidget(title: 'PENDENTES', value: '${c.totalPendentes}', color: _T.orange, icon: Icons.hourglass_empty_outlined)),
                  ],
                ),
              ],
            ),
          );
        }
      }
    );
  }

  // ══════════════════════════════════════════════════════════
  //  CARD DO USUÁRIO
  // ══════════════════════════════════════════════════════════

  Widget _buildCard(
      BuildContext context, Usuario u, UsuarioController controller) {
    final theme = Theme.of(context);
    final statusColor = _T.corStatus(u.status);
    final perfilColor = _T.corPerfil(u.perfil);
    final isAtivo = u.status == StatusUsuario.ativo;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // ── Header do card ────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border:
              Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                // Avatar com iniciais
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor.withValues(alpha: 0.8), theme.primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      u.iniciais,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
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
                        u.nomeCompleto.toUpperCase(),
                        style: TextStyle(
                            color: theme.textTheme.titleMedium?.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((u.cargo ?? '').isNotEmpty)
                        Text(
                          u.cargo!,
                          style: TextStyle(
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                              fontSize: 11),
                        ),
                    ],
                  ),
                ),

                // Badge perfil
                _badge(u.perfil.label, perfilColor),
                const SizedBox(width: 6),
                // Badge status
                _badge(u.status.label.toUpperCase(), statusColor),

                // Indicador primeiro acesso
                if (u.primeiroAcesso) ...[
                  const SizedBox(width: 6),
                  Tooltip(
                    message: 'Aguardando primeiro acesso',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _T.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: _T.orange.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.schedule,
                          size: 12, color: _T.orange),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Corpo do card ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _infoItem(context, Icons.email_outlined, 'E-MAIL', u.email),
                    _infoItem(
                        context,
                        Icons.phone_outlined,
                        'TELEFONE',
                        u.telefone?.isEmpty ?? true ? '—' : u.telefone!),
                    _infoItem(
                        context,
                        Icons.corporate_fare_outlined,
                        'DEPARTAMENTO',
                        u.departamento?.isEmpty ?? true
                            ? '—'
                            : u.departamento!),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Ações ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Editar
                    _actionButton(
                      context,
                      icon: Icons.edit_outlined,
                      tooltip: 'Editar',
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                      iconColor: const Color(0xFF4FC3F7),
                      onTap: () =>
                          _showDialog(context, controller, usuario: u),
                    ),
                    const SizedBox(width: 8),

                    // Redefinir senha
                    _actionButton(
                      context,
                      icon: Icons.lock_reset_outlined,
                      tooltip: 'Redefinir Senha',
                      color: _T.orange.withValues(alpha: 0.1),
                      iconColor: _T.orange,
                      onTap: () => _confirmRedefinirSenha(
                          context, u, controller),
                    ),
                    const SizedBox(width: 8),

                    // Toggle ativo/inativo
                    _actionButton(
                      context,
                      icon: isAtivo
                          ? Icons.toggle_on_outlined
                          : Icons.toggle_off_outlined,
                      tooltip: isAtivo ? 'Inativar' : 'Ativar',
                      color: isAtivo
                          ? _T.red.withValues(alpha: 0.1)
                          : _T.green.withValues(alpha: 0.1),
                      iconColor: isAtivo
                          ? _T.red
                          : _T.green,
                      onTap: () => controller.alterarStatus(
                        u.id,
                        isAtivo ? StatusUsuario.inativo : StatusUsuario.ativo,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Excluir
                    _actionButton(
                      context,
                      icon: Icons.person_remove_outlined,
                      tooltip: 'Excluir',
                      color: Colors.red.withValues(alpha: 0.1),
                      iconColor: Colors.red.withValues(alpha: 0.6),
                      onTap: () =>
                          _confirmDelete(context, u, controller),
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

  // ══════════════════════════════════════════════════════════
  //  DIALOGS
  // ══════════════════════════════════════════════════════════

  // ── Confirmar exclusão ───────────────────────────────────
  void _confirmDelete(
      BuildContext context, Usuario u, UsuarioController controller) {
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _T.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: _T.red, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Excluir Usuário',
                  style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Tem certeza que deseja remover ${u.nomeCompleto} do sistema?\nEsta ação não pode ser desfeita.',
                textAlign: TextAlign.center,
                style:
                TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _btnCancelar(context, () => Navigator.pop(context))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _btnAcao(
                      context,
                      label: 'EXCLUIR',
                      cor: _T.red,
                      onTap: () async {
                        Navigator.pop(context);
                        await controller.excluir(u.id);
                        if (context.mounted) {
                          _showSnack(context, controller.sucesso ?? controller.erro ?? '',
                              erro: controller.erro != null);
                        }
                      },
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

  // ── Confirmar redefinição de senha ───────────────────────
  void _confirmRedefinirSenha(
      BuildContext context, Usuario u, UsuarioController controller) {
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _T.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset_outlined,
                    color: _T.orange, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Redefinir Senha',
                  style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Um e-mail de redefinição de senha será enviado para:\n${u.email}',
                textAlign: TextAlign.center,
                style:
                TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _btnCancelar(context, () => Navigator.pop(context))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _btnAcao(
                      context,
                      label: 'ENVIAR',
                      cor: _T.orange,
                      onTap: () async {
                        Navigator.pop(context);
                        final ok =
                        await controller.redefinirSenha(u.email);
                        if (context.mounted) {
                          _showSnack(
                            context,
                            ok
                                ? 'E-mail enviado para ${u.email}'
                                : controller.erro ?? 'Erro ao enviar e-mail',
                            erro: !ok,
                          );
                        }
                      },
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

  // ══════════════════════════════════════════════════════════
  //  DIALOG CADASTRO / EDIÇÃO
  // ══════════════════════════════════════════════════════════

  void _showDialog(
      BuildContext context,
      UsuarioController controller, {
        Usuario? usuario,
      }) {
    final theme = Theme.of(context);

    final nomeCtrl =
    TextEditingController(text: usuario?.nome ?? '');
    final sobrenomeCtrl =
    TextEditingController(text: usuario?.sobrenome ?? '');
    final emailCtrl =
    TextEditingController(text: usuario?.email ?? '');
    final senhaCtrl = TextEditingController(
        text: '••••••••••••');
    final telefoneCtrl =
    TextEditingController(text: usuario?.telefone ?? '');
    final cargoCtrl =
    TextEditingController(text: usuario?.cargo ?? '');
    final deptCtrl =
    TextEditingController(text: usuario?.departamento ?? '');
    final obsCtrl =
    TextEditingController(text: usuario?.observacao ?? '');

    PerfilUsuario perfilSel =
        usuario?.perfil ?? PerfilUsuario.operador;
    StatusUsuario statusSel =
        usuario?.status ?? StatusUsuario.pendente;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: StatefulBuilder(builder: (ctx, setState) {
          return Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ────────────────────────────────
                _dialogHeader(
                  context,
                  titulo: usuario == null
                      ? 'NOVO USUÁRIO'
                      : 'EDITAR USUÁRIO',
                  onClose: () => Navigator.pop(ctx),
                ),

                // ── Corpo ─────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Credenciais (email + senha bloqueados) ──
                        _labelSection(context, 'CREDENCIAIS DE ACESSO'),
                        const SizedBox(height: 10),

                        // Email — bloqueado/pré-preenchido
                        _inputField(
                          context,
                          emailCtrl,
                          'E-mail',
                          Icons.email_outlined,
                          enabled: usuario == null, // só editável no cadastro
                          keyboardType: TextInputType.emailAddress,
                          hint: 'usuario@empresa.com',
                        ),
                        const SizedBox(height: 10),

                        // Senha — sempre bloqueada + botão trocar
                        Row(
                          children: [
                            Expanded(
                              child: _inputField(
                                context,
                                senhaCtrl,
                                'Senha',
                                Icons.lock_outline,
                                enabled: false, // SEMPRE bloqueado
                                obscureText: true,
                                hint: '••••••••••••',
                                suffixText: usuario == null
                                    ? 'Gerada automaticamente'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Botão trocar senha
                            Tooltip(
                              message: 'Enviar e-mail de redefinição de senha',
                              child: GestureDetector(
                                onTap: usuario == null
                                    ? null
                                    : () {
                                  Navigator.pop(ctx);
                                  _confirmRedefinirSenha(
                                      context, usuario, controller);
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: usuario == null
                                        ? theme.dividerColor.withValues(alpha: 0.1)
                                        : _T.orange,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: usuario == null
                                          ? theme.dividerColor
                                          : _T.orange
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.lock_reset_outlined,
                                    color: usuario == null
                                        ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2)
                                        : Colors.black,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Info — senha gerada automaticamente
                        if (usuario == null) ...[
                          const SizedBox(height: 8),
                          _infoBox(
                            icon: Icons.info_outline,
                            cor: const Color(0xFF4FC3F7),
                            texto:
                            'A senha temporária será gerada automaticamente e um e-mail de redefinição será enviado ao usuário.',
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── Dados pessoais ─────────────────
                        _labelSection(context, 'INFORMAÇÕES PESSOAIS'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _inputField(
                                  context, nomeCtrl, 'Nome', Icons.person_outline),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _inputField(context, sobrenomeCtrl,
                                  'Sobrenome', Icons.person_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _inputField(
                          context,
                          telefoneCtrl,
                          'Telefone',
                          Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          hint: '(00) 00000-0000',
                        ),

                        const SizedBox(height: 20),

                        // ── Cargo / Departamento ───────────
                        _labelSection(context, 'FUNÇÃO'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _inputField(
                                  context,
                                  cargoCtrl, 'Cargo',
                                  Icons.work_outline,
                                  hint: 'Ex: Analista Financeiro'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _inputField(
                                  context,
                                  deptCtrl, 'Departamento',
                                  Icons.corporate_fare_outlined,
                                  hint: 'Ex: Financeiro'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Perfil de acesso ───────────────
                        _labelSection(context, 'PERFIL DE ACESSO'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PerfilUsuario.values.map((p) {
                            final sel = perfilSel == p;
                            final cor = _T.corPerfil(p);
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => perfilSel = p),
                              child: AnimatedContainer(
                                duration:
                                const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                  color: sel
                                      ? cor.withValues(alpha: 0.15)
                                      : theme.scaffoldBackgroundColor,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  border: Border.all(
                                    color: sel
                                        ? cor
                                        : theme.dividerColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_perfilIcon(p),
                                            size: 14,
                                            color: sel
                                                ? cor
                                                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.38)),
                                        const SizedBox(width: 6),
                                        Text(
                                          p.label,
                                          style: TextStyle(
                                              color: sel
                                                  ? cor
                                                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
                                              fontSize: 12,
                                              fontWeight: sel
                                                  ? FontWeight.w700
                                                  : FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.descricao,
                                      style: TextStyle(
                                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                                          fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // Status (somente na edição)
                        if (usuario != null) ...[
                          const SizedBox(height: 20),
                          _labelSection(context, 'STATUS'),
                          const SizedBox(height: 10),
                          Row(
                            children:
                            StatusUsuario.values.map((s) {
                              final sel = statusSel == s;
                              final cor = _T.corStatus(s);
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: s !=
                                          StatusUsuario.values.last
                                          ? 8
                                          : 0),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => statusSel = s),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: sel
                                            ? cor
                                            : theme.scaffoldBackgroundColor,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        border: Border.all(
                                          color: sel
                                              ? cor
                                              : theme.dividerColor,
                                        ),
                                      ),
                                      child: Text(
                                        s.label.toUpperCase(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: sel
                                                ? (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white)
                                                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.38),
                                            fontSize: 10,
                                            fontWeight: sel
                                                ? FontWeight.w800
                                                : FontWeight.w400,
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Observações
                        _labelSection(context, 'OBSERVAÇÕES'),
                        const SizedBox(height: 10),
                        _inputField(
                          context,
                          obsCtrl,
                          'Observações internas',
                          Icons.notes_outlined,
                          maxLines: 3,
                          hint: 'Notas sobre o usuário...',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer ───────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border:
                    Border(top: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child:
                          _btnCancelar(context, () => Navigator.pop(ctx))),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Consumer<UsuarioController>(
                          builder: (_, ctrl, __) => _btnAcao(
                            context,
                            label: ctrl.salvando
                                ? 'SALVANDO...'
                                : usuario == null
                                ? 'CRIAR USUÁRIO'
                                : 'ATUALIZAR',
                            cor: theme.primaryColor,
                            onTap: ctrl.salvando
                                ? null
                                : () async {
                              if (usuario == null) {
                                // CRIAR
                                final senha = await ctrl.criar(
                                  nome: nomeCtrl.text,
                                  sobrenome: sobrenomeCtrl.text,
                                  email: emailCtrl.text,
                                  perfil: perfilSel,
                                  telefone: telefoneCtrl.text,
                                  cargo: cargoCtrl.text,
                                  departamento: deptCtrl.text,
                                  observacao: obsCtrl.text,
                                );
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  if (senha != null) {
                                    _showSenhaDialog(
                                        context,
                                        emailCtrl.text,
                                        senha);
                                  } else if (ctrl.erro != null) {
                                    _showSnack(context, ctrl.erro!,
                                        erro: true);
                                  }
                                }
                              } else {
                                // ATUALIZAR
                                final atualizado = usuario.copyWith(
                                  nome: nomeCtrl.text,
                                  sobrenome: sobrenomeCtrl.text,
                                  telefone: telefoneCtrl.text,
                                  cargo: cargoCtrl.text,
                                  departamento: deptCtrl.text,
                                  perfil: perfilSel,
                                  status: statusSel,
                                  observacao: obsCtrl.text,
                                  atualizadoEm: DateTime.now(),
                                );
                                final ok =
                                await ctrl.atualizar(atualizado);
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  _showSnack(
                                    context,
                                    ok
                                        ? 'Usuário atualizado!'
                                        : ctrl.erro ?? 'Erro',
                                    erro: !ok,
                                  );
                                }
                              }
                            },
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

  // ── Modal exibindo a senha temporária gerada ─────────────
  void _showSenhaDialog(
      BuildContext context, String email, String senha) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: theme.cardColor,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _T.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: _T.green, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Usuário Criado!',
                  style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Um e-mail de redefinição de senha foi enviado para $email.\n\nSenha temporária:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5), fontSize: 13),
              ),
              const SizedBox(height: 12),

              // Caixa da senha
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: senha));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        senha,
                        style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: _T.mono,
                            letterSpacing: 2),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.copy_outlined,
                          color: theme.primaryColor, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Toque para copiar • O usuário deve trocar no primeiro acesso',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3), fontSize: 10),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _btnAcao(
                    context,
                    label: 'ENTENDIDO',
                    cor: theme.primaryColor,
                    onTap: () => Navigator.pop(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  WIDGETS AUXILIARES
  // ══════════════════════════════════════════════════════════

  Widget _dialogHeader(
      BuildContext context,
      {required String titulo, required VoidCallback onClose}) {
    final theme = Theme.of(context);
    return Container(
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
          Text(titulo,
              style: TextStyle(
                  color: theme.textTheme.titleMedium?.color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  fontSize: 14)),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4), size: 20),
          ),
        ],
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

  Widget _inputField(
      BuildContext context,
      TextEditingController ctrl,
      String label,
      IconData icon, {
        bool enabled = true,
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
        String? hint,
        String? suffixText,
      }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: enabled ? theme.scaffoldBackgroundColor : theme.dividerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: enabled ? theme.dividerColor : theme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        style: TextStyle(
            color: enabled ? theme.textTheme.bodyMedium?.color : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.38),
            fontSize: 14,
            fontFamily: (label == 'Telefone' || label == 'Senha') ? _T.mono : null,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle:
          TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2), fontSize: 13),
          labelStyle: TextStyle(
            color: enabled
                ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.35)
                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2),
            fontSize: 12,
          ),
          prefixIcon: Icon(icon,
              size: 16,
              color: enabled
                  ? theme.primaryColor
                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2)),
          suffixText: suffixText,
          suffixStyle: const TextStyle(
              color: Color(0xFF4FC3F7), fontSize: 10),
          disabledBorder: InputBorder.none,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _infoBox(
      {required IconData icon,
        required Color cor,
        required String texto}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cor, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto,
                style: TextStyle(color: cor, fontSize: 11)),
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
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.35),
                      fontSize: 9,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 12,
                  fontFamily: label == 'TELEFONE' ? _T.mono : null),
              overflow: TextOverflow.ellipsis),
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

  Widget _badge(String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
      ),
      child: Text(texto,
          style: TextStyle(
              color: cor, fontSize: 10, fontWeight: FontWeight.w700)),
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
          color: selected
              ? theme.primaryColor
              : theme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected
                  ? theme.primaryColor
                  : theme.dividerColor),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? (theme.primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
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
                color: selected ? (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white) : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

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
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.54),
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
                color: onTap == null ? Colors.black45 : (cor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5)),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(erro ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: erro ? _T.red : _T.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  IconData _perfilIcon(PerfilUsuario p) {
    switch (p) {
      case PerfilUsuario.administrador: return Icons.admin_panel_settings_outlined;
      case PerfilUsuario.gerente:       return Icons.manage_accounts_outlined;
      case PerfilUsuario.operador:      return Icons.person_outline;
      case PerfilUsuario.visualizador:  return Icons.visibility_outlined;
    }
  }
}
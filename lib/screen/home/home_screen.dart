import 'package:finance/enums/perfil_usuario_enum.dart';
import 'package:finance/screen/cliente/cliente_screen.dart';
import 'package:finance/screen/contas_receber/contas_receber_screen.dart';
import 'package:finance/screen/entrada/entrada_screen.dart';
import 'package:finance/screen/fornecedor/fornecedor_screen.dart';
import 'package:finance/screen/saida/saida_screen.dart';
import 'package:finance/screen/usuario/usuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/theme_toggle_button.dart';


import '../contas_pagar/contas_pagar_screen.dart';
import '../desconto/desconto_screen.dart';
import '../investimento/investimento_screen.dart';
import '../relatorios/relatorios_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authService = context.watch<AuthService>();
    final isAdmin = authService.isAdmin;
    final isGerente = authService.isGerente;
    final perfil = authService.perfil;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: Text(
          "Dashboard Financeiro",
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Informação do usuário
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.cardColor,
                  child: Icon(Icons.person, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authService.userData?['email'] ?? "Usuário",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Perfil: ${perfil.label}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🔥 LINHA 1 (Menu)
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int crossAxisCount = width > 600 ? 5 : 3;
                final double spacing = 8.0;
                final double itemWidth = (width - (spacing * (crossAxisCount - 1))) / crossAxisCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    if (isGerente)
                      _buildMenuCard(context, "Contas Receber", Icons.attach_money, Colors.blue, const ContasReceberScreen(), width: itemWidth),
                    
                    if (isGerente)
                      _buildMenuCard(context, "Contas à Pagar", Icons.money_off, Colors.red, const ContasPagarScreen(), width: itemWidth),
                    
                    if (perfil != PerfilUsuarioEnum.BASICO)
                      _buildMenuCard(context, "Entradas", Icons.trending_up, Colors.green, const EntradaScreen(), width: itemWidth),
                    
                    if (perfil != PerfilUsuarioEnum.BASICO)
                      _buildMenuCard(context, "Saídas", Icons.trending_down, Colors.orange, const SaidaScreen(), width: itemWidth),
                    
                    if (isAdmin)
                      _buildMenuCard(context, "Investimentos", Icons.show_chart, Colors.purple, const InvestimentosScreen(), width: itemWidth),

                    if (isAdmin)
                      _buildMenuCard(context, "Descontos", Icons.percent, Colors.redAccent, const DescontoScreen(), width: itemWidth),

                    if (isAdmin)
                      _buildMenuCard(context, "Usuários", Icons.people_alt, Colors.indigo, const UsuarioScreen(), width: itemWidth),

                    _buildMenuCard(context, "Fornecedor", Icons.business, Colors.brown, const FornecedorScreen(), width: itemWidth),
                    _buildMenuCard(context, "Clientes", Icons.person, Colors.teal, const ClienteScreen(), width: itemWidth),
                    _buildMenuCard(context, "Relatório", Icons.newspaper, Colors.teal, const RelatoriosScreen(), width: itemWidth),
                  ],
                );
              }
            ),

            const SizedBox(height: 24),

            // 🔥 DASHBOARD (Visível para todos, mas dados podem ser filtrados no futuro)
            Expanded(
              child: Column(
                children: [
                  // 📊 RESUMO Responsivo
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      if (isMobile) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                _buildResumoCard(context, "Saldo", "R\$ 10.000", const Color(0xFF4CAF50)),
                                const SizedBox(width: 12),
                                _buildResumoCard(context, "Receitas", "R\$ 5.000", const Color(0xFF2196F3)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildResumoCard(context, "Despesas", "R\$ 2.000", const Color(0xFFE53935), isFullWidth: true),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          _buildResumoCard(context, "Saldo", "R\$ 10.000", const Color(0xFF4CAF50)),
                          const SizedBox(width: 12),
                          _buildResumoCard(context, "Receitas", "R\$ 5.000", const Color(0xFF2196F3)),
                          const SizedBox(width: 12),
                          _buildResumoCard(context, "Despesas", "R\$ 2.000", const Color(0xFFE53935)),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 📋 LISTA (Exemplo de log ou transações recentes)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Atividades Recentes",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: ListView(
                        children: [
                          _buildRecentActivityItem(
                            context,
                            icon: Icons.flash_on,
                            iconColor: const Color(0xFFFFA726),
                            title: "Conta de Luz",
                            subtitle: "Venc: 10/04",
                            value: "R\$ 200",
                            isNegative: true,
                          ),
                          Divider(color: theme.dividerColor, height: 1),
                          _buildRecentActivityItem(
                            context,
                            icon: Icons.payments,
                            iconColor: const Color(0xFF4CAF50),
                            title: "Salário",
                            subtitle: "05/04",
                            value: "R\$ 3.000",
                            isNegative: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 CARD DE MENU
  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, Widget? screen, {required double width}) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: 90,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (screen != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Módulo em desenvolvimento")),
            );
          }
        },
        child: Card(
          elevation: 0,
          color: color.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 CARD RESUMO
  Widget _buildResumoCard(BuildContext context, String title, String value, Color color, {bool isFullWidth = false}) {
    final theme = Theme.of(context);
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );

    return isFullWidth ? card : Expanded(child: card);
  }

  Widget _buildRecentActivityItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required bool isNegative,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: Text(
        "${isNegative ? '-' : '+'} $value",
        style: TextStyle(
          color: isNegative ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

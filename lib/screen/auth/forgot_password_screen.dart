import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_input_widget.dart';

// ══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ══════════════════════════════════════════════════════════════
abstract class _T {
  static const teal   = Color(0xFF00BFA5);
  static const mono   = 'monospace';
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final controller = TextEditingController();

  bool isEmail = true;

  @override
  Widget build(BuildContext context) {
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
              "RECUPERAR SENHA",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone topo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEmail ? Icons.email_outlined : Icons.phone_iphone,
                    size: 40,
                    color: theme.primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "RECUPERAR ACESSO",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Escolha como deseja recuperar sua conta",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // TOGGLE EMAIL / TELEFONE
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _toggleItem(context, "Email", isEmail, () => setState(() => isEmail = true)),
                      _toggleItem(context, "Telefone", !isEmail, () => setState(() => isEmail = false)),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // INPUT DINÂMICO
                CustomInputWidget(
                  controller: controller,
                  label: isEmail ? "E-mail" : "Telefone",
                  hint: isEmail ? "Digite seu e-mail" : "Digite seu telefone",
                  icon: isEmail
                      ? Icons.email_outlined
                      : Icons.phone_outlined,
                  keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.phone,
                ),

                const SizedBox(height: 24),

                // BOTÃO
                SizedBox(
                  width: double.infinity,
                  child: CustomButtonWidget(
                    text: "ENVIAR CÓDIGO",
                    onPressed: () {
                      if (isEmail) {
                        _recuperarPorEmail();
                      } else {
                        _recuperarPorTelefone();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // VOLTAR LOGIN
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "VOLTAR PARA LOGIN",
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleItem(BuildContext context, String label, bool active, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? theme.cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active 
                  ? theme.textTheme.bodyLarge?.color 
                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Firebase - Email
  Future<void> _recuperarPorEmail() async {
    final email = controller.text;
    if (email.isEmpty) {
      _showSnackBar("Por favor, digite seu e-mail.", isError: true);
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.sendPasswordResetEmail(email);
      _showSnackBar("E-mail de recuperação enviado com sucesso!");
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Erro ao enviar e-mail: $e", isError: true);
    }
  }

  // 🔥 Firebase - Telefone
  Future<void> _recuperarPorTelefone() async {
    final telefone = controller.text;
    if (telefone.isEmpty) {
      _showSnackBar("Por favor, digite seu telefone.", isError: true);
      return;
    }

    _showSnackBar("A recuperação por telefone ainda não está disponível.", isError: true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}

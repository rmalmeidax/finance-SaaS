import 'package:flutter/material.dart';

import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_input_widget.dart';


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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar senha"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(28),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.15),
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
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEmail ? Icons.email_outlined : Icons.phone_iphone,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Recuperar acesso",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Escolha como deseja recuperar sua conta",
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // TOGGLE EMAIL / TELEFONE
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isEmail = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isEmail
                                ? Colors.grey[900]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Email",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                              isEmail ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isEmail = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isEmail
                                ? Colors.grey[900]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Telefone",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                              !isEmail ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // INPUT DINÂMICO
                CustomInputWidget(
                  controller: controller,
                  hint: isEmail ? "Digite seu email" : "Digite seu telefone",
                  icon: isEmail
                      ? Icons.email_outlined
                      : Icons.phone_outlined,
                ),

                const SizedBox(height: 20),

                // BOTÃO
                CustomButtonWidget(
                  text: "Enviar código",
                  onPressed: () {
                    if (isEmail) {
                      _recuperarPorEmail();
                    } else {
                      _recuperarPorTelefone();
                    }
                  },
                ),

                const SizedBox(height: 15),

                // VOLTAR LOGIN
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Voltar para login"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 Firebase - Email
  void _recuperarPorEmail() {
    final email = controller.text;

    // TODO: Firebase Auth
    print("Recuperar por email: $email");
  }

  // 🔥 Firebase - Telefone
  void _recuperarPorTelefone() {
    final telefone = controller.text;

    // TODO: Firebase Auth (SMS)
    print("Recuperar por telefone: $telefone");
  }
}
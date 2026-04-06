import 'package:finance/controllers/conta_pagar_controller.dart';
import 'package:finance/controllers/fornecedor_controller.dart';
import 'package:finance/services/conta_pagar_service.dart';
import 'package:finance/services/fornecedor_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// 🔹 Suas telas
import 'package:finance/screen/auth/login_screen.dart';

// 🔹 Tema
import 'core/theme/app_theme.dart';

// 🔹 Firebase config
import 'firebase_options.dart';

// 🔹 Contas a Receber
import 'controllers/conta_receber_controller.dart';
import 'services/conta_receber_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 Inicializa Providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ContaReceberController(ContaReceberService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ContaPagarController(ContaPagarService()),
        ),
        ChangeNotifierProvider(
          create: (_) => FornecedorController(),
        ),
     ],
      child: const MyApp(),
    ),
  );
}

// 🔹 App principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance SaaS',
      debugShowCheckedModeBanner: false,

      // 🎨 Tema global
      theme: AppTheme.lightTheme,

      // 🧭 Tela inicial
      home: const LoginScreen(),
    );
  }
}
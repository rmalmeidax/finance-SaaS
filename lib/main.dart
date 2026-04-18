import 'package:finance/controllers/theme_controller.dart';
import 'package:finance/controllers/conta_pagar_controller.dart';
import 'package:finance/controllers/fornecedor_controller.dart';
import 'package:finance/controllers/investimento_controller.dart';
import 'package:finance/controllers/usuario_controller.dart';
import 'package:finance/services/auth_service.dart';
import 'package:finance/services/cliente_service.dart';
import 'package:finance/services/conta_pagar_service.dart';
import 'package:finance/services/desconto_service.dart';
import 'package:finance/services/entrada_service.dart';
import 'package:finance/services/fornecedor_service.dart';
import 'package:finance/services/investimento_service.dart';
import 'package:finance/services/saida_service.dart';
import 'package:finance/services/usuario_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// 🔹 Suas telas
import 'package:finance/screen/auth/login_screen.dart';
import 'package:finance/screen/home/home_screen.dart';

// 🔹 Tema
import 'controllers/clientes_controller.dart';
import 'controllers/desconto_controller.dart';
import 'controllers/entrada_controller.dart';
import 'controllers/saida_controller.dart';
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
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (_) => ContaReceberController(ContaReceberService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ContaPagarController(ContaPagarService()),
        ),
        ChangeNotifierProvider(
          create: (_) => FornecedorController(FornecedorService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ClienteController(ClienteService()),
        ),
        ChangeNotifierProvider(
          create: (_) => EntradaController(EntradaService()),
        ),
        ChangeNotifierProvider(
          create: (_) => SaidaController(SaidaService()),
        ),
        ChangeNotifierProvider(
          create: (_) => InvestmentController(),
        ),
        ChangeNotifierProvider(
          create: (_) => UsuarioController(),
        ),
        ChangeNotifierProvider(
          create: (_) => DescontoController(DescontoService()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeController()),
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
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: 'Finance SaaS',
      debugShowCheckedModeBanner: false,

      // 🎨 Tema global
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,

      // 🧭 Tela inicial baseada no estado de auth
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}

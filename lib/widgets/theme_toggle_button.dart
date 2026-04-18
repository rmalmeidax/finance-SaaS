import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return IconButton(
      icon: Icon(
        themeController.isDarkMode ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: () {
        themeController.toggleTheme();
      },
      tooltip: themeController.isDarkMode
          ? 'Mudar para tema claro'
          : 'Mudar para tema escuro',
    );
  }
}

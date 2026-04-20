import 'package:flutter/material.dart';

class CustomInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool isMonospace;

  const CustomInputWidget({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Auto-detect monospace based on keyboard type or label
    final effectiveMono = isMonospace || 
        keyboardType == TextInputType.number || 
        keyboardType == TextInputType.phone ||
        label.toLowerCase().contains('valor') ||
        label.toLowerCase().contains('cpf') ||
        label.toLowerCase().contains('cnpj');

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontFamily: effectiveMono ? 'monospace' : null,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
            fontSize: 12,
          ),
          hintStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.2),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, size: 18, color: theme.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}

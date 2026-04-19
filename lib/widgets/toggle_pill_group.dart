import 'package:flutter/material.dart';

import '../util/app_theme.dart';


/// Grupo de pills de seleção única (radio behavior)
class TogglePillGroup<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelFor;
  final ValueChanged<T> onChanged;
  final Color activeColor;
  final Color activeBg;
  final Color activeText;

  const TogglePillGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.labelFor,
    required this.onChanged,
    this.activeColor = AppColors.blueMid,
    this.activeBg = AppColors.blueLight,
    this.activeText = AppColors.blueDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isOn = opt == selected;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isOn ? activeBg : const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOn ? activeColor : AppColors.border,
                width: isOn ? 1.5 : 0.5,
              ),
            ),
            child: Text(
              labelFor(opt),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
                color: isOn ? activeText : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Grupo de pills de seleção múltipla (checkbox behavior)
class MultiTogglePillGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final Color activeColor;
  final Color activeBg;
  final Color activeText;

  const MultiTogglePillGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.activeColor = AppColors.blueMid,
    this.activeBg = AppColors.blueLight,
    this.activeText = AppColors.blueDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isOn = selected.contains(opt);
        return GestureDetector(
          onTap: () => onToggle(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isOn ? activeBg : const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOn ? activeColor : AppColors.border,
                width: isOn ? 1.5 : 0.5,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
                color: isOn ? activeText : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

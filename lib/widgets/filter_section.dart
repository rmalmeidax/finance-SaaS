import 'package:flutter/material.dart';

import '../util/app_theme.dart';

class FilterSection extends StatelessWidget {
  final String label;
  final Widget child;

  const FilterSection({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class FilterDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T value;
  final String Function(T) labelFor;
  final ValueChanged<T?> onChanged;

  const FilterDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.labelFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          borderRadius: BorderRadius.circular(10),
          dropdownColor: theme.cardColor,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(labelFor(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class FilterDatePicker extends StatelessWidget {
  final String hint;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const FilterDatePicker({
    super.key,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: theme.primaryColor,
                onPrimary: theme.colorScheme.onPrimary,
              ),
            ),
            child: child!,
          ),
        );
        onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 15,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 8),
            Text(
              value != null
                  ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
                  : hint,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: value != null
                    ? theme.textTheme.bodyMedium?.color
                    : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
              ),
            ),
            const Spacer(),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(
                  Icons.close,
                  size: 15,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

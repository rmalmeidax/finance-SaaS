import 'package:flutter/material.dart';

import '../model/relatorio_madel/relatorio_tipo.dart';

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
}

class RelatorioCardButton extends StatelessWidget {
  final TipoRelatorio tipo;
  final bool isSelected;
  final VoidCallback onTap;

  const RelatorioCardButton({
    super.key,
    required this.tipo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _configForTipo(tipo);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? config.accent.withValues(alpha: 0.1) : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? config.accent : theme.dividerColor.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? config.accent.withValues(alpha: 0.08) 
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: config.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(config.icon, color: config.accent, size: 16),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: config.accent, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tipo.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? config.accent : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                tipo.descricao,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _CardConfig _configForTipo(TipoRelatorio tipo) {
    switch (tipo) {
      case TipoRelatorio.contasPagarReceber:
        return _CardConfig(
          icon: Icons.swap_vert_rounded,
          accent: _T.blue,
        );
      case TipoRelatorio.clientesFornecedores:
        return _CardConfig(
          icon: Icons.people_outline_rounded,
          accent: _T.teal,
        );
      case TipoRelatorio.usuarios:
        return _CardConfig(
          icon: Icons.manage_accounts_outlined,
          accent: const Color(0xFF7E57C2), // Purple
        );
      case TipoRelatorio.investimentosDescontos:
        return _CardConfig(
          icon: Icons.trending_up_rounded,
          accent: _T.orange,
        );
    }
  }
}

class _CardConfig {
  final IconData icon;
  final Color accent;

  _CardConfig({
    required this.icon,
    required this.accent,
  });
}

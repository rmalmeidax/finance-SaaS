import 'package:flutter/material.dart';

import '../model/relatorio_madel/relatorio_tipo.dart';
import '../util/app_theme.dart';


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
    final config = _configForTipo(tipo);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? config.bgSelected : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? config.accent : AppColors.border,
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: config.accent.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: config.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(config.icon, color: config.iconColor, size: 18),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: config.badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tipo.categoria,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: config.badgeText,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tipo.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tipo.descricao,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
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
          accent: AppColors.blueMid,
          bgSelected: AppColors.blueLight,
          iconBg: const Color(0xFFB5D4F4),
          iconColor: AppColors.blueDark,
          badgeBg: const Color(0xFFB5D4F4),
          badgeText: AppColors.blueDark,
        );
      case TipoRelatorio.clientesFornecedores:
        return _CardConfig(
          icon: Icons.people_outline_rounded,
          accent: AppColors.tealMid,
          bgSelected: AppColors.tealLight,
          iconBg: const Color(0xFF9FE1CB),
          iconColor: AppColors.tealDark,
          badgeBg: const Color(0xFF9FE1CB),
          badgeText: AppColors.tealDark,
        );
      case TipoRelatorio.usuarios:
        return _CardConfig(
          icon: Icons.manage_accounts_outlined,
          accent: AppColors.purpleMid,
          bgSelected: AppColors.purpleLight,
          iconBg: const Color(0xFFCECBF6),
          iconColor: AppColors.purpleDark,
          badgeBg: const Color(0xFFCECBF6),
          badgeText: AppColors.purpleDark,
        );
      case TipoRelatorio.investimentosDescontos:
        return _CardConfig(
          icon: Icons.trending_up_rounded,
          accent: AppColors.amberMid,
          bgSelected: AppColors.amberLight,
          iconBg: const Color(0xFFFAC775),
          iconColor: AppColors.amberDark,
          badgeBg: const Color(0xFFFAC775),
          badgeText: AppColors.amberDark,
        );
    }
  }
}

class _CardConfig {
  final IconData icon;
  final Color accent;
  final Color bgSelected;
  final Color iconBg;
  final Color iconColor;
  final Color badgeBg;
  final Color badgeText;

  _CardConfig({
    required this.icon,
    required this.accent,
    required this.bgSelected,
    required this.iconBg,
    required this.iconColor,
    required this.badgeBg,
    required this.badgeText,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/relatorio_controller/relatorio_controller.dart';
import '../model/relatorio_madel/relatorio_request.dart';
import '../util/app_theme.dart';


class ResultadoBanner extends StatelessWidget {
  const ResultadoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.watch<RelatorioController>().resultado;

    if (r.status == StatusRelatorio.idle || r.status == StatusRelatorio.gerando) {
      return const SizedBox.shrink();
    }

    final isSuccess = r.status == StatusRelatorio.sucesso;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFE1F5EE) : const Color(0xFFFCEBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess ? const Color(0xFF5DCAA5) : const Color(0xFFF09595),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            color: isSuccess ? AppColors.tealMid : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.mensagem ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSuccess
                        ? AppColors.tealDark
                        : const Color(0xFF791F1F),
                  ),
                ),
                if (isSuccess && r.arquivoPath != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    r.arquivoPath!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.tealDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSuccess)
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new_rounded, size: 14),
              label: const Text('Abrir', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.tealMid,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
        ],
      ),
    );
  }
}

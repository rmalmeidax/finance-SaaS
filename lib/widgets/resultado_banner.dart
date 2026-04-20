import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/relatorio_controller/relatorio_controller.dart';
import '../model/relatorio_madel/relatorio_request.dart';

class ResultadoBanner extends StatelessWidget {
  const ResultadoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = context.watch<RelatorioController>().resultado;

    if (r.status == StatusRelatorio.idle || r.status == StatusRelatorio.gerando) {
      return const SizedBox.shrink();
    }

    final isSuccess = r.status == StatusRelatorio.sucesso;
    final green = const Color(0xFF00BFA5);
    final red = const Color(0xFFC62828);
    
    final mainColor = isSuccess ? green : red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: mainColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mainColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            color: mainColor,
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
                    color: mainColor,
                  ),
                ),
                if (isSuccess && r.arquivoPath != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    r.arquivoPath!,
                    style: TextStyle(
                      fontSize: 11,
                      color: mainColor.withValues(alpha: 0.7),
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
                foregroundColor: mainColor,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
        ],
      ),
    );
  }
}

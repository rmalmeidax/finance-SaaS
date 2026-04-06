import 'package:flutter/material.dart';

import '../../services/conta_pagar_service.dart';
import '../../widgets/dashboard_resumo_card_widget.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final service = ContaPagarService();

  @override
  Widget build(BuildContext context) {
    final vencidas = service.getContasVencidas();
    final avencer = service.getContasAVencer();

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Financeiro")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 CARDS RESUMO
            Row(
              children: [
                DashboardResumoCardWidget(
                  title: "Vencidas",
                  value: service.totalVencidas(),
                  color: Colors.red,
                ),
                DashboardResumoCardWidget(
                  title: "A Vencer",
                  value: service.totalAVencer(),
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔴 VENCIDAS
            _titulo("Contas Vencidas", Colors.red),

            Expanded(
              child: ListView.builder(
                itemCount: vencidas.length,
                itemBuilder: (_, i) {
                  final c = vencidas[i];

                  return _cardConta(c, Colors.red);
                },
              ),
            ),

            const SizedBox(height: 10),

            // 🟢 A VENCER
            _titulo("Contas a Vencer", Colors.green),

            Expanded(
              child: ListView.builder(
                itemCount: avencer.length,
                itemBuilder: (_, i) {
                  final c = avencer[i];

                  return _cardConta(c, Colors.green);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String texto, Color cor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: cor,
        ),
      ),
    );
  }

  Widget _cardConta(c, Color cor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.2),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(c.descricao),
          Text(
            "R\$ ${c.valor.toStringAsFixed(2)}",
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
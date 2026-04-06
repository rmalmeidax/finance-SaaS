import 'package:finance/screen/contas_receber/contas_receber_screen.dart';
import 'package:finance/screen/fornecedor/fornecedor_screen.dart';
import 'package:flutter/material.dart';

import '../../widgets/dashboard_card_widget.dart';
import '../contas_pagar/contas_pagar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: const Text("Dashboard Financeiro"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            DashboardCardWidget(
              title: "Contas a Receber",
              icon: Icons.attach_money,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContasReceberScreen(),
                  ),
                );
              },
           ),
            DashboardCardWidget(
              title: "Contas a Pagar",
              icon: Icons.money_off,
              color: Colors.red,
              onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContasPagarScreen(),
                    ),
                  );
               },
            ),
            DashboardCardWidget(
              title: "Entradas",
              icon: Icons.trending_up,
              color: Colors.green,
              onTap: () {},
            ),
            DashboardCardWidget(
              title: "Saídas",
              icon: Icons.trending_down,
              color: Colors.orange,
              onTap: () {},
            ),
            DashboardCardWidget(
              title: "Investimentos",
              icon: Icons.show_chart,
              color: Colors.purple,
              onTap: () {},
            ),
            DashboardCardWidget(
              title: "Descontos",
              icon: Icons.show_chart,
              color: Colors.redAccent,
              onTap: () {},
            ),
            DashboardCardWidget(
              title: "Fornecedor",
              icon: Icons.people,
              color: Colors.red,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FornecedorScreen(),
                    ),
                );
              },
            ),
            DashboardCardWidget(
              title: "Clientes",
              icon: Icons.people,
              color: Colors.teal,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 MENU LATERAL
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.grey),
            accountName: const Text("Usuário"),
            accountEmail: const Text("email@email.com"),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          _drawerItem(Icons.dashboard, "Dashboard"),
          _drawerItem(Icons.attach_money, "Contas a Receber"),
          _drawerItem(Icons.money_off, "Contas a Pagar"),
          _drawerItem(Icons.trending_up, "Entradas"),
          _drawerItem(Icons.trending_down, "Saídas"),
          _drawerItem(Icons.show_chart, "Investimentos"),
          _drawerItem(Icons.show_chart, "Descontos"),
          _drawerItem(Icons.people, "Fornecedor"),
          _drawerItem(Icons.people, "Clientes"),

          const Spacer(),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Sair"),
            onTap: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {},
    );
  }
}
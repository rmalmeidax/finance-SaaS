// =============================
// 📁 SCREEN CLIENTES
// =============================
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../controllers/entrada_controller.dart';
import '../../form/cliente_form.dart';
import '../../widgets/item_lista.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final controller = ClienteController();

  void _abrirFormulario() {
    showDialog(
      context: context,
      builder: (_) => ClienteForm(onSave: (c) {
        setState(() => controller.adicionar(c));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: controller.lista
            .map((c) => ListItem(
          titulo: c.nome,
          subtitulo: c.email,
          onDelete: () {},
        ))
            .toList(),
      ),
    );
  }
}

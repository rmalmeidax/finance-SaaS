// =============================
// 📁 SCREEN ENTRADAS
// =============================
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../controllers/entrada_controller.dart';
import '../../form/entrada_form.dart';
import '../../widgets/item_lista.dart';

class EntradasScreen extends StatefulWidget {
  const EntradasScreen({super.key});

  @override
  State<EntradasScreen> createState() => _EntradasScreenState();
}

class _EntradasScreenState extends State<EntradasScreen> {
  final controller = EntradaController();

  void _abrirFormulario() {
    showDialog(
      context: context,
      builder: (_) => EntradaForm(onSave: (entrada) {
        setState(() => controller.adicionar(entrada));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entradas')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: controller.lista
            .map((e) => ListItem(
          titulo: e.descricao,
          subtitulo: 'R\$ ${e.valor}',
          onDelete: () => setState(() => controller.remover(e.id)),
        ))
            .toList(),
      ),
    );
  }
}
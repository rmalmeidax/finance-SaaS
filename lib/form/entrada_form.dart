// =============================
// 📁 FORM ENTRADA
// =============================
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/entrada.dart';

class EntradaForm extends StatefulWidget {
  final Function(Entrada) onSave;

  const EntradaForm({super.key, required this.onSave});

  @override
  State<EntradaForm> createState() => _EntradaFormState();
}

class _EntradaFormState extends State<EntradaForm> {
  final descricao = TextEditingController();
  final valor = TextEditingController();

  void salvar() {
    final entrada = Entrada(
      id: DateTime.now().toString(),
      descricao: descricao.text,
      valor: double.tryParse(valor.text) ?? 0,
      data: DateTime.now(),
    );

    widget.onSave(entrada);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Entrada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: descricao, decoration: const InputDecoration(labelText: 'Descrição')),
          TextField(controller: valor, decoration: const InputDecoration(labelText: 'Valor')),
        ],
      ),
      actions: [
        TextButton(onPressed: salvar, child: const Text('Salvar')),
      ],
    );
  }
}

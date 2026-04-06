// =============================
// 📁 FORM CLIENTE
// =============================
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/entrada.dart';

class ClienteForm extends StatefulWidget {
  final Function(Cliente) onSave;

  const ClienteForm({super.key, required this.onSave});

  @override
  State<ClienteForm> createState() => _ClienteFormState();
}

class _ClienteFormState extends State<ClienteForm> {
  final nome = TextEditingController();
  final email = TextEditingController();

  void salvar() {
    final cliente = Cliente(
      id: DateTime.now().toString(),
      nome: nome.text,
      email: email.text,
    );

    widget.onSave(cliente);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Cliente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nome, decoration: const InputDecoration(labelText: 'Nome')),
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
        ],
      ),
      actions: [
        TextButton(onPressed: salvar, child: const Text('Salvar')),
      ],
    );
  }
}
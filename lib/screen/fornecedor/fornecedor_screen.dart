import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/fornecedor_controller.dart';



class FornecedorScreen extends StatelessWidget {
  const FornecedorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FornecedorController>(context);

    final cnpjController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Fornecedor"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔍 CNPJ
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cnpjController,
                    decoration: const InputDecoration(
                      labelText: "Digite o CNPJ",
                      filled: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    controller.buscar(cnpjController.text);
                  },
                  child: const Icon(Icons.search),
                )
              ],
            ),

            const SizedBox(height: 20),

            if (controller.loading)
              const CircularProgressIndicator(),

            if (controller.fornecedor != null)
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        _campo("Razão Social",
                            controller.fornecedor!.nome),
                        _campo("Fantasia",
                            controller.fornecedor!.fantasia),
                        _campo("CNPJ",
                            controller.fornecedor!.cnpj),
                        _campo("Endereço",
                            controller.fornecedor!.endereco),
                        _campo("Cidade",
                            controller.fornecedor!.cidade),
                        _campo("Estado",
                            controller.fornecedor!.estado),
                        _campo("Telefone",
                            controller.fornecedor!.telefone),
                        _campo("Email",
                            controller.fornecedor!.email),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _campo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: TextEditingController(text: valor),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
        ),
      ),
    );
  }
}
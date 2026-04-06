import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final VoidCallback onDelete;

  const ListItem({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
enum CategoriaEntrada {
  salario,
  vendas,
  servicos,
  alugueis,
  investimentos,
  outros,
}

extension CategoriaEntradaLabel on CategoriaEntrada {
  String get label {
    switch (this) {
      case CategoriaEntrada.salario:
        return 'Salário';
      case CategoriaEntrada.vendas:
        return 'Vendas';
      case CategoriaEntrada.servicos:
        return 'Serviços';
      case CategoriaEntrada.alugueis:
        return 'Aluguéis';
      case CategoriaEntrada.investimentos:
        return 'Investimentos';
      case CategoriaEntrada.outros:
        return 'Outros';
    }
  }

  String get icon {
    switch (this) {
      case CategoriaEntrada.salario:
        return '💼';
      case CategoriaEntrada.vendas:
        return '🛒';
      case CategoriaEntrada.servicos:
        return '🔧';
      case CategoriaEntrada.alugueis:
        return '🏠';
      case CategoriaEntrada.investimentos:
        return '📈';
      case CategoriaEntrada.outros:
        return '💡';
    }
  }
}

class Entrada {
  final String id;
  final String descricao;
  final String cliente;
  final CategoriaEntrada categoria;
  final DateTime data;
  final double valor;
  final String observacao;
  String status; // Recebido, Pendente

  Entrada({
    required this.id,
    required this.descricao,
    required this.cliente,
    required this.categoria,
    required this.data,
    required this.valor,
    this.observacao = '',
    this.status = 'Recebido',
  });
}
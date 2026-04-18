enum CategoriaSaida {
  aluguel,
  folhaDePagamento,
  impostos,
  fornecedores,
  marketing,
  utilities,
  manutencao,
  transporte,
  alimentacao,
  tecnologia,
  outros,
}

enum TipoDespesa { fixa, variavel }

extension CategoriaSaidaLabel on CategoriaSaida {
  String get label {
    switch (this) {
      case CategoriaSaida.aluguel:
        return 'Aluguel';
      case CategoriaSaida.folhaDePagamento:
        return 'Folha de Pgto';
      case CategoriaSaida.impostos:
        return 'Impostos';
      case CategoriaSaida.fornecedores:
        return 'Fornecedores';
      case CategoriaSaida.marketing:
        return 'Marketing';
      case CategoriaSaida.utilities:
        return 'Utilidades';
      case CategoriaSaida.manutencao:
        return 'Manutenção';
      case CategoriaSaida.transporte:
        return 'Transporte';
      case CategoriaSaida.alimentacao:
        return 'Alimentação';
      case CategoriaSaida.tecnologia:
        return 'Tecnologia';
      case CategoriaSaida.outros:
        return 'Outros';
    }
  }

  String get icon {
    switch (this) {
      case CategoriaSaida.aluguel:
        return '🏢';
      case CategoriaSaida.folhaDePagamento:
        return '👥';
      case CategoriaSaida.impostos:
        return '🏛️';
      case CategoriaSaida.fornecedores:
        return '📦';
      case CategoriaSaida.marketing:
        return '📣';
      case CategoriaSaida.utilities:
        return '💡';
      case CategoriaSaida.manutencao:
        return '🔧';
      case CategoriaSaida.transporte:
        return '🚗';
      case CategoriaSaida.alimentacao:
        return '🍽️';
      case CategoriaSaida.tecnologia:
        return '💻';
      case CategoriaSaida.outros:
        return '📌';
    }
  }
}

class Saida {
  final String id;
  final String descricao;
  final String fornecedor;
  final CategoriaSaida categoria;
  final TipoDespesa tipoDespesa;
  final DateTime data;
  final DateTime? dataVencimento;
  final double valor;
  final String observacao;
  String status; // Pago, Pendente, Vencido

  Saida({
    required this.id,
    required this.descricao,
    required this.fornecedor,
    required this.categoria,
    required this.tipoDespesa,
    required this.data,
    this.dataVencimento,
    required this.valor,
    this.observacao = '',
    this.status = 'Pendente',
  });
}
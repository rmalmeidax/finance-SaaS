import 'package:intl/intl.dart';

enum TipoAnalise { investimentosDescontos, investimentos, descontos }

extension TipoAnaliseExt on TipoAnalise {
  String get label {
    switch (this) {
      case TipoAnalise.investimentosDescontos:
        return 'Investimentos e Descontos';
      case TipoAnalise.investimentos:
        return 'Apenas Investimentos';
      case TipoAnalise.descontos:
        return 'Apenas Descontos';
    }
  }
}

enum TipoInvestimento { todos, rendaFixa, rendaVariavel, imoveis, outros }

extension TipoInvestimentoExt on TipoInvestimento {
  String get label {
    switch (this) {
      case TipoInvestimento.todos:
        return 'Todos';
      case TipoInvestimento.rendaFixa:
        return 'Renda Fixa';
      case TipoInvestimento.rendaVariavel:
        return 'Renda Variável';
      case TipoInvestimento.imoveis:
        return 'Imóveis';
      case TipoInvestimento.outros:
        return 'Outros';
    }
  }
}

enum TipoDesconto { todos, comercial, financeiro, condicional }

extension TipoDescontoExt on TipoDesconto {
  String get label {
    switch (this) {
      case TipoDesconto.todos:
        return 'Todos';
      case TipoDesconto.comercial:
        return 'Desconto Comercial';
      case TipoDesconto.financeiro:
        return 'Desconto Financeiro';
      case TipoDesconto.condicional:
        return 'Desconto Condicional';
    }
  }
}

class FiltroInvestimentos {
  TipoAnalise tipoAnalise;
  TipoInvestimento tipoInvestimento;
  TipoDesconto tipoDesconto;
  DateTime? dataInicial;
  DateTime? dataFinal;
  Set<String> metricas;

  FiltroInvestimentos({
    this.tipoAnalise = TipoAnalise.investimentosDescontos,
    this.tipoInvestimento = TipoInvestimento.todos,
    this.tipoDesconto = TipoDesconto.todos,
    this.dataInicial,
    this.dataFinal,
    Set<String>? metricas,
  }) : metricas = metricas ?? {'Valor Aplicado', 'Rendimento'};

  static List<String> get opcoesMetricas => [
    'Valor Aplicado',
    'Rendimento',
    '% Desconto',
    'Acumulado',
    'Comparativo',
  ];

  void limpar() {
    tipoAnalise = TipoAnalise.investimentosDescontos;
    tipoInvestimento = TipoInvestimento.todos;
    tipoDesconto = TipoDesconto.todos;
    dataInicial = null;
    dataFinal = null;
    metricas = {'Valor Aplicado', 'Rendimento'};
  }

  Map<String, dynamic> toMap() {
    final fmt = DateFormat('dd/MM/yyyy');
    return {
      'tipoAnalise': tipoAnalise.label,
      'tipoInvestimento': tipoInvestimento.label,
      'tipoDesconto': tipoDesconto.label,
      'dataInicial': dataInicial != null ? fmt.format(dataInicial!) : null,
      'dataFinal': dataFinal != null ? fmt.format(dataFinal!) : null,
      'metricas': metricas.toList(),
    };
  }
}

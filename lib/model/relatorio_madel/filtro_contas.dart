import 'package:intl/intl.dart';

enum TipoLancamento { entradaSaida, entrada, saida }

extension TipoLancamentoExt on TipoLancamento {
  String get label {
    switch (this) {
      case TipoLancamento.entradaSaida:
        return 'Entrada e Saída';
      case TipoLancamento.entrada:
        return 'Apenas Entrada';
      case TipoLancamento.saida:
        return 'Apenas Saída';
    }
  }
}

enum StatusConta { todos, emAberto, pagoRecebido, vencido }

extension StatusContaExt on StatusConta {
  String get label {
    switch (this) {
      case StatusConta.todos:
        return 'Todos';
      case StatusConta.emAberto:
        return 'Em Aberto';
      case StatusConta.pagoRecebido:
        return 'Pago / Recebido';
      case StatusConta.vencido:
        return 'Vencido';
    }
  }
}

enum CategoriaConta { todas, operacional, administrativo, tributario, pessoal }

extension CategoriaContaExt on CategoriaConta {
  String get label {
    switch (this) {
      case CategoriaConta.todas:
        return 'Todas';
      case CategoriaConta.operacional:
        return 'Operacional';
      case CategoriaConta.administrativo:
        return 'Administrativo';
      case CategoriaConta.tributario:
        return 'Tributário';
      case CategoriaConta.pessoal:
        return 'Pessoal';
    }
  }
}

enum AgrupamentoConta { dia, semana, mes, categoria }

extension AgrupamentoContaExt on AgrupamentoConta {
  String get label {
    switch (this) {
      case AgrupamentoConta.dia:
        return 'Por Dia';
      case AgrupamentoConta.semana:
        return 'Por Semana';
      case AgrupamentoConta.mes:
        return 'Por Mês';
      case AgrupamentoConta.categoria:
        return 'Por Categoria';
    }
  }
}

class FiltroContas {
  TipoLancamento tipoLancamento;
  StatusConta status;
  CategoriaConta categoria;
  DateTime? dataInicial;
  DateTime? dataFinal;
  AgrupamentoConta agrupamento;

  FiltroContas({
    this.tipoLancamento = TipoLancamento.entradaSaida,
    this.status = StatusConta.todos,
    this.categoria = CategoriaConta.todas,
    this.dataInicial,
    this.dataFinal,
    this.agrupamento = AgrupamentoConta.dia,
  });

  FiltroContas copyWith({
    TipoLancamento? tipoLancamento,
    StatusConta? status,
    CategoriaConta? categoria,
    DateTime? dataInicial,
    DateTime? dataFinal,
    AgrupamentoConta? agrupamento,
  }) {
    return FiltroContas(
      tipoLancamento: tipoLancamento ?? this.tipoLancamento,
      status: status ?? this.status,
      categoria: categoria ?? this.categoria,
      dataInicial: dataInicial ?? this.dataInicial,
      dataFinal: dataFinal ?? this.dataFinal,
      agrupamento: agrupamento ?? this.agrupamento,
    );
  }

  void limpar() {
    tipoLancamento = TipoLancamento.entradaSaida;
    status = StatusConta.todos;
    categoria = CategoriaConta.todas;
    dataInicial = null;
    dataFinal = null;
    agrupamento = AgrupamentoConta.dia;
  }

  Map<String, dynamic> toMap() {
    final fmt = DateFormat('dd/MM/yyyy');
    return {
      'tipoLancamento': tipoLancamento.label,
      'status': status.label,
      'categoria': categoria.label,
      'dataInicial': dataInicial != null ? fmt.format(dataInicial!) : null,
      'dataFinal': dataFinal != null ? fmt.format(dataFinal!) : null,
      'agrupamento': agrupamento.label,
    };
  }
}

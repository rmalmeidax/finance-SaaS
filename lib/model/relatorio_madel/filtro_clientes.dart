import 'package:intl/intl.dart';

enum TipoEntidade { clientesFornecedores, clientes, fornecedores }

extension TipoEntidadeExt on TipoEntidade {
  String get label {
    switch (this) {
      case TipoEntidade.clientesFornecedores:
        return 'Clientes e Fornecedores';
      case TipoEntidade.clientes:
        return 'Apenas Clientes';
      case TipoEntidade.fornecedores:
        return 'Apenas Fornecedores';
    }
  }
}

enum StatusCadastro { todos, ativo, inativo, bloqueado }

extension StatusCadastroExt on StatusCadastro {
  String get label {
    switch (this) {
      case StatusCadastro.todos:
        return 'Todos';
      case StatusCadastro.ativo:
        return 'Ativo';
      case StatusCadastro.inativo:
        return 'Inativo';
      case StatusCadastro.bloqueado:
        return 'Bloqueado';
    }
  }
}

enum TipoPessoa { todos, fisica, juridica }

extension TipoPessoaExt on TipoPessoa {
  String get label {
    switch (this) {
      case TipoPessoa.todos:
        return 'Todos';
      case TipoPessoa.fisica:
        return 'Pessoa Física';
      case TipoPessoa.juridica:
        return 'Pessoa Jurídica';
    }
  }
}

class FiltroClientes {
  TipoEntidade tipoEntidade;
  StatusCadastro statusCadastro;
  TipoPessoa tipoPessoa;
  DateTime? dataInicial;
  DateTime? dataFinal;
  Set<String> informacoesIncluidas;

  FiltroClientes({
    this.tipoEntidade = TipoEntidade.clientesFornecedores,
    this.statusCadastro = StatusCadastro.todos,
    this.tipoPessoa = TipoPessoa.todos,
    this.dataInicial,
    this.dataFinal,
    Set<String>? informacoesIncluidas,
  }) : informacoesIncluidas =
           informacoesIncluidas ?? {'Saldo', 'Compras', 'Pagamentos'};

  static List<String> get opcoesInformacoes => [
    'Saldo',
    'Compras',
    'Pagamentos',
    'Dados de Contato',
    'Histórico Completo',
  ];

  void limpar() {
    tipoEntidade = TipoEntidade.clientesFornecedores;
    statusCadastro = StatusCadastro.todos;
    tipoPessoa = TipoPessoa.todos;
    dataInicial = null;
    dataFinal = null;
    informacoesIncluidas = {'Saldo', 'Compras', 'Pagamentos'};
  }

  Map<String, dynamic> toMap() {
    final fmt = DateFormat('dd/MM/yyyy');
    return {
      'tipoEntidade': tipoEntidade.label,
      'statusCadastro': statusCadastro.label,
      'tipoPessoa': tipoPessoa.label,
      'dataInicial': dataInicial != null ? fmt.format(dataInicial!) : null,
      'dataFinal': dataFinal != null ? fmt.format(dataFinal!) : null,
      'informacoesIncluidas': informacoesIncluidas.toList(),
    };
  }
}

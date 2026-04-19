enum TipoRelatorio {
  contasPagarReceber,
  clientesFornecedores,
  usuarios,
  investimentosDescontos,
}

extension TipoRelatorioExt on TipoRelatorio {
  String get label {
    switch (this) {
      case TipoRelatorio.contasPagarReceber:
        return 'Contas a Pagar / Receber';
      case TipoRelatorio.clientesFornecedores:
        return 'Clientes / Fornecedores';
      case TipoRelatorio.usuarios:
        return 'Usuários';
      case TipoRelatorio.investimentosDescontos:
        return 'Investimentos / Descontos';
    }
  }

  String get descricao {
    switch (this) {
      case TipoRelatorio.contasPagarReceber:
        return 'Fluxo financeiro por entrada e saída';
      case TipoRelatorio.clientesFornecedores:
        return 'Movimentações e histórico por entidade';
      case TipoRelatorio.usuarios:
        return 'Ações e acessos por usuário do sistema';
      case TipoRelatorio.investimentosDescontos:
        return 'Rentabilidade, aportes e descontos aplicados';
    }
  }

  String get categoria {
    switch (this) {
      case TipoRelatorio.contasPagarReceber:
        return 'Financeiro';
      case TipoRelatorio.clientesFornecedores:
        return 'Cadastro';
      case TipoRelatorio.usuarios:
        return 'Acesso';
      case TipoRelatorio.investimentosDescontos:
        return 'Analítico';
    }
  }
}

enum FormatoExportacao { pdf, excel, csv }

extension FormatoExportacaoExt on FormatoExportacao {
  String get label {
    switch (this) {
      case FormatoExportacao.pdf:
        return 'PDF';
      case FormatoExportacao.excel:
        return 'Excel';
      case FormatoExportacao.csv:
        return 'CSV';
    }
  }
}

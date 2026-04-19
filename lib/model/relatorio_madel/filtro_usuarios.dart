import 'package:intl/intl.dart';

enum TipoUsuario { todos, administradores, operadores, visualizadores }

extension TipoUsuarioExt on TipoUsuario {
  String get label {
    switch (this) {
      case TipoUsuario.todos:
        return 'Todos os Usuários';
      case TipoUsuario.administradores:
        return 'Administradores';
      case TipoUsuario.operadores:
        return 'Operadores';
      case TipoUsuario.visualizadores:
        return 'Visualizadores';
    }
  }
}

enum ModuloSistema {
  todos,
  financeiro,
  cadastro,
  estoque,
  relatorios,
  configuracoes,
}

extension ModuloSistemaExt on ModuloSistema {
  String get label {
    switch (this) {
      case ModuloSistema.todos:
        return 'Todos';
      case ModuloSistema.financeiro:
        return 'Financeiro';
      case ModuloSistema.cadastro:
        return 'Cadastro';
      case ModuloSistema.estoque:
        return 'Estoque';
      case ModuloSistema.relatorios:
        return 'Relatórios';
      case ModuloSistema.configuracoes:
        return 'Configurações';
    }
  }
}

enum TipoAcao { todas, inclusao, edicao, exclusao, acesso }

extension TipoAcaoExt on TipoAcao {
  String get label {
    switch (this) {
      case TipoAcao.todas:
        return 'Todas as Ações';
      case TipoAcao.inclusao:
        return 'Inclusão';
      case TipoAcao.edicao:
        return 'Edição';
      case TipoAcao.exclusao:
        return 'Exclusão';
      case TipoAcao.acesso:
        return 'Login / Acesso';
    }
  }
}

class FiltroUsuarios {
  TipoUsuario tipoUsuario;
  ModuloSistema moduloSistema;
  DateTime? dataInicial;
  DateTime? dataFinal;
  TipoAcao tipoAcao;

  FiltroUsuarios({
    this.tipoUsuario = TipoUsuario.todos,
    this.moduloSistema = ModuloSistema.todos,
    this.dataInicial,
    this.dataFinal,
    this.tipoAcao = TipoAcao.todas,
  });

  void limpar() {
    tipoUsuario = TipoUsuario.todos;
    moduloSistema = ModuloSistema.todos;
    dataInicial = null;
    dataFinal = null;
    tipoAcao = TipoAcao.todas;
  }

  Map<String, dynamic> toMap() {
    final fmt = DateFormat('dd/MM/yyyy');
    return {
      'tipoUsuario': tipoUsuario.label,
      'moduloSistema': moduloSistema.label,
      'dataInicial': dataInicial != null ? fmt.format(dataInicial!) : null,
      'dataFinal': dataFinal != null ? fmt.format(dataFinal!) : null,
      'tipoAcao': tipoAcao.label,
    };
  }
}

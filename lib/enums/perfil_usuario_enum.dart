enum PerfilUsuarioEnum { MASTER, PLENO, BASICO}
  extension PerfilUsuarioEnumExtension on PerfilUsuarioEnum {
  String get label {
    switch (this) {
      case PerfilUsuarioEnum.MASTER:
        return "Master";
      case PerfilUsuarioEnum.PLENO:
        return "Pleno";
      case PerfilUsuarioEnum.BASICO:
        return "Básico";
    }
  }
}

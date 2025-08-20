// revisado 10/03/2024 author: @albertjjimenezp
// Simulación de SystemChrome para realizar pruebas
class ApplicationSwitcherDescription {
  ApplicationSwitcherDescription({
    this.label,
    this.primaryColor,
  });
  final String? label;
  final int? primaryColor;
}

class SystemChrome {
  static bool calledSetApplicationSwitcherDescription = false;
  static ApplicationSwitcherDescription? lastApplicationSwitcherDescription;

  static void setApplicationSwitcherDescription(
    ApplicationSwitcherDescription description,
  ) {
    calledSetApplicationSwitcherDescription = true;
    lastApplicationSwitcherDescription = description;
  }
}

void main() {}

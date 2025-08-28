# JocaaguraArchetype

> ⚠️ **Aviso importante (migración)**  
> Estamos trasladando la mayor parte de las responsabilidades de este paquete a [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain).  
> `JocaaguraArchetype` seguirá disponible por ahora, pero podría marcarse como **deprecated** en el futuro.  
> Recomendamos construir directamente sobre `jocaagura_domain`, que concentra BLoCs, contratos e infraestructura compartida.

![Coverage](https://img.shields.io/badge/coverage-86%25-brightgreen)
![Author](https://img.shields.io/badge/Author-@albertjjimenezp-brightgreen) 🐱‍👤

---

## ℹ️ Estado de la documentación

La documentación completa **está en progreso** y la **actualizaremos en breve**.  
Mientras tanto, este README resume lo esencial para empezar y te indica dónde encontrar la funcionalidad que se ha movido a `jocaagura_domain`.

Próximas secciones (WIP):
- Navegación (Router 2.0, `PageManager`, `PageRegistry`)
- Responsive (`BlocResponsive`, `WorkAreaWidget`)
- Menús y layout (`MainMenuWidget`, `PageWithSecondaryMenuWidget`)
- Overlays y notificaciones (`MySnackBarWidget`)
- Guías de pruebas y cobertura

---

## ¿Qué es este paquete?

`JocaaguraArchetype` es un arquetipo pensado para alinear funcionalidades transversales de apps Flutter dentro del ecosistema Jocaagura. Proporciona una base uniforme para construir experiencias responsivas, navegación por páginas y algunos widgets de UI listos para usar.

> Muchas piezas han sido **migradas** a [`jocaagura_domain`](https://pub.dev/packages/jocaagura_domain) para centralizar contratos y lógica compartida, reducir duplicación y simplificar el mantenimiento.

---

## Instalación rápida

```yaml
dependencies:
  jocaaguraarchetype: ^<última_versión>

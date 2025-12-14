# Responsive Flow & BlocResponsive Pattern

Centraliza cómo el arquetipo sincroniza `BlocResponsive` y cómo debes consumir sus métricas desde la UI, builders y tests.

---

## 1. Punto único de sincronización

| Elemento                     | Ubicación                                               | Responsabilidad                                                                              |
|------------------------------|---------------------------------------------------------|----------------------------------------------------------------------------------------------|
| `MaterialApp.router.builder` | `lib/ui/jocaagura_app.dart` (`_JocaaguraAppShellState`) | Llamar **una sola vez** a `appManager.responsive.setSizeFromContext(context)` en cada frame. |

```
  return MaterialApp.router(
    // ...router wiring...,
    builder: (BuildContext context, Widget? child) {
      appManager.responsive.setSizeFromContext(context);
      return child ?? const SizedBox.shrink();
    },
  );
```

Esto garantiza que:

* Toda la app comparte las mismas métricas (`columnsNumber`, `marginWidth`, etc.).
* Ningún widget necesita volver a invocar `setSizeFromContext` localmente.
* El stream `appScreenSizeStream` sólo se actualiza cuando cambia `MediaQuery` en la raíz.

> **Nunca** reproduzcas `responsive.setSizeFromContext(context)` dentro de widgets individuales. Si lo ves en un proyecto heredado, migra usando la guía de la sección 4.

---

## 2. Consumir métricas en la UI

Buenas prácticas:

1. **Obtén** `BlocResponsive` desde `AppManager` o parámetros inyectados (ej. `PageBuilder`, `MainMenuWidget`).
2. **Lee** propiedades derivadas (`columnsNumber`, `workAreaSize`, `widthByColumns`, etc.) sin modificar el bloc.
3. **Evita** `MediaQuery.of` directo en componentes reutilizables; usa los métodos de `BlocResponsive` para mantener consistencia.
4. **Builders base** (`PageBuilder`, `WorkAreaWidget`, `PageWithSecondaryMenuWidget`) ya usan estas métricas: revisa sus implementaciones para replicar patrones.

Snippet recomendado dentro de widgets:

```dart
class ExampleCard extends StatelessWidget {
  const ExampleCard({required this.responsive, super.key});
  final BlocResponsive responsive;

  @override
  Widget build(BuildContext context) {
    final double maxWidth = responsive.widthByColumns(3).clamp(280.0, 420.0);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Card(/* ... */),
    );
  }
}
```

---

## 3. Testing y `setSizeForTesting`

Para escenarios headless o pruebas unitarias:

1. Crea el bloc real o un fake que extienda `BlocResponsive`.
2. Llama a `setSizeForTesting(Size widthHeight)` para fijar las métricas.
3. Inyecta el bloc en el widget bajo prueba a través de sus parámetros o de un `AppManager` configurado.

Ejemplo (extraído de `test/ui/widgets/my_app_button_widget_test.dart`):

```
final BlocResponsive resp = BlocResponsive()
  ..setSizeForTesting(const Size(960, 600));

await tester.pumpWidget(
  MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(size: Size(960, 600)),
      child: MyAppButtonWidget(responsive: resp, label: 'Save', onPressed: () {}),
    ),
  ),
);
```

> Si necesitas simular cambios de tamaño en pruebas de integración, actualiza `tester.binding.window.physicalSizeTestValue` y vuelve a invocar `setSizeForTesting` con el nuevo `Size` antes de `pump()`.

---

## 4. Guía rápida de migración

1. **Busca** `setSizeFromContext` en tu código (widgets, drawers, builders heredados).
2. **Elimina** la llamada y cualquier flag asociado (`setFromCtxCalled`).
3. **Verifica** que el widget recibe `BlocResponsive` por parámetro o vía `context.appManager.responsive`.
4. **Actualiza tests** que esperaban la invocación manual (usa `setSizeForTesting`).
5. **Documenta** en tus componentes reutilizables que las métricas provienen del punto único en `JocaaguraApp`.

Checklist:

- [ ] `lib/ui/jocaagura_app.dart` → `builder` invoca `setSizeFromContext`.
- [ ] `PageBuilder` y shells custom sólo leen métricas.
- [ ] Fakes/tests usan `setSizeForTesting` o `MediaQuery`.
- [ ] Documentación del proyecto enlaza esta guía.

---

## 5. Referencias cruzadas

| Recurso                                       | Descripción                                                                                     |
|-----------------------------------------------|-------------------------------------------------------------------------------------------------|
| `doc/page-builder-doc.md`                     | Explica cómo `PageBuilder` y `PageScaffoldShell` consumen `BlocResponsive` sin duplicar lógica. |
| `lib/ui/widgets/work_area_widget.dart`        | Ejemplo real de layout que sólo lee métricas.                                                   |
| `test/ui/widgets/work_area_widget_test.dart`  | Pruebas que fijan tamaños con `setSizeForTesting`.                                              |
| `test/domain/blocs/bloc_responsive_test.dart` | Cobertura de `BlocResponsive` (`setSizeFromContext`, streams y helpers).                        |

---

## 6. FAQ

**¿Puedo seguir usando `MediaQuery` directamente?**
Sí, en widgets altamente específicos (p. ej. `LayoutBuilder`). Pero las superficies públicas del arquetipo deben favorecer `BlocResponsive` para mantener coherencia.

**¿Qué ocurre si necesito múltiple `MediaQuery` (p. ej. nested navigator)?**
Propaga `BlocResponsive` al sub-árbol y sigue leyendo sus métricas. Si el sub-árbol puede cambiar de tamaño de forma independiente, crea un bloc dedicado y sincronízalo desde el `LayoutBuilder` correspondiente.

**¿Cómo monitorizo cambios de tamaño para analytics o logs?**
Suscríbete a `responsive.appScreenSizeStream`. Recuerda administrar la suscripción para evitar fugas.

---

Mantén este documento actualizado cada vez que cambie el flujo responsivo o se agreguen nuevos helpers en `BlocResponsive`.


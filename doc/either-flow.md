# Guía para arquitectos de ModelFlowStep unidimensionales

## 1) Qué significa “unidimensional” en la práctica

En cada `ModelFlowStep` hay exactamente **dos salidas**:

- `nextOnSuccessIndex` (Right)
- `nextOnFailureIndex` (Left)

Eso ya permite decisiones. Pero “unidimensional” implica esta disciplina:

- El flujo describe **una sola intención** (ej: “Abrir app”, “Preparar limonada”, “Onboarding”, “Pago”).
- Cada paso hace **una cosa** (acción/validación/transformación).
- Si una decisión implica caminos con lógica extensa o distinta intención, **no metas todo ahí**:
    - el paso “decide”
    - y el siguiente índice te lleva a un paso que **dispara otro flujo** (o termina y el orquestador cambia de flujo).

Así mantienes el flujo “lineal por intención” y el branching se vuelve “cambio de flujo”.

---

## 2) Cómo construirlo efectivamente (método que funciona)

### Paso A — Define el contrato del flujo (1–3 líneas)

- **Name**: “Lemonade”
- **Description**: “Preparar limonada con verificación de sabor”
- **Done**: ¿Qué significa “END” aquí? (ej: “servida”)

Esto evita que termines mezclando pasos de otra cosa.

### Paso B — Lista pasos como “verbo + objeto”

Ejemplos:

1. Reunir ingredientes
2. Agregar 1 litro de agua
3. Exprimir 4 limones
4. Agregar 2 cucharadas de azúcar y probar
5. Agregar 2 cucharadas de azúcar y probar
6. Servir

Aquí ya tienes el backbone.

### Paso C — Decide qué pasos son “decisión”

Un paso es **decisión** si:

`nextOnSuccessIndex != nextOnFailureIndex`

Ej: “Probar”:

- Success → 6
- Failure → 5

Esto te da un punto claro de branching.

### Paso D — Asigna índices pensando en legibilidad

Convenciones útiles:

- Índices ascendentes por orden “principal”.
- Los “ajustes” o “reintentos” van inmediatamente después.
- Deja espacios si crees que crecerá (0,10,20…) o consecutivo si el editor ya te lo facilita.

Lo importante no es el número, es que sea **estable y fácil de leer**.

### Paso E — Define failureCode como “telemetría”

`failureCode` no es solo “si falla”; es el **identificador de trazabilidad** del paso. Reglas prácticas:

- Prefijo por dominio: `LEMONADE.*`, `APP.*`, `AUTH.*`
- Acción concreta: `LEMONADE.TASTE_1`
- Que sea estable (no dependas del índice).

Te ayuda a:

- mapear a `ErrorItem.code`
- generar analytics y bitácoras
- rastrear dónde muere un flujo

### Paso F — Constraints y cost: úsalo como “metadata útil”, no como lógica

- `constraints` describen **condiciones/links/métricas** para UI/QA/documentación.
- `cost` te permite sumar costos del camino simulado.

Reglas prácticas:

- constraints deben ser **renderizables** y **human-friendly**
- cost keys deben tener unidad embebida (como ya haces): `timeMin`, `networkKb`, `latencyMs`

---

## 3) Consideraciones clave del arquitecto (lo que evita dolores)

### 3.1 Evita rutas rotas (missing indexes)

Esto es lo más común cuando editas. Checklist:

- Cada `nextOn*Index` debe ser `-1` o existir en `stepsByIndex`.
- Si cambias un índice, recuerda que **no hay auto-rewire** (el editor lo advierte y el UI lo puede marcar).

Recomendación: mantener una validación “lint” del flujo (aunque sea en tests o en una pantalla interna).

### 3.2 Controla loops conscientemente

Un loop puede ser válido (reintento), pero debe ser **intencional** y acotado.
El arquitecto debe:

- definir máximo de reintentos como pasos explícitos (Taste_1, Taste_2, END)
- evitar “volver atrás” a pasos muy anteriores salvo que sea una subrutina clara

En flujos de producto, lo normal es:

- reintentar 1–2 veces
- luego finalizar o disparar un flujo alterno (ej: “fallback”, “soporte”, “error handling”)

### 3.3 Un paso debe ser atómico

Si un paso hace demasiadas cosas:

- no puedes medir costo bien
- no puedes debugear
- no puedes reusar

Regla: “si para describirlo necesitas ‘y luego’ dos veces, está demasiado grande”.

### 3.4 Decide cuándo separar en otro flujo

Separar en otro flujo cuando:

- cambia la intención (de “abrir app” a “login”)
- se abre una variante grande (pago con tarjeta vs PSE vs QR)
- hay un subproceso reusable (verificación OTP, verificación identidad)

Entonces:

- el flujo actual termina (`-1`)
- o va a un paso “Bridge/Dispatch” que explícitamente indica: “Launch FLOW_X”

### 3.5 Diseña constraints como UI-first

Formato recomendado y consistente:

- `flag:requiresInternet`
- `metric:sugar|2|tbsp`
- `url:figma|https://...`

Piensa:

- “¿Qué quiero que vea QA / PO / Dev en la tarjeta del paso?”
- “¿Qué links necesito para soporte (Figma, Jira, Docs)?”
- “¿Qué valores ayudan a entenderlo (gramos, watts, intentos, tiempo)?”

### 3.6 Mantén END explícito y semántico

Usar `-1` está bien, pero el arquitecto debería:

- definir si `END` significa “done”, “cancelled”, “failed”, “handoff”
- si necesitas diferenciar, crea pasos finales distintos:
    - “Serve lemonade” (END success)
    - “Stop: not sweet enough” (END failure)

Esto hace el flujo legible y auditable.

### 3.7 Pensar en observabilidad desde el diseño

Lo que más vale en producción:

- `failureCode`
- pasos visitados
- aggregated cost
- constraints que expliquen contexto

Eso te da:

- “por qué falló”
- “en qué paso”
- “cuánto costó”
- “qué dependencia faltaba”

---

## 4) Convenciones de naming (formalización)

### 4.1 `ModelCompleteFlow.name`

- **Formato:** `Domain.Action` o `Domain.Process`
- **Ejemplos:**
    - `App.Launch`
    - `Auth.Login`
    - `Lemonade.Prepare`
    - `Payment.Checkout`

### 4.2 `ModelCompleteFlow.description`

- 1–2 líneas: intención + criterio de finalización.
- Ejemplo: “Abre la app y decide destino inicial. END cuando se muestra Home o se reporta error.”

### 4.3 `ModelFlowStep.title`

- **Verbo + objeto**, corto (máx 40–50 chars).
- Ejemplos:
    - `Gather ingredients`
    - `Squeeze lemons`
    - `Validate session`
    - `Dispatch Login flow`

### 4.4 `failureCode` (clave de trazabilidad)

Este es el “ID estable” del paso.

**Formato recomendado**

`<FLOW>.<STAGE>.<ACTION>[_<VARIANT>]`

- `<FLOW>`: compacto: `APP`, `AUTH`, `PAY`, `LEMONADE`
- `<STAGE>`: `START`, `CHECK`, `BUILD`, `TASTE`, `ROUTE`, `END`, etc.
- `<ACTION>`: verbo concreto: `LAUNCH`, `SESSION`, `WATER`, `SQUEEZE`, `OTP`
- `<VARIANT>` opcional: `1`, `2`, `A`, `B` (para reintentos)

**Ejemplos**

- `APP.START.LAUNCH`
- `AUTH.CHECK.SESSION`
- `LEMONADE.BUILD.WATER`
- `LEMONADE.TASTE.SWEETNESS_1`
- `LEMONADE.TASTE.SWEETNESS_2`

**Anti-patrones**

- No metas el índice en el code (cambia con ediciones).
- No uses códigos genéricos tipo `UNKNOWN` salvo en defaults.

---

## 5) Índices y estructura del flujo

### 5.1 Estilo de índices

Escoge una de estas 2 y úsala siempre en el repo:

**Opción A — consecutivo (0,1,2,3…)**

- + simple, ideal para examples y flows chicos.
- – insertas pasos y reordenas más a menudo.

**Opción B — espaciado (0,10,20,30…)**

- + permite insertar sin reindexar todo.
- recomendado para flows que crecen.

### 5.2 END

- `-1` siempre significa **END**.
- Evita terminar “a la fuerza” con rutas rotas; si es final, usa `-1`.

### 5.3 Pasos finales explícitos

Si necesitas distinguir finales:

- `Serve lemonade` (success end)
- `Stop: not sweet enough` (failure end)

Ambos van a `-1/-1`, pero se diferencian por `title + failureCode`.

---

## 6) Decisiones sin romper la unidimensionalidad

### 6.1 Regla de oro

Un paso es **decisión** si:

`nextOnSuccessIndex != nextOnFailureIndex`

### 6.2 Decisión “corta”

Ideal: deriva a ajuste inmediato o END.

- Ejemplo: `Taste_1` → fail a `Taste_2`, success a `Serve`.

### 6.3 Decisión “larga” ⇒ separar en otro flujo

Si success/failure abre procesos grandes:

- Termina el flujo o envía a un paso `Dispatch <X>` que conceptualmente “lanza otro flow”.

**Convención de paso puente**

- Title: `Dispatch <FlowName>`
- failureCode: `APP.ROUTE.AUTH_FLOW` (por ejemplo)
- constraints: `url:docs|...` / `flag:requiresInternet`
- (y el orquestador real fuera del example hace el cambio de flujo)

---

## 7) Constraints: mini-DSL oficial

### 7.1 Formatos permitidos

1) **Flag**
- `flag:<name>`
- Ej: `flag:requiresInternet`

1) **Metric**
- `metric:<name>|<value>|<unit>`
- Ej: `metric:sugar|2|tbsp`

1) **URL**
- `url:<label>|<absoluteUrl>`
- Ej: `url:figma|https://...`

### 7.2 Reglas de normalización

- `<name>`, `<unit>`, `<label>`: `trim + lowercase`
- `<value>`: finito (si no, `0.0`)
- URL: idealmente `https` y absoluta

### 7.3 Taxonomía recomendada

**Flags comunes**
- `flag:requiresInternet`
- `flag:requiresAuth`
- `flag:requiresLocation`
- `flag:requiresBatteryAbove15Percent`
- `flag:requiresPermissionCamera`

**Metrics comunes**
- `metric:time|2|min` (o `metric:timeMin|2|min` — elige uno y estandariza)
- `metric:network|12.5|kb`
- `metric:dbReads|2|count`
- `metric:sugar|2|tbsp`

**URLs comunes**
- `url:figma|...`
- `url:jira|...`
- `url:docs|...`
- `url:api|...`

### 7.4 Compatibilidad hacia atrás

Si llega un string legacy (ej: markdown), se trata como `flag`.
Regla: el simulador **no revienta**.

---

## 8) Cost: métricas agregables por simulación

### 8.1 Reglas

- `cost` debe ser **no negativo**
- keys deben implicar unidad: `timeMin`, `latencyMs`, `networkKb`, `dbReadsCount`

### 8.2 Convención recomendada

- `timeMin`
- `latencyMs`
- `networkKb`
- `cpuMs`
- `retriesCount`

---

## 9) Reglas de calidad (lint mental del arquitecto)

Antes de aprobar un flujo:

1. **Cobertura de índices**: todo `nextOn*` es `-1` o existe.
2. **Sin loops accidentales**: si hay loops, son intencionales y acotados.
3. **Paso atómico**: cada step es una acción/decisión clara.
4. **Trazabilidad**: `failureCode` es estable y describible.
5. **Consistencia**: constraints siguen el DSL oficial.
6. **Escalabilidad**: decisiones grandes “saltan” a otro flujo, no crean árboles dentro.

---

## 10) Convenciones UI-first para el simulador

- Paso decisión → icono “route/alt_route”.
- `nextIndex` inexistente → warning visible.
- `url:*` → lista con validación `https`.
- `metric:*` → chips `name: value unit`.
- `flag:*` → chips simples.

---

## 11) Ejemplo de flow “bien formado”

- `0` Gather ingredients → `1` / END
- `10` Add water → `20` / END
- `20` Squeeze lemons → `30` / END
- `30` Taste_1 → success `50`, failure `40`
- `40` Taste_2 → success `50`, failure END
- `50` Serve → END/END

---

## 12) Plantilla mental rápida para el arquitecto

Antes de cerrar un flujo, responde:

1. **Intención:** ¿Este flujo cuenta una sola historia?
2. **Atomización:** ¿Cada paso es una sola acción?
3. **Rutas:** ¿Todos los next apuntan a un step existente o END?
4. **Decisiones:** ¿Las decisiones están limitadas y claras?
5. **Loops:** ¿Hay loops? ¿Son intencionales y acotados?
6. **Trazabilidad:** ¿failureCode es estable y útil?
7. **Metadata:** ¿constraints y cost ayudan a UI/QA/soporte?
8. **Escalamiento:** ¿Si crece, sé dónde cortar en otro flujo?

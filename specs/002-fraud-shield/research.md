# Research: Escudo Antifraude (002-fraud-shield)

## R1: Motor de reglas en Dart puro

**Decision**: Clase `RiskEngine` en `domain/services/` que recibe un `OperationContext`, un `RiskThresholds`, y un historial de operaciones. Retorna un `RiskAlert?` (null = sin riesgo). Dart puro: no importa Flutter, no depende de providers ni widgets.

**Rationale**: El usuario lo pidió explícitamente: "motor de reglas en Dart puro dentro de domain, testeable sin UI". Alineado con Principio III (dominio es Dart puro). Permite unit tests rápidos sin `WidgetTester`, con cobertura exhaustiva de todas las combinaciones de reglas.

**Signature**:
```dart
class RiskEngine {
  RiskAlert? evaluate({
    required OperationContext operation,
    required List<Operation> history,
    required RiskThresholds thresholds,
  });
}
```

**Alternatives considered**:
- Reglas como providers de Riverpod: mezcla lógica de negocio con framework. Viola Principio III.
- Reglas en JSON/YAML configurables: sobreingeniería para 4 reglas fijas en un prototipo.

## R2: Umbrales configurables

**Decision**: Clase `RiskThresholds` (freezed) con valores por defecto que se pueden sobreescribir en tests o para personalización futura.

**Umbrales del prototipo** (de la sección Assumptions del spec):
| Regla | Umbral | Justificación |
|-------|--------|---------------|
| Monto inusual | `amountMultiplier: 2.0` | Alerta si monto > 2x promedio últimas 10 ops del mismo tipo |
| Destinatario nuevo | N/A (binario) | Alerta si el contacto no tiene historial de transacciones |
| Frecuencia alta | `maxOpsInWindow: 3`, `windowMinutes: 10` | Alerta si >3 ops en 10 min |
| Horario inusual | `safeHourStart: 7`, `safeHourEnd: 22` | Alerta si hora fuera de 7:00–22:00 |

**Rationale**: freezed genera `copyWith`, permitiendo override en tests: `RiskThresholds().copyWith(amountMultiplier: 1.5)`. Los valores default vienen del spec, configurables sin recompilar.

**Alternatives considered**:
- Constantes hardcodeadas: no configurables, difícil de testear edge cases.
- Config en archivo JSON: innecesario para un prototipo con 4 reglas fijas.

## R3: Las 4 reglas de riesgo

**Decision**: Enum `RiskRule` con 4 valores. Cada regla es un método privado del `RiskEngine` que retorna `true/false`. El engine evalúa todas y combina las activadas.

**Implementación por regla**:

1. **`unusualAmount`**: Calcula promedio de las últimas N operaciones del mismo tipo (pago o transferencia). Si `operation.amount > average * thresholds.amountMultiplier` → activada. Si no hay historial suficiente, no se activa (beneficio de la duda).

2. **`newRecipient`**: Busca `operation.recipientId` en el historial. Si no aparece en ninguna operación anterior → activada. Solo aplica a transferencias (los recibos tienen destinatario fijo).

3. **`highFrequency`**: Cuenta operaciones en `history` con `date` dentro de los últimos `thresholds.windowMinutes` minutos. Si count ≥ `thresholds.maxOpsInWindow` → activada.

4. **`unusualTime`**: Evalúa `operation.timestamp.hour`. Si `< thresholds.safeHourStart` o `>= thresholds.safeHourEnd` → activada.

**Alternatives considered**:
- Reglas como clases separadas (Strategy pattern): sobreingeniería para 4 reglas simples. YAGNI.
- Machine learning: completamente fuera del alcance de un prototipo de 4 semanas.

## R4: Combinación de alertas en un solo mensaje

**Decision**: `RiskAlert` contiene un `Set<RiskRule>` con todas las reglas activadas. El mensaje combinado se construye en la capa de presentación consultando las claves ARB correspondientes y concatenándolas con conectores.

**Rationale**: FR-009 exige una sola pantalla. El motor retorna las reglas activadas (dominio), y la presentación construye el mensaje localizado (ARB). Separación limpia.

**Patrón de mensajes ARB**:
- 1 regla: `"Este pago es mucho más alto de lo que sueles pagar."`
- 2+ reglas: `"Nunca le has enviado dinero a esta persona y el monto es más alto de lo habitual."`
- Cierre empático (siempre): `"Solo queremos asegurarnos. ¿Qué quieres hacer?"`

**Alternatives considered**:
- Mensajes generados dinámicamente con templates: más flexible pero más complejo. Para 4 reglas, las combinaciones son manejables (≤15 combinaciones) y se pueden cubrir con claves ARB específicas por combinación común + fallback genérico.

## R5: Integración con flujos de 001

**Decision**: El escudo se ejecuta en el paso de navegación entre la pantalla de ingreso de datos y la confirmación. En el provider de cada flujo (pay_bill, send_money), antes de navegar a `ConfirmScreen`, se llama al `RiskEngine`. Si retorna `RiskAlert`, se navega a `FraudAlertScreen` en vez de `ConfirmScreen`.

**Flujo de navegación**:
```
PayBillScreen → [RiskEngine.evaluate()] → FraudAlertScreen? → PayBillConfirmScreen
SendMoneyScreen → [RiskEngine.evaluate()] → FraudAlertScreen? → SendMoneyConfirmScreen
```

**Acciones en FraudAlertScreen**:
- "Cancelar" → `context.pop()` (vuelve a PayBillScreen/SendMoneyScreen, datos preservados en provider)
- "Continuar" → `context.go()` a la confirmación normal de 001
- "Consultar a [nombre]" → simular notificación + mostrar mensaje "Le avisamos a [nombre]"

**Rationale**: El escudo es un interceptor de navegación, no modifica los providers de 001. Los datos de la operación se pasan como parámetros de ruta (o via provider compartido). El flujo de 001 no necesita saber que el escudo existe — solo la navegación cambia.

**Alternatives considered**:
- Middleware en go_router: go_router tiene `redirect`, pero no es ideal para mostrar una pantalla intermedia condicional. Navegación explícita es más claro.
- Modificar los providers de 001: acopla 001 a 002. Mejor que 002 sea un interceptor independiente.

## R6: Historial de operaciones para el motor

**Decision**: Reutilizar `OperationRepository` de 001-easy-mode (que ya registra pagos y transferencias completadas) + precargar historial ficticio para que las reglas tengan datos contra los cuales comparar.

**Historial precargado** (mock):
- 10 pagos de recibos en el último mes: montos entre S/ 40 y S/ 130
- 5 transferencias a contactos conocidos: montos entre S/ 50 y S/ 200
- Horarios: todos entre 8:00 y 20:00
- Solo a contactos existentes (Valeria, Carlos, María)

Esto establece una línea base para que las reglas detecten anomalías.

**Alternatives considered**:
- Repository separado solo para historial: duplica funcionalidad de `OperationRepository` de 001.
- Generar historial dinámicamente: innecesario, datos mock hardcodeados son suficientes.

## R7: Mensajes empáticos en ARB

**Decision**: Claves ARB para cada regla y para las combinaciones más comunes. Tono empático: "Solo queremos asegurarnos", nunca "Operación sospechosa".

**Claves principales**:
```
fraudShield_alert_unusualAmount: "Este pago es mucho más alto de lo que sueles pagar."
fraudShield_alert_newRecipient: "Nunca le has enviado dinero a esta persona."
fraudShield_alert_highFrequency: "Has hecho varios pagos seguidos."
fraudShield_alert_unusualTime: "Estás haciendo un pago a una hora poco habitual."
fraudShield_alert_closing: "Solo queremos asegurarnos. ¿Qué quieres hacer?"
fraudShield_action_cancel: "Cancelar"
fraudShield_action_continue: "Continuar de todos modos"
fraudShield_action_consultTrusted: "Consultar a {name}"
fraudShield_notification_sent: "Le avisamos a {name}. Puedes esperarle o continuar."
```

Todas las frases ≤15 palabras. Sin jerga bancaria.

**Alternatives considered**:
- Mensajes hardcodeados: viola Principio VII (textos en ARB).
- Generación dinámica por IA: fuera del alcance de esta feature (el asistente IA es feature 004).

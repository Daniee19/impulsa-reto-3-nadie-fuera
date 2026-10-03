# Risk Engine Contract (002-fraud-shield)

El motor de reglas de riesgo es el servicio central de esta feature. Es Dart puro, sin dependencias de Flutter, y vive en `domain/services/`.

Ubicación: `lib/features/fraud_shield/domain/services/risk_engine.dart`

## RiskEngine

```dart
class RiskEngine {
  /// Evalúa una operación contra las reglas de riesgo.
  /// Retorna null si no se detecta riesgo.
  /// Retorna RiskAlert con las reglas activadas si se detecta riesgo.
  RiskAlert? evaluate({
    required OperationContext operation,
    required List<Operation> history,
    RiskThresholds thresholds = const RiskThresholds(),
  });
}
```

**Contrato**:
- Evalúa las 4 reglas en orden: `unusualAmount`, `newRecipient`, `highFrequency`, `unusualTime`.
- Retorna `null` si ninguna regla se activa → flujo normal de 001.
- Retorna `RiskAlert` con todas las reglas activadas si al menos una se activa → navegar a `FraudAlertScreen`.
- Es determinístico: mismos inputs → mismo output. Sin efectos secundarios.
- No accede a providers, repositorios, ni estado global. Recibe todo como parámetros.

## Contrato de integración con 001-easy-mode

El escudo se invoca desde los providers de pago/transferencia de 001, justo antes de la navegación a la pantalla de confirmación.

```dart
// En el provider de PayBillScreen o SendMoneyScreen (001):

Future<void> proceedToConfirmation(OperationContext operation) async {
  final history = await ref.read(operationRepositoryProvider).getOperations();
  final engine = RiskEngine();
  final alert = engine.evaluate(
    operation: operation,
    history: history,
  );

  if (alert != null) {
    // Navegar a FraudAlertScreen con el alert como parámetro
    // FraudAlertScreen maneja las 3 opciones
    ref.read(fraudAlertProvider.notifier).setAlert(alert);
    context.push('/easy-mode/fraud-alert');
  } else {
    // Flujo normal de 001: ir a confirmación
    context.push('/easy-mode/pay-bill/${billId}/confirm');
  }
}
```

## Contrato de integración con 006-trusted-person

`FraudAlertScreen` consulta el estado de la persona de confianza para decidir cuántas opciones mostrar.

```dart
// En FraudAlertScreen:

final trustedPerson = ref.watch(trustedPersonProvider).valueOrNull;
final showConsultOption = trustedPerson != null &&
    trustedPerson.hasPermission(TrustedPermission.securityAlerts);

// Opciones:
// 1. "Cancelar" — siempre
// 2. "Continuar de todos modos" — siempre
// 3. "Consultar a [trustedPerson.name]" — solo si showConsultOption

// Al elegir "Consultar":
// - Simular notificación: mostrar dialog con lo que recibiría el familiar
// - Contenido del aviso: tipo de operación, destinatario, monto
// - Mostrar mensaje: "Le avisamos a [nombre]. Puedes esperarle o continuar."
// - Dejar al usuario en FraudAlertScreen con opciones "Cancelar" y "Continuar"
```

## Rutas de navegación

```
/easy-mode/fraud-alert    → FraudAlertScreen
```

Esta ruta recibe el `RiskAlert` via el `fraudAlertProvider` (no como query param, porque contiene objetos complejos).

## Acciones y sus efectos

| Acción | Efecto en navegación | Efecto en datos |
|--------|---------------------|-----------------|
| "Cancelar" | `context.pop()` → vuelve a PayBillScreen/SendMoneyScreen | Datos del formulario preservados en provider |
| "Continuar" | `context.go()` → ConfirmScreen de 001 | Operación continúa flujo normal |
| "Consultar a [nombre]" | Se queda en FraudAlertScreen, muestra confirmación de aviso | Simulación de notificación |

## OperationHistoryRepository (para el motor)

```dart
abstract class OperationHistoryRepository {
  /// Obtiene las últimas N operaciones del usuario.
  Future<List<Operation>> getRecentOperations({int limit = 20});

  /// Obtiene operaciones de un tipo específico.
  Future<List<Operation>> getOperationsByType(OperationType type, {int limit = 10});

  /// Verifica si el usuario ha enviado dinero a este destinatario antes.
  Future<bool> hasTransactionHistoryWith(String recipientId);
}
```

Esta interfaz puede ser implementada por el `MockOperationRepository` de 001 (extendido con los métodos de consulta) o por un repository separado que wrappee el de 001. Decisión de implementación para `/speckit-tasks`.

## Invariantes

1. **Toda operación monetaria pasa por el motor**: no hay bypass. Si se agrega un nuevo flujo monetario, debe llamar a `RiskEngine.evaluate()`.
2. **El motor es stateless**: no mantiene estado entre llamadas. Cada evaluación es independiente.
3. **Nunca bloquea**: siempre retorna opciones para el usuario. `null` = sin riesgo (continuar). `RiskAlert` = riesgo (con opciones para decidir).
4. **Una sola pantalla por operación**: múltiples reglas → un solo `RiskAlert` → una sola `FraudAlertScreen`.
5. **Cancelar no aprueba**: no hay caché de "operación revisada". Cada intento se evalúa desde cero.

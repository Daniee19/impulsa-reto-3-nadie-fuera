# Assistant Service Contract (004-voice-text-assistant)

Este servicio orquesta el flujo del asistente de voz y texto: interpreta intenciones, prepara operaciones con datos reales, y coordina confirmación biométrica.

## IntentParser

Ubicación: `lib/features/voice_assistant/domain/services/intent_parser.dart`

Dart puro. Sin dependencias de Flutter.

```dart
class IntentParser {
  /// Interpreta una frase en español y retorna la intención identificada.
  /// Lista cerrada: checkBalance, payBill, sendMoney, requestHelp, unknown.
  /// NUNCA adivina. Si la confianza es insuficiente, retorna unknown.
  ParsedIntent parse(String input);
}
```

**Contrato**:
- `parse()` SIEMPRE retorna un `ParsedIntent` válido (nunca null, nunca throw).
- Si `input` es vacío o no se mapea a ninguna intención → `AssistantIntentType.unknown`.
- Los parámetros extraídos (`IntentParameters`) son sugerencias del texto, NO datos definitivos. El `OperationPreparer` los valida contra repositorios.
- El parser NO accede a repositorios ni a datos de la cuenta. Solo procesa texto.
- El parser es determinístico: la misma entrada siempre produce la misma salida.

**Keywords de matching** (referencia, no exhaustivo):
```dart
// checkBalance
const _balanceKeywords = ['saldo', 'cuánto tengo', 'cuánto hay',
    'mi plata', 'mi dinero', 'balance', 'cuenta'];

// payBill
const _payKeywords = ['pagar', 'recibo', 'servicio'];
const _serviceKeywords = ['luz', 'agua', 'gas', 'teléfono', 'internet',
    'cable', 'electricidad'];

// sendMoney
const _sendKeywords = ['enviar', 'mandar', 'transferir', 'envía',
    'manda', 'transfiere'];

// requestHelp
const _helpKeywords = ['ayuda', 'ayúdame', 'no sé', 'no entiendo',
    'hablar con alguien', 'persona'];
```

## OperationPreparer

Ubicación: `lib/features/voice_assistant/domain/services/operation_preparer.dart`

Dart puro. Recibe repositorios como dependencias inyectadas.

```dart
class OperationPreparer {
  final AccountRepository _accountRepo;
  final BillRepository _billRepo;
  final ContactRepository _contactRepo;

  OperationPreparer({
    required AccountRepository accountRepo,
    required BillRepository billRepo,
    required ContactRepository contactRepo,
  });

  /// Prepara una operación a partir de la intención parseada.
  /// Resuelve parámetros contra datos reales del repositorio.
  /// Retorna OperationSummary si todo está listo, o un PrepareResult
  /// que indica qué dato falta.
  Future<PrepareResult> prepare(ParsedIntent intent);
}
```

**Enum `PrepareResult`** (sealed class):
```dart
sealed class PrepareResult {
  const PrepareResult();
}

class PrepareSuccess extends PrepareResult {
  final OperationSummary summary;
  const PrepareSuccess(this.summary);
}

class PrepareNeedsService extends PrepareResult {
  final List<Bill> pendingBills;
  const PrepareNeedsService(this.pendingBills);
}

class PrepareNeedsContact extends PrepareResult {
  final List<SavedContact> contacts;
  const PrepareNeedsContact(this.contacts);
}

class PrepareNeedsAmount extends PrepareResult {
  final String contactName;
  const PrepareNeedsAmount(this.contactName);
}

class PrepareBillNotFound extends PrepareResult {
  final String serviceName;
  const PrepareBillNotFound(this.serviceName);
}

class PrepareBalanceResult extends PrepareResult {
  final double balance;
  const PrepareBalanceResult(this.balance);
}
```

**Contrato de seguridad**:
- `prepare()` obtiene montos y nombres SOLO de los repositorios.
- Los `IntentParameters` del parser son hints para buscar en el repo, no datos definitivos.
- Si `intent.parameters.serviceName` es "luz" → busca en `billRepo.getPendingBills()` un recibo cuyo `serviceName` contenga "luz". El monto viene de `bill.amount`, no del parser.
- Si el contacto no se resuelve con certeza → retorna `PrepareNeedsContact` con la lista para que el usuario elija.

## Contrato de integración con 001-easy-mode

El asistente usa los mismos repositorios de 001 para datos y para ejecutar operaciones:

```dart
// Obtener saldo
final account = await accountRepo.getAccount();
final balance = account.availableBalance;

// Buscar recibo por servicio
final bills = await billRepo.getPendingBills();
final match = bills.where(
  (b) => b.serviceName.toLowerCase().contains(serviceName),
).toList();

// Resolver contacto
final contacts = await contactRepo.getContacts();
final match = contacts.where(
  (c) => c.name.toLowerCase().contains(contactName),
).toList();

// Ejecutar operación (después de confirmación biométrica)
await operationRepo.createOperation(Operation(...));
await billRepo.payBill(billId);  // o
await accountRepo.updateBalance(newBalance);
```

## Contrato de integración con 002-fraud-shield

Después de preparar la operación y antes de pedir confirmación biométrica:

```dart
// En VoiceAssistantProvider:
final alert = riskEngine.evaluate(
  context: OperationContext(
    type: summary.type == OperationType.payment
        ? OperationContextType.payment
        : OperationContextType.transfer,
    amount: summary.amount,
    recipientId: summary.recipientId,
    recipientName: summary.recipientName,
    timestamp: DateTime.now(),
  ),
  history: await operationHistoryRepo.getRecent(),
);

if (alert.triggeredRules.isNotEmpty) {
  // Navegar a FraudAlertScreen (002) con la alerta
  // Las 3 opciones de 002 aplican: cancelar, continuar, consultar familiar
  // Si continúa → volver a awaitingConfirmation
}
```

## Contrato de integración con 003-contextual-human-help

Si la intención es "pedir ayuda":

```dart
if (intent.type == AssistantIntentType.requestHelp) {
  // Actualizar contexto de operación si hay sesión activa
  if (session.operationSummary != null) {
    ref.read(operationInProgressProvider.notifier).set(
      OperationInProgress(
        type: session.operationSummary!.type,
        amount: session.operationSummary!.amount,
        recipientName: session.operationSummary!.recipientName,
        recipientId: session.operationSummary!.recipientId,
      ),
    );
  }
  // Delegar al flujo de ayuda de 003
  context.push('/easy-mode/help/contact-picker');
}
```

## Rutas de navegación

```
/easy-mode/assistant                → VoiceAssistantScreen
/easy-mode/assistant/consent        → MicrophoneConsentScreen
/easy-mode/assistant/summary        → OperationSummaryScreen (resumen + biometría)
```

Las rutas de fraude (002) y ayuda (003) se acceden via `context.push()` desde el provider, preservando el estado del asistente.

## Invariantes

1. **Lista cerrada**: IntentParser solo retorna valores del enum AssistantIntentType. No puede inventar intenciones nuevas.
2. **IA no ejecuta**: El parser identifica intención. El preparer resuelve datos. El usuario confirma con huella. Tres barreras antes de ejecutar.
3. **Datos reales siempre**: OperationSummary.amount y .recipientName vienen del repositorio, nunca del texto parseado.
4. **No adivinar**: Si type == unknown o confianza insuficiente, el asistente pregunta. Nunca ejecuta con dudas.
5. **Audio efímero**: El texto reconocido vive solo en VoiceSession (in-memory). No se persiste. El audio raw nunca se captura por la app (lo maneja speech_to_text internamente y lo descarta).
6. **Consentimiento antes de micrófono**: Si `microphone_consent_granted` es false, el botón de micrófono navega a la pantalla de consentimiento, no activa el micrófono.
7. **Solo contactos guardados**: sendMoney solo resuelve contactos de ContactRepository. "Cuenta nueva 12345" → rechazado con mensaje explicativo.

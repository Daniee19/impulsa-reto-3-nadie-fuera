# Practice Mode Contract (008-practice-mode)

El modo práctica reutiliza los flujos de 001 con repositorios aislados inyectados via ProviderScope override.

## Practice Repositories

Ubicación: `lib/features/practice_mode/data/repositories/`

Cada uno implementa la interfaz abstracta correspondiente de 001 (`lib/features/easy_mode/domain/repositories/`).

### PracticeAccountRepository

```dart
class PracticeAccountRepository implements AccountRepository {
  Account _account = const Account(
    id: 'practice-account',
    holderName: 'Cuenta de práctica',
    maskedNumber: '****0000',
    availableBalance: 5000.0,
    currency: 'PEN',
  );

  @override
  Future<Account> getAccount() async => _account;

  @override
  Future<Account> updateBalance(String accountId, double newBalance) async {
    _account = _account.copyWith(availableBalance: newBalance);
    return _account;
  }

  /// Restaura saldo y estado al valor inicial.
  void reset() {
    _account = _account.copyWith(availableBalance: 5000.0);
  }
}
```

### PracticeBillRepository

```dart
class PracticeBillRepository implements BillRepository {
  List<Bill> _bills = _initialBills();

  static List<Bill> _initialBills() => [
    Bill(id: 'p-bill-1', serviceName: 'Luz', providerName: 'Enel Práctica',
         amount: 95.0, dueDate: ..., status: BillStatus.pending),
    Bill(id: 'p-bill-2', serviceName: 'Agua', providerName: 'Sedapal Práctica',
         amount: 38.0, dueDate: ..., status: BillStatus.pending),
    Bill(id: 'p-bill-3', serviceName: 'Teléfono', providerName: 'Movistar Práctica',
         amount: 55.0, dueDate: ..., status: BillStatus.pending),
  ];

  @override
  Future<List<Bill>> getBills({BillStatus? status}) async {
    if (status != null) return _bills.where((b) => b.status == status).toList();
    return _bills;
  }

  @override
  Future<Bill> getBillById(String billId) async =>
    _bills.firstWhere((b) => b.id == billId);

  @override
  Future<Bill> payBill(String billId) async {
    _bills = _bills.map((b) =>
      b.id == billId ? b.copyWith(status: BillStatus.paid) : b
    ).toList();
    return _bills.firstWhere((b) => b.id == billId);
  }

  void reset() { _bills = _initialBills(); }
}
```

### PracticeContactRepository

```dart
class PracticeContactRepository implements ContactRepository {
  static const _contacts = [
    SavedContact(id: 'p-contact-1', name: 'Ana García', initial: 'A', maskedAccount: '****1111'),
    SavedContact(id: 'p-contact-2', name: 'Pedro Ruiz', initial: 'P', maskedAccount: '****2222'),
    SavedContact(id: 'p-contact-3', name: 'Lucía Torres', initial: 'L', maskedAccount: '****3333'),
  ];

  @override
  Future<List<SavedContact>> getContacts() async => _contacts;

  @override
  Future<SavedContact> getContactById(String contactId) async =>
    _contacts.firstWhere((c) => c.id == contactId);
}
```

### PracticeOperationRepository

```dart
class PracticeOperationRepository implements OperationRepository {
  final List<Operation> _operations = [];

  @override
  Future<Operation> createOperation({
    required OperationType type,
    required String recipientName,
    required double amount,
    required String description,
  }) async {
    final op = Operation(
      id: 'p-op-${_operations.length + 1}',
      type: type,
      recipientName: recipientName,
      amount: amount,
      date: DateTime.now(),
      status: OperationStatus.success,
      description: description,
    );
    _operations.add(op);
    return op;
  }

  @override
  Future<List<Operation>> getOperations() async =>
    _operations.reversed.toList();

  void reset() => _operations.clear();
}
```

**Contrato de aislamiento**:
- Ningún repositorio de práctica importa, referencia ni accede a los repositorios reales.
- Los IDs de las entidades de práctica usan prefijo `p-` para facilitar debugging.
- `reset()` restaura todos los datos al estado inicial.

## PracticeRiskEngine

Ubicación: `lib/features/practice_mode/data/services/practice_risk_engine.dart`

```dart
class PracticeRiskEngine implements RiskEngine {
  @override
  RiskAlert? evaluate({
    required OperationContext context,
    required List<Operation> history,
  }) {
    if (context.amount > 500) {
      return RiskAlert(
        triggeredRules: {RiskRule.unusualAmount},
        operation: context,
      );
    }
    return null;
  }
}
```

**Contrato**:
- Umbral fijo: S/ 500. Sin lógica de historial.
- Retorna `RiskAlert` con regla `unusualAmount` para montos > 500.
- Retorna `null` para todo lo demás (sin alerta).
- La `FraudAlertScreen` de 002 lo consume sin saber que es práctica.

## ProviderScope Override

Ubicación: En el builder del ShellRoute de práctica.

```dart
final practiceOverrides = [
  accountRepositoryProvider.overrideWith((_) => PracticeAccountRepository()),
  billRepositoryProvider.overrideWith((_) => PracticeBillRepository()),
  contactRepositoryProvider.overrideWith((_) => PracticeContactRepository()),
  operationRepositoryProvider.overrideWith((_) => PracticeOperationRepository()),
  riskEngineProvider.overrideWith((_) => PracticeRiskEngine()),
  biometricAuthProvider.overrideWith((_) => PracticeBiometricAuth()),
  confirmButtonTextProvider.overrideWithValue('Confirmar práctica'),
];
```

**Contrato**:
- Todos los overrides se aplican en un `ProviderScope` que envuelve las rutas de práctica.
- Las pantallas de 001 y 002 no necesitan cambios — reciben datos via los providers sobreescritos.
- Al salir del ProviderScope (navegar fuera de `/easy-mode/practice/`), los overrides se descartan.

## Contrato de integración con 001

Las pantallas de 001 deben cumplir una condición para que el override funcione:
- Los providers de repositorio deben ser overridables (no usar implementación concreta directamente).
- 001-R1 y 001-R6 ya documentan este patrón: "provider global por repositorio que se overridea en ProviderScope."

**No se modifica ninguna pantalla de 001.** Si una pantalla necesita mostrar texto distinto (ej: "Confirmar práctica" en vez de "Confirmar con huella"), se usa un provider de configuración que también se overridea.

## Contrato de integración con 002

- `riskEngineProvider` se overridea con `PracticeRiskEngine`.
- `FraudAlertScreen` se reutiliza sin cambios.
- Cuando la guía está activa, un widget condicional en la `FraudAlertScreen` (o encima de ella via el ShellRoute) muestra la nota educativa.

## Rutas de navegación

```
/easy-mode                              → EasyModeHomeScreen (botón "Practicar")
/easy-mode/practice                     → PracticeEntryScreen (anuncio + oferta guía)
/easy-mode/practice/home                → EasyModeHomeScreen (override repos)
/easy-mode/practice/balance             → BalanceScreen (override repos)
/easy-mode/practice/pay-bill            → PayBillScreen (override repos)
/easy-mode/practice/pay-bill/:id/confirm → PayBillConfirmScreen (override repos)
/easy-mode/practice/send-money          → SendMoneyScreen (override repos)
/easy-mode/practice/send-money/confirm  → SendMoneyConfirmScreen (override repos)
/easy-mode/practice/success             → OperationSuccessScreen (+ "Practicar otra vez")
```

## Invariantes

1. **Aislamiento absoluto**: Los repos de práctica y los repos reales son instancias completamente separadas. No comparten estado ni referencias.
2. **Cero cambios en 001/002**: Ninguna pantalla de 001 ni 002 se modifica para soportar práctica. Todo se logra via ProviderScope override.
3. **Sesión efímera**: PracticeSession no persiste. Cerrar la app = volver a modo real.
4. **Banner siempre visible**: PracticeBanner presente en 100% de las pantallas bajo `/easy-mode/practice/`.
5. **Guía no intrusiva**: Las instrucciones se superponen, no reemplazan el contenido de la pantalla.
6. **Anuncios TTS**: Entrada y salida de práctica siempre se anuncian.

# Repository Interfaces (Contracts): Modo Fácil

Estas interfaces abstractas definen el contrato entre la capa de dominio y la capa de datos. Las implementaciones mock (prototipo) y las futuras implementaciones con API real deben cumplir estos contratos sin cambios en la UI.

Ubicación: `lib/features/easy_mode/domain/repositories/`

## AccountRepository

```dart
abstract class AccountRepository {
  /// Obtiene la cuenta del usuario actual.
  Future<Account> getAccount();

  /// Actualiza el saldo disponible (usado internamente después de pagos/envíos).
  Future<Account> updateBalance(String accountId, double newBalance);
}
```

**Contrato**:
- `getAccount()` siempre retorna una cuenta válida (en el prototipo, la cuenta mock de Rosa).
- `updateBalance()` retorna la cuenta actualizada. Lanza excepción si `newBalance < 0`.

## BillRepository

```dart
abstract class BillRepository {
  /// Lista los recibos del usuario, opcionalmente filtrados por estado.
  Future<List<Bill>> getBills({BillStatus? status});

  /// Obtiene un recibo por ID.
  Future<Bill> getBillById(String billId);

  /// Marca un recibo como pagado.
  Future<Bill> payBill(String billId);
}
```

**Contrato**:
- `getBills(status: BillStatus.pending)` retorna solo recibos no pagados. Lista vacía si no hay.
- `payBill()` cambia el estado a `paid` y retorna el recibo actualizado. Lanza excepción si ya estaba pagado.

## ContactRepository

```dart
abstract class ContactRepository {
  /// Lista los contactos guardados del usuario.
  Future<List<SavedContact>> getContacts();

  /// Obtiene un contacto por ID.
  Future<SavedContact> getContactById(String contactId);
}
```

**Contrato**:
- `getContacts()` retorna la lista completa. Lista vacía si no hay contactos.
- Solo lectura en esta feature — agregar contactos está fuera del alcance.

## OperationRepository

```dart
abstract class OperationRepository {
  /// Registra una nueva operación (pago o transferencia).
  Future<Operation> createOperation({
    required OperationType type,
    required String recipientName,
    required double amount,
    required String description,
  });

  /// Lista las operaciones completadas, ordenadas por fecha descendente.
  Future<List<Operation>> getOperations();
}
```

**Contrato**:
- `createOperation()` genera `id` y `date` automáticamente. En el mock, siempre retorna `status: success`.
- La operación se crea DESPUÉS de la confirmación del usuario y la actualización del saldo.

## Flujo de una operación monetaria

```
1. Usuario confirma en ConfirmationScreen
2. Provider llama accountRepository.updateBalance(newBalance)
3. Provider llama billRepository.payBill(billId) o solo registra
4. Provider llama operationRepository.createOperation(...)
5. Si todo OK → navegar a OperationSuccessScreen
6. Si error → mostrar ErrorMessage, saldo no cambia
```

Los pasos 2-4 son atómicos en el mock (in-memory). En una API real, esto sería una transacción del backend.

## Swap a API real

Para conectar con un banco real, se implementan las mismas interfaces:

```dart
class ApiAccountRepository implements AccountRepository { ... }
class ApiBillRepository implements BillRepository { ... }
```

Y se cambia el override en el `ProviderScope` de `main.dart`. Cero cambios en `presentation/` o `domain/`.

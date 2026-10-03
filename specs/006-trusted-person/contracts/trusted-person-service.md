# Trusted Person Service Contract (006-trusted-person)

Este es el servicio público que 002-fraud-shield y 003-contextual-human-help consumen. Define la interfaz para consultar y gestionar la persona de confianza y sus permisos.

Ubicación: `lib/features/trusted_person/domain/repositories/`

## TrustedPersonRepository

```dart
abstract class TrustedPersonRepository {
  /// Obtiene la persona de confianza registrada, o null si no hay.
  Future<TrustedPerson?> getTrustedPerson();

  /// Registra una nueva persona de confianza.
  /// Lanza si ya existe una (debe cambiar/quitar primero).
  Future<TrustedPerson> register({
    required String name,
    required String phone,
    required String relationship,
    required Set<TrustedPermission> initialPermissions,
  });

  /// Actualiza los permisos de la persona de confianza.
  /// Crea ConsentRecords para cada cambio.
  Future<TrustedPerson> updatePermissions(Set<TrustedPermission> permissions);

  /// Quita la persona de confianza. Revoca todos los permisos.
  /// Crea ConsentRecords de revocación.
  Future<void> remove();

  /// Verifica si un permiso específico está activo.
  /// Shortcut: equivale a getTrustedPerson() → hasPermission().
  /// Retorna false si no hay persona registrada.
  Future<bool> hasPermission(TrustedPermission permission);

  /// Stream de cambios en la persona de confianza.
  /// 002/003 usan esto vía el provider para reactividad.
  Stream<TrustedPerson?> watchTrustedPerson();
}
```

## Contrato de uso para 002-fraud-shield

Cuando el escudo antifraude detecta una operación inusual y construye la pantalla de alerta:

```dart
// En el provider o screen de 002:
final trustedPerson = ref.watch(trustedPersonProvider).valueOrNull;

final showTrustedPersonOption =
    trustedPerson != null &&
    trustedPerson.hasPermission(TrustedPermission.securityAlerts);

// Si showTrustedPersonOption == true:
//   Mostrar botón "Consultar a [trustedPerson.name]"
//   Al tocar: simular notificación al familiar con contexto de la alerta
// Si false:
//   Solo mostrar "Cancelar" y "Continuar de todos modos"
```

**Cuando el usuario cancela la operación después de enviar aviso al familiar**:
El aviso simulado incluye una nota: "Rosa decidió cancelar esta operación."

## Contrato de uso para 003-contextual-human-help

Cuando el usuario toca "Pedir ayuda" y se construye la lista de opciones de contacto:

```dart
// En el provider o screen de 003:
final trustedPerson = ref.watch(trustedPersonProvider).valueOrNull;

final showTrustedPersonAsContact =
    trustedPerson != null &&
    trustedPerson.hasPermission(TrustedPermission.helpRequests);

// Si showTrustedPersonAsContact == true:
//   Mostrar opción "Llamar a [trustedPerson.name]" / "Escribir a [trustedPerson.name]"
//   Al contactar: enviar contexto (pantalla, paso, operación) al familiar (simulado)
// Si false:
//   Solo mostrar "Llamar al banco" / "Escribir al banco" / "Videollamada con intérprete"
```

## ConfigSuggestionRepository

```dart
abstract class ConfigSuggestionRepository {
  /// Lista sugerencias pendientes.
  Future<List<ConfigSuggestion>> getPendingSuggestions();

  /// Acepta una sugerencia. Retorna la sugerencia actualizada.
  Future<ConfigSuggestion> accept(String suggestionId);

  /// Rechaza una sugerencia. Retorna la sugerencia actualizada.
  /// No notifica al familiar (spec: "no se entera del rechazo").
  Future<ConfigSuggestion> reject(String suggestionId);

  /// Crea una sugerencia simulada (para demo/debug).
  Future<ConfigSuggestion> createSimulated({
    required ConfigSuggestionType type,
    required String description,
    String? suggestedValue,
  });
}
```

## Provider público

Ubicación: `lib/features/trusted_person/presentation/providers/trusted_person_provider.dart`

```dart
@riverpod
Stream<TrustedPerson?> trustedPerson(Ref ref) {
  final repo = ref.watch(trustedPersonRepositoryProvider);
  return repo.watchTrustedPerson();
}
```

Este provider es el punto de integración. 002 y 003 lo importan y lo watch'an. No necesitan conocer la implementación (secure storage, mock, API real).

## Invariantes

1. **Nunca más de una persona de confianza** por usuario.
2. **Permisos desactivados = feature invisible**: si `securityAlerts` off → 002 no muestra opción. Si `helpRequests` off → 003 no muestra opción.
3. **Quitar persona de confianza = revocar todo**: 002 y 003 dejan de mostrar opciones del familiar inmediatamente.
4. **Datos en secure storage**: el teléfono y nombre nunca se almacenan en SharedPreferences, logs, ni variables de entorno.
5. **Sugerencias nunca auto-apply**: siempre `pending` hasta decisión explícita del usuario.

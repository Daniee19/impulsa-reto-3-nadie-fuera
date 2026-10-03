# Accessibility Utilities Contract (005-screen-reader-audit)

Utilities compartidas en `lib/core/a11y/` que las pantallas de todas las features usan para cumplir los estándares de accesibilidad.

## AmountToWords

Ubicación: `lib/core/a11y/amount_to_words.dart`

Dart puro. Sin dependencias de Flutter.

```dart
class AmountToWords {
  /// Convierte un monto en soles a texto en español.
  /// Siempre incluye la moneda.
  ///
  /// 120.50 → "ciento veinte soles con cincuenta céntimos"
  /// 2350.00 → "dos mil trescientos cincuenta soles"
  /// 0.00 → "cero soles"
  /// 1.00 → "un sol"
  static String convert(double amount);
}
```

**Contrato**:
- `convert()` SIEMPRE retorna un String no vacío en español.
- Monto negativo → throw `ArgumentError` (los montos siempre son positivos en esta app).
- Rango soportado: 0 a 999,999.99.
- Parte decimal se redondea a 2 decimales.
- "soles" plural, "sol" singular. "céntimos" plural, "céntimo" singular.
- "con" separa soles de céntimos. Si no hay céntimos, no aparece "con".

## screenAnnounce

Ubicación: `lib/core/a11y/screen_announce.dart`

```dart
/// Anuncia un mensaje al lector de pantalla sin que el usuario navegue.
/// Wrapper de SemanticsService.announce para uso consistente.
Future<void> screenAnnounce(String message) {
  return SemanticsService.announce(message, TextDirection.ltr);
}
```

**Contrato**:
- Llamar en `initState()`, `didChangeDependencies()`, o en callbacks de provider cuando cambia el estado.
- El mensaje debe estar en español, ≤15 palabras, sin jerga.
- Para montos, usar `AmountToWords.convert()` en el mensaje.
- No llamar si el widget no está montado (verificar `mounted` antes en StatefulWidget).

## Patrón de uso en pantallas

### Anuncio al cargar pantalla

```dart
class BalanceScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends ConsumerState<BalanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final balance = ref.read(accountProvider).valueOrNull?.availableBalance;
      if (balance != null) {
        screenAnnounce(
          'Tu saldo es ${AmountToWords.convert(balance)}',
        );
      }
    });
  }
}
```

### Monto accesible en widget

```dart
Semantics(
  label: AmountToWords.convert(amount),
  excludeSemantics: true, // excluir el Text hijo que dice "S/ 120.00"
  child: Text(
    'S/ ${amount.toStringAsFixed(2)}',
    style: theme.textTheme.headlineLarge,
  ),
)
```

### Imagen decorativa

```dart
ExcludeSemantics(
  child: Image.asset('assets/illustration.png'),
)
```

### Icono de acción

```dart
Semantics(
  button: true,
  label: l10n.payBillAction, // "Pagar recibo", no "icono de billete"
  child: IconButton(
    icon: const Icon(Icons.receipt_long),
    onPressed: () => /* ... */,
  ),
)
```

### Agrupación de información relacionada

```dart
MergeSemantics(
  child: Row(
    children: [
      Text(bill.serviceName),
      const Spacer(),
      Semantics(
        label: AmountToWords.convert(bill.amount),
        excludeSemantics: true,
        child: Text('S/ ${bill.amount.toStringAsFixed(2)}'),
      ),
    ],
  ),
)
// TalkBack lee: "Luz ciento veinte soles" como una unidad
```

### Orden de lectura con sortKey

```dart
// Solo cuando el orden del tree no coincide con el orden lógico:
Semantics(
  sortKey: const OrdinalSortKey(99), // FAB se lee al final
  child: HelpFab(),
)
```

## Contrato de integración con 001-easy-mode

Pantallas de 001 que requieren modificaciones:

| Pantalla | Modificación |
|----------|-------------|
| `EasyModeHomeScreen` | `screenAnnounce` al cargar. sortKey si FAB presente |
| `BalanceScreen` | Monto con AmountToWords. Announce del saldo |
| `PayBillListScreen` | MergeSemantics por cada recibo (nombre + monto) |
| `PayBillConfirmScreen` | Resumen con AmountToWords. Announce antes de confirmar |
| `SendMoneyScreen` | Labels en campos de contacto y monto |
| `SendMoneyConfirmScreen` | Resumen con AmountToWords |
| `SuccessScreen` | Announce del resultado. Monto en palabras |

## Contrato de integración con 002-fraud-shield

| Pantalla | Modificación |
|----------|-------------|
| `FraudAlertScreen` | Announce automático de la alerta al aparecer. Monto con AmountToWords. Las 3 opciones con labels descriptivos únicos |

## Contrato de integración con 003-contextual-human-help

| Pantalla | Modificación |
|----------|-------------|
| `HelpFab` | sortKey alto para que se lea al final. Label "Pedir ayuda" |
| `HelpContactPickerScreen` | Labels por cada opción de contacto |
| `HelpChannelPickerScreen` | Labels por cada canal |
| `HelpConnectingScreen` | Announce de "Te estamos conectando..." |
| `HelpFallbackScreen` | Announce de "No pudimos comunicarte..." |

## Contrato de integración con 004-voice-text-assistant

| Pantalla | Modificación |
|----------|-------------|
| `VoiceAssistantScreen` | Label del botón de micrófono. Announce de respuestas |
| `MicrophoneConsentScreen` | Labels claros en botones de aceptar/rechazar |
| `OperationSummaryScreen` | Monto con AmountToWords. Announce del resumen |

## Invariantes

1. **Ningún elemento mudo**: Todo interactivo e informativo tiene Semantics label en español.
2. **Montos siempre en palabras**: Nunca "S/ 120" en Semantics — siempre AmountToWords.convert().
3. **Announce en toda transición**: Todo cambio de pantalla/estado importante anuncia via SemanticsService.
4. **Decorativo excluido**: Imágenes sin información van dentro de ExcludeSemantics.
5. **Etiquetas únicas por pantalla**: No hay dos interactivos adyacentes con la misma label.
6. **Tests por pantalla**: Cada pantalla tiene al menos un test con las 3 guidelines.

# Research: Auditoría de Accesibilidad para Lector de Pantalla (005-screen-reader-audit)

## R1: Conversión de montos a palabras en español

**Decision**: Implementar un conversor `AmountToWords` en Dart puro (`lib/core/a11y/amount_to_words.dart`) que traduce valores numéricos a texto en español con moneda. No usar paquete externo.

**Rationale**: FR-004/FR-005 exigen que los montos se lean en palabras completas ("ciento veinte soles con cincuenta céntimos"). No hay paquete Flutter estable en español con licencia aprobada que haga exactamente esto. La lógica es ~100 líneas de Dart puro, completamente testeable, sin dependencias.

**Implementación**:
```dart
class AmountToWords {
  /// Convierte un monto en soles a texto en español.
  /// 120.50 → "ciento veinte soles con cincuenta céntimos"
  /// 2350.00 → "dos mil trescientos cincuenta soles"
  /// 0.50 → "cincuenta céntimos"
  /// 0.00 → "cero soles"
  static String convert(double amount);
}
```

**Reglas**:
- Parte entera: número en palabras + "soles" (plural) o "sol" (si es 1).
- Parte decimal (céntimos): si > 0, " con " + número en palabras + "céntimos" o "céntimo".
- Cero: "cero soles".
- Rango esperado: 0 a 999,999 soles (suficiente para el prototipo).

**Uso en Semantics**:
```dart
Semantics(
  label: AmountToWords.convert(amount), // "ciento veinte soles"
  child: Text('S/ ${amount.toStringAsFixed(2)}'), // Visual: "S/ 120.00"
)
```

El texto visual muestra "S/ 120.00" pero TalkBack lee "ciento veinte soles".

**Alternatives considered**:
- `number_to_words` package: solo inglés.
- `intl` NumberFormat: formatea números pero no los convierte a palabras.
- Dejar que TalkBack lea "S/ 120": lee "ese barra ciento veinte" — confuso.

## R2: Anuncios de cambio de pantalla con SemanticsService

**Decision**: Usar `SemanticsService.announce()` para anunciar automáticamente cambios de pantalla y estado. Crear un helper `screenAnnounce()` en `lib/core/a11y/screen_announce.dart`.

**Rationale**: FR-006 exige que cambios importantes se anuncien automáticamente. La constitución exige `SemanticsService.announce` para cambios de estado. En Flutter, `SemanticsService.announce` envía un mensaje al lector de pantalla sin que el usuario tenga que navegar al elemento.

**Implementación**:
```dart
Future<void> screenAnnounce(String message) {
  return SemanticsService.announce(message, TextDirection.ltr);
}
```

**Puntos de anuncio** (inventario de todas las transiciones):
| Pantalla / Evento | Mensaje de anuncio |
|-------------------|-------------------|
| Pantalla principal carga | "Pantalla principal. Tienes 4 opciones" |
| Resultado de saldo | "Tu saldo es [monto en palabras]" |
| Pago realizado | "Pago realizado. Pagaste [monto] al recibo de [servicio]" |
| Dinero enviado | "Dinero enviado. Enviaste [monto] a [nombre]" |
| Alerta de fraude aparece | "Alerta de seguridad. [explicación del riesgo]" |
| Conexión de ayuda | "Te estamos conectando con [nombre]" |
| Respuesta del asistente | "[texto de respuesta del asistente]" |
| Error de operación | "[mensaje de error]" |

**Dónde colocar los announces**: En los métodos `initState()` o `didChangeDependencies()` del widget de la pantalla, o en el callback del provider que maneja la transición de estado.

**Alternatives considered**:
- `FocusSemantics` automático: mueve el foco al primer elemento, pero no anuncia un mensaje personalizado.
- `live region` (AccessibleNavigation): Flutter no tiene equivalente directo a ARIA live regions. `SemanticsService.announce` es la forma canónica.

## R3: Orden de lectura con Semantics.sortKey

**Decision**: Usar `Semantics.sortKey` (OrdinalSortKey) donde el orden natural del widget tree no coincida con el orden lógico deseado (título → información → acciones). Solo intervenir donde sea necesario — la mayoría de pantallas ya tienen orden correcto por la estructura del widget tree.

**Rationale**: FR-003 exige orden lógico: título primero, información contextual, y acciones al final. En Flutter, TalkBack lee los `Semantics` nodes en el orden que aparecen en el tree, de arriba hacia abajo. Si un botón está encima de la información (por ejemplo, un FAB posicionado con Stack), necesita `sortKey` para que se lea al final.

**Implementación**:
```dart
// Solo donde el orden natural no es correcto:
Semantics(
  sortKey: const OrdinalSortKey(0), // título primero
  child: screenTitle,
)
Semantics(
  sortKey: const OrdinalSortKey(1), // información después
  child: balanceDisplay,
)
Semantics(
  sortKey: const OrdinalSortKey(2), // acciones al final
  child: actionButtons,
)
```

**Caso especial: HelpFab**: El FAB de ayuda (003) está en un overlay/stack. Sin `sortKey`, TalkBack puede leerlo antes que el contenido principal. Se le asigna un `sortKey` alto (ej: OrdinalSortKey(99)) para que se lea al final.

**Alternatives considered**:
- Reestructurar el widget tree: si el tree ya está bien, no tocar. `sortKey` es menos invasivo.
- `MergeSemantics`: útil para agrupar, no para reordenar.

## R4: Agrupación y exclusión de Semantics

**Decision**: Usar `MergeSemantics` para agrupar información relacionada (ej: nombre de recibo + monto se leen como una unidad). Usar `ExcludeSemantics` para imágenes decorativas que no aportan información.

**Rationale**: FR-008 exige que imágenes decorativas sean ignoradas por TalkBack. Edge case del spec: "Se agrupa información relacionada para que se lea como un bloque lógico." MergeSemantics produce una mejor experiencia: "Recibo de luz, ochenta y cinco soles con cincuenta céntimos" en vez de "Recibo de luz" (swipe) "ochenta y cinco soles con cincuenta céntimos" (swipe).

**Implementación**:
```dart
// Agrupar recibo como una unidad:
MergeSemantics(
  child: Column(
    children: [
      Text(bill.serviceName),
      Text('S/ ${bill.amount}'),
    ],
  ),
)

// Excluir imagen decorativa:
ExcludeSemantics(
  child: Image.asset('assets/decorative_illustration.png'),
)

// Imagen informativa con descripción:
Semantics(
  label: 'Estado: pago exitoso',
  child: Icon(Icons.check_circle, color: Colors.green),
)
```

**Alternatives considered**:
- Dejar cada campo como Semantics separado: más swipes, peor experiencia.

## R5: Tests automáticos de accesibilidad

**Decision**: Un widget test por feature (001-004) que verifica las 3 guidelines de flutter_test en todas las pantallas de esa feature: `androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`.

**Rationale**: FR-015 exige tests automáticos de etiquetas, áreas táctiles y contraste. La constitución exige estos mismos 3 tests por pantalla. Agrupar por feature (no por pantalla individual) reduce la cantidad de archivos de test.

**Estructura del test**:
```dart
void main() {
  group('Easy Mode A11y', () {
    testWidgets('home screen meets a11y guidelines', (tester) async {
      await tester.pumpWidget(/* EasyModeHomeScreen wrapped */);
      expect(tester, meetsGuideline(androidTapTargetGuideline));
      expect(tester, meetsGuideline(labeledTapTargetGuideline));
      expect(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('balance screen meets a11y guidelines', (tester) async {
      // ...same pattern
    });

    // ... una por pantalla
  });
}
```

**Inventario de pantallas a probar**:
| Feature | Pantallas |
|---------|-----------|
| 001 | Home, Balance, PayBillList, PayBillConfirm, SendMoney, SendMoneyConfirm, Success, Settings |
| 002 | FraudAlertScreen |
| 003 | HelpContactPicker, HelpChannelPicker, HelpConnecting, HelpFallback |
| 004 | VoiceAssistant, MicrophoneConsent, OperationSummary |

**Test adicional**: verificar que no hay overflow a `textScaler` 2.0 (constitución).

```dart
testWidgets('no overflow at textScaler 2.0', (tester) async {
  tester.view.platformDispatcher.textScaleFactorTestValue = 2.0;
  await tester.pumpWidget(/* screen */);
  expect(tester.takeException(), isNull);
});
```

**Alternatives considered**:
- Un test por pantalla en archivos separados: demasiados archivos para un audit transversal.
- Solo prueba manual: no cumple FR-015 que exige tests automáticos.

## R6: Guion de prueba manual con TalkBack

**Decision**: Un documento markdown (`docs/talkback_test_checklist.md`) con pasos guiados para probar cada flujo con TalkBack y ojos cerrados. Incluye: qué pantalla, qué acción, qué esperar oír, y campo para anotar problemas.

**Rationale**: FR-013/FR-014 exigen un guion de prueba manual ejecutable. La constitución exige "prueba manual obligatoria: usar la app 10 minutos con ojos cerrados y TalkBack encendido". Las pruebas automáticas no pueden verificar calidad de etiquetas ni orden perceptual — solo la prueba manual con un humano puede hacerlo.

**Estructura del guion**:
```markdown
## Flujo: Ver saldo
- [ ] Abrir app → TalkBack anuncia "Pantalla principal"
- [ ] Swipe → lee "Ver mi saldo" (no "botón 1")
- [ ] Doble toque → anuncia "Tu saldo es dos mil cuatrocientos cincuenta soles"
- [ ] Problemas encontrados: ___
```

**Flujos a cubrir** (alineados con SC-006):
1. Ver saldo
2. Pagar recibo (seleccionar → confirmar → éxito)
3. Enviar dinero (seleccionar contacto → monto → confirmar → éxito)
4. Pedir ayuda (FAB → elegir contacto → elegir canal)
5. Recibir alerta de fraude
6. Usar asistente de voz
7. Conectar con ayuda humana

**Tiempo objetivo**: ≤10 minutos para completar todos los flujos (SC-009, constitución).

**Alternatives considered**:
- Herramienta automatizada de audit (accessibility_scanner): no existe como paquete Flutter estable. flutter_test guidelines ya cubren lo automatizable.
- Solo tests automáticos sin manual: los tests no capturan "la etiqueta dice CTA principal en vez de Pagar recibo" (edge case del spec).

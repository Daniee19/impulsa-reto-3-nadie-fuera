# Research: Contratos Explicados en Audio (010-audio-contracts)

## R1: Reutilización del servicio TTS de 004

**Decision**: Reutilizar `TtsService` de `lib/features/voice_assistant/presentation/services/tts_service.dart` (de 004) que wrappea `flutter_tts`. No se crea un nuevo servicio TTS — se consume el existente via su provider.

**Implementación**:
```dart
// En contract_review_provider.dart:
final tts = ref.read(ttsServiceProvider);
await tts.speak(section.text, locale: 'es-ES');
```

El servicio de 004 ya expone: `speak()`, `stop()`, `pause()` (si soportado por plataforma), `setRate()`, `setSpeechRate()`. Se le agrega soporte para velocidad variable si no lo tiene (3 niveles: 1.0, 0.75, 0.5).

**Rationale**: Sin dependencias nuevas. `flutter_tts` ya está en `pubspec.yaml` por 004. El servicio existente maneja el ciclo de vida del engine TTS.

**Alternatives considered**:
- Nuevo servicio TTS específico para contratos: duplicaría lógica.
- Instancia separada de `FlutterTts`: conflictos de engine singleton en Android.

## R2: Contratos de ejemplo como contenido estático

**Decision**: Definir los 2 contratos de ejemplo como JSON en `assets/contracts/` con estructura tipada. Los textos del resumen van en ARB (localizados). El JSON referencia las keys ARB para cada sección.

**Implementación**:
```json
// assets/contracts/savings_account.json
{
  "id": "savings_account",
  "titleKey": "contract_savings_account_title",
  "sections": [
    {
      "type": "what_you_accept",
      "titleKey": "contract_section_what_you_accept",
      "contentKey": "contract_savings_what_you_accept"
    },
    {
      "type": "cost",
      "titleKey": "contract_section_cost",
      "contentKey": "contract_savings_cost"
    },
    {
      "type": "risks",
      "titleKey": "contract_section_risks",
      "contentKey": "contract_savings_risks"
    },
    {
      "type": "how_to_cancel",
      "titleKey": "contract_section_how_to_cancel",
      "contentKey": "contract_savings_how_to_cancel"
    }
  ],
  "fullContractParagraphs": 8
}
```

Los textos en `lib/l10n/app_es.arb`:
```json
{
  "contract_savings_account_title": "Cuenta de ahorro",
  "contract_savings_what_you_accept": "Abres una cuenta de ahorro donde puedes guardar tu dinero. El banco lo cuida por ti.",
  "contract_savings_cost": "No tiene costo mensual. Si sacas dinero de otro banco, cobran un sol por cada vez.",
  "contract_savings_risks": "Tu dinero está seguro. Si el banco cierra, el gobierno te devuelve hasta cien mil soles.",
  "contract_savings_how_to_cancel": "Puedes cerrar tu cuenta cuando quieras. Ve a una oficina o llama por teléfono. No cobran por cerrarla."
}
```

**Rationale**: JSON para la estructura (fijo, 4 secciones), ARB para el texto (localizable). Los textos de resumen usan ≤ 15 palabras por oración, lenguaje simple.

**Alternatives considered**:
- Todo en ARB: pierde la estructura tipada de secciones.
- Markdown: necesitaría parser, YAGNI.
- Base de datos: son datos estáticos, no cambian en runtime.

## R3: Estructura de 4 secciones obligatorias

**Decision**: Enum `ContractSectionType` con 4 valores fijos que mapean a las 4 secciones del spec: "Qué aceptas", "Cuánto cuesta", "Qué puede salir mal", "Cómo cancelar".

**Implementación**:
```dart
enum ContractSectionType {
  whatYouAccept,
  cost,
  risks,
  howToCancel;
}
```

El orden es fijo (enum order). Cada sección se lee secuencialmente en TTS. El spec exige las 4 en cada contrato.

**Rationale**: Enum fijo garantiza que no se omita ninguna sección. El spec dice "4 secciones obligatorias" — no hay opcionales ni extensibles.

**Alternatives considered**:
- Secciones dinámicas (lista libre): contradice el spec que exige 4 fijas.
- Map<String, String>: pierde type safety.

## R4: Controles de reproducción TTS

**Decision**: Widget `TtsPlaybackControls` con 3 botones: Pausar/Reanudar, Repetir sección actual, Cambiar velocidad (ciclo 100% → 75% → 50% → 100%).

**Implementación**:
```dart
class TtsPlaybackControls extends ConsumerWidget {
  // 3 botones, todos 48×48 dp mínimo con Semantics labels en español.
  // Pausar: Icons.pause / Icons.play_arrow, label "Pausar" / "Continuar"
  // Repetir: Icons.replay, label "Repetir esta sección"
  // Velocidad: texto "100%" / "75%" / "50%", label "Velocidad: {speed}%"
}
```

**Estado de velocidad**: `enum PlaybackSpeed { normal, slow, slower }` con valores 1.0, 0.75, 0.5. Almacenado en el provider de revisión. Se aplica via `tts.setSpeechRate(speed.rate)`.

**Rationale**: Ciclo de velocidad simple sin slider — reduce carga cognitiva (principio VI). 3 velocidades son suficientes para el target: velocidad normal, más lento, mucho más lento.

**Alternatives considered**:
- Slider de velocidad: demasiado fino para el target de usuarios.
- Solo 2 velocidades: el spec pide 3 niveles (100%, 75%, 50%).

## R5: Gating del botón "Aceptar"

**Decision**: El botón "Aceptar" se habilita cuando `reviewCompleted == true`. La revisión se completa por una de dos vías:
1. **Audio**: TTS terminó de leer las 4 secciones (callback `onComplete` de `flutter_tts`).
2. **Visual**: El usuario hizo scroll hasta el final del resumen (un `ScrollController` detecta `position.pixels >= position.maxScrollExtent - 50`).

**Implementación**:
```dart
@freezed
class ReviewSession with _$ReviewSession {
  const factory ReviewSession({
    required String contractId,
    @Default({}) Set<ContractSectionType> sectionsHeard,
    @Default(false) bool scrolledToEnd,
    @Default(PlaybackSpeed.normal) PlaybackSpeed speed,
    @Default(TtsState.idle) TtsState ttsState,
  }) = _ReviewSession;

  bool get reviewCompleted =>
      sectionsHeard.length == ContractSectionType.values.length ||
      scrolledToEnd;
}
```

**Rationale**: Doble vía (audio o scroll) porque el spec dice "ver u oír el resumen". Un usuario que lee visualmente las 4 secciones no debe ser forzado a esperar el audio. La detección de scroll es simple y no intrusiva.

**Alternatives considered**:
- Solo audio: excluye usuarios que prefieren leer.
- Timer (30 segundos visibles): artifical, no mide comprensión real.
- Checkbox "He leído": engañable, no accesible.

## R6: Lectura automática al abrir

**Decision**: Al abrir `ContractSummaryScreen`, el TTS comienza a leer la primera sección automáticamente. Se anuncia con `SemanticsService.announce("Leyendo el resumen del contrato")` primero.

**Flujo**:
1. Pantalla se abre → announce → pausa de 500ms → TTS empieza sección 1.
2. Al terminar sección 1 → pausa 800ms → TTS empieza sección 2.
3. Repite hasta sección 4.
4. Al terminar sección 4 → `reviewCompleted = true` → TTS anuncia "Ya puedes aceptar el contrato."

**Highlight visual**: La sección actualmente siendo leída se resalta con un borde lateral de color `primary` (#1A3C6E). Las secciones ya leídas muestran un check ✓ (o icon `Icons.check_circle`).

**Rationale**: Lectura automática es el camino principal — la persona abre el contrato y escucha. Pausas entre secciones dan tiempo para procesar. El highlight visual sincroniza audio con visual (WCAG 1.3.3 sensory characteristics).

**Alternatives considered**:
- Lectura manual (tocar cada sección): más fricción, contradice el spec ("se lee automáticamente").
- Sin highlight: pierde sincronización visual-audio.

## R7: Pantalla de contrato completo

**Decision**: `FullContractScreen` muestra el texto legal completo (simulado) dividido en párrafos. Cada párrafo tiene un botón "Leer" (icon speaker) que lee ese párrafo con TTS. No hay lectura automática del contrato completo.

**Implementación**:
```dart
// Cada párrafo como Card con botón "Leer este párrafo":
ListView.builder(
  itemCount: paragraphs.length,
  itemBuilder: (_, i) => _ParagraphCard(
    text: paragraphs[i],
    onRead: () => tts.speak(paragraphs[i]),
    isReading: currentParagraph == i,
  ),
)
```

**Navegación**: Desde `ContractSummaryScreen`, botón "Ver contrato completo" navega a `FullContractScreen`. No es obligatorio para habilitar "Aceptar" — solo el resumen.

**Rationale**: El contrato completo es opcional y puede ser largo. Lectura por párrafos da control al usuario. No requiere leer todo para aceptar (solo el resumen).

**Alternatives considered**:
- Lectura automática del completo: demasiado largo, frustrante.
- Sin lectura en contrato completo: pierde valor de accesibilidad.

## R8: Integración con asistente (004) para preguntas

**Decision**: Botón "¿Tienes una pregunta?" en la pantalla de resumen que abre el asistente de voz (004) con contexto del contrato actual. Se pasa el `contractId` como contexto para que el asistente pueda responder preguntas sobre el contrato.

**Implementación**:
```dart
// Botón en ContractSummaryScreen:
AccessibleButton(
  label: '¿Tienes una pregunta?',
  icon: Icons.help_outline,
  onPressed: () {
    // Pausa TTS si está leyendo
    ref.read(contractReviewProvider.notifier).pauseTts();
    // Navega al asistente con contexto
    context.push('/assistant', extra: AssistantContext(
      source: 'contract',
      contractId: contractId,
    ));
  },
)
```

**Rationale**: Reutiliza 004 sin modificar su lógica. El contexto del contrato permite al asistente entender qué se está revisando. TTS se pausa al abrir el asistente para evitar conflicto de audio.

**Alternatives considered**:
- FAQ estático: no responde preguntas específicas.
- Chat en la misma pantalla: complejidad de layout, YAGNI para prototipo.

## R9: Detección de volumen bajo

**Decision**: Antes de iniciar TTS, verificar el volumen del sistema. Si está por debajo de un umbral (30%), mostrar un aviso visual: "El volumen está bajo. ¿Quieres subirlo?" con botón para abrir configuración de sonido del dispositivo.

**Implementación**:
```dart
// Usar volume_controller o simplemente el check de flutter_tts:
// flutter_tts no ofrece check de volumen directamente.
// Opción simple: usar platform channel o package volume_controller.
// Para prototipo: banner informativo estático "Sube el volumen para escuchar."
```

**Decision simplificada para prototipo**: No se agrega dependencia nueva. Se muestra un banner estático al inicio: "Asegúrate de que el volumen esté alto para escuchar el resumen." Esto cumple el spec sin agregar `volume_controller` (que requeriría aprobación por constitución).

**Rationale**: Agregar un package solo para leer volumen es overkill para el prototipo. El banner informativo cumple la intención del spec.

**Alternatives considered**:
- `volume_controller` package: dependencia nueva no en whitelist.
- Platform channel custom: esfuerzo excesivo para prototipo.
- Ignorar: el spec lo menciona explícitamente.

## R10: Rutas de navegación

**Decision**: Sub-rutas bajo `/contracts/`:

```
/contracts/:contractId/summary    → ContractSummaryScreen (resumen + TTS)
/contracts/:contractId/full       → FullContractScreen (completo + lectura por párrafo)
```

Se llega desde cualquier flujo que presente un contrato (ej: apertura de cuenta, solicitud de préstamo). Para el prototipo, un entry point de ejemplo en la pantalla principal o configuración.

**Rationale**: Rutas parametrizadas por `contractId` para soportar múltiples contratos. Separación summary/full como sub-rutas permite navegación con back button.

**Alternatives considered**:
- Una sola ruta con tabs: más complejo, YAGNI.
- Modal/bottom sheet para contrato completo: demasiado limitado para texto largo.

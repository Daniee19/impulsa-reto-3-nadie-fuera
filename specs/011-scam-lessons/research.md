# Research: Microlecciones contra Estafas (011-scam-lessons)

## R1: Reutilización del servicio TTS de 004

**Decision**: Reutilizar `TtsService` y `ttsServiceProvider` de `lib/features/voice_assistant/` para leer el contenido de las lecciones en voz alta. No se crea servicio TTS nuevo.

**Implementación**:
```dart
final tts = ref.read(ttsServiceProvider);
await tts.speak(lesson.content, locale: 'es-ES');
```

El spec menciona "audio pregrabado" pero para el prototipo se usa TTS en tiempo real (`flutter_tts`), que ya está integrado por 004. El resultado es funcional y evita gestionar archivos de audio.

**Rationale**: Sin dependencias nuevas. `flutter_tts` ya en `pubspec.yaml`. El servicio de 004 maneja el lifecycle del engine.

**Alternatives considered**:
- Audio pregrabado (MP3 en assets): requiere grabar, almacenar y sincronizar archivos. Overkill para prototipo.
- Nuevo servicio TTS: duplicaría lógica de 004.

## R2: Contenido de lecciones como datos estáticos

**Decision**: Las lecciones se definen como constantes en `MockLessonRepository`. Los textos visibles van en ARB (localizables). La estructura (pregunta, opciones, respuesta correcta, retroalimentación) se hardcodea en el repositorio mock.

**Implementación**:
```dart
class MockLessonRepository implements LessonRepository {
  final AppLocalizations _l10n;

  @override
  Future<List<Lesson>> getAllLessons() async {
    return [
      Lesson(
        id: 'fake_yape',
        titleKey: _l10n.lessonFakeYapeTitle,
        content: _l10n.lessonFakeYapeContent,
        relatedRiskRules: {RiskRule.newRecipient},
        question: PracticeQuestion(
          prompt: _l10n.lessonFakeYapeQuestionPrompt,
          options: [
            AnswerOption(text: _l10n.lessonFakeYapeOptionA, isCorrect: false,
                feedback: _l10n.lessonFakeYapeFeedbackA),
            AnswerOption(text: _l10n.lessonFakeYapeOptionB, isCorrect: true,
                feedback: _l10n.lessonFakeYapeFeedbackB),
            AnswerOption(text: _l10n.lessonFakeYapeOptionC, isCorrect: false,
                feedback: _l10n.lessonFakeYapeFeedbackC),
          ],
        ),
      ),
      // ... más lecciones
    ];
  }
}
```

**Rationale**: Para el hackathon, 3-5 lecciones fijas no justifican un sistema de carga dinámico. Los textos en ARB cumplen constitución (VII). La estructura en Dart da type safety completo.

**Alternatives considered**:
- JSON en assets: pierde type safety, requiere deserialización, YAGNI para 5 lecciones.
- Base de datos: overkill para contenido estático inmutable.
- Markdown: necesitaría parser.

## R3: Mapeo alerta → lección relevante

**Decision**: Mapa estático `Map<RiskRule, Set<String>>` que relaciona cada `RiskRule` de 002 con IDs de lecciones relevantes. Definido como constante en domain.

**Implementación**:
```dart
const alertToLessonMap = <RiskRule, List<String>>{
  RiskRule.newRecipient: ['fake_yape', 'fake_relative'],
  RiskRule.unusualAmount: ['fake_yape', 'bank_call_scam'],
  RiskRule.highFrequency: ['fake_prize'],
  RiskRule.unusualTime: ['bank_call_scam'],
};
```

Cuando la alerta tiene múltiples `triggeredRules`, se toma la unión de lecciones y se filtra por no completadas. Se sugiere la primera no vista.

**Rationale**: El spec dice "la relación entre tipo de alerta y lección sugerida es fija". Un mapa constante es lo más simple.

**Alternatives considered**:
- Algoritmo de relevancia dinámico: YAGNI, solo hay 5 lecciones.
- Tag system: sobre-ingeniería para un mapa estático de 4 entries.

## R4: Timing de la sugerencia — post-operación

**Decision**: La sugerencia se muestra cuando el usuario vuelve a la pantalla principal después de resolver una alerta Y completar/cancelar la operación. Se usa un provider efímero `pendingSuggestionProvider` que se setea al resolver la alerta y se consume al llegar a la pantalla principal.

**Implementación**:
```dart
// En el provider de 002 (fraud alert), al resolver la alerta:
ref.read(pendingLessonTriggerProvider.notifier).set(
  SuggestionTrigger(triggeredRules: alert.triggeredRules),
);

// En EasyModeHomeScreen, al construir:
final trigger = ref.watch(pendingLessonTriggerProvider);
if (trigger != null) {
  // Buscar lección relevante no completada
  final suggestion = ref.watch(lessonSuggestionProvider(trigger));
  if (suggestion != null) {
    // Mostrar LessonSuggestionCard
  }
}
```

**Flujo**:
1. Alerta del 002 se resuelve → se guarda `SuggestionTrigger` en provider.
2. Operación se completa o cancela.
3. Usuario vuelve a pantalla principal.
4. `EasyModeHomeScreen` lee `pendingLessonTriggerProvider`, busca lección relevante.
5. Si hay lección → muestra `LessonSuggestionCard`.
6. Al aceptar o rechazar → limpia el trigger.

**Key invariant**: El trigger se guarda pero NO se actúa hasta que `operationInProgressProvider` (de 003) es null — garantiza que no interrumpe operaciones (FR-005).

**Rationale**: Provider efímero in-memory. No necesita persistencia — si el usuario cierra la app entre la alerta y la pantalla principal, se pierde la sugerencia. Aceptable para prototipo.

**Alternatives considered**:
- Navigator observer: demasiado acoplado a rutas específicas.
- SharedPreferences para el trigger: sobre-ingeniería, el trigger es efímero.

## R5: Estado de lecciones — persistencia

**Decision**: SharedPreferences con prefijo `lesson_` para guardar qué lecciones se completaron y el contador de rechazos consecutivos.

**Keys**:
| Key | Type | Description |
|-----|------|-------------|
| `lesson_{id}_completed` | `bool` | Si la lección fue completada |
| `lesson_consecutive_rejections` | `int` | Rechazos consecutivos de sugerencias |

**Implementación**:
```dart
class LessonProgressRepository {
  final SharedPreferences _prefs;

  Future<bool> isCompleted(String lessonId) async =>
      _prefs.getBool('lesson_${lessonId}_completed') ?? false;

  Future<void> markCompleted(String lessonId) async =>
      await _prefs.setBool('lesson_${lessonId}_completed', true);

  Future<int> getConsecutiveRejections() async =>
      _prefs.getInt('lesson_consecutive_rejections') ?? 0;

  Future<void> incrementRejections() async {
    final current = await getConsecutiveRejections();
    await _prefs.setInt('lesson_consecutive_rejections', current + 1);
  }

  Future<void> resetRejections() async =>
      await _prefs.setInt('lesson_consecutive_rejections', 0);
}
```

`markCompleted()` también llama `resetRejections()` — completar una lección resetea la racha de rechazos.

**Rationale**: Estado binario (vista/no vista) más un contador. SharedPreferences es suficiente. No son datos sensibles.

**Alternatives considered**:
- flutter_secure_storage: solo para secretos, no para preferencias.
- In-memory only: FR-010 exige que el estado persista entre sesiones.

## R6: Pregunta de práctica — lógica de evaluación

**Decision**: Lógica trivial — comparar `selectedOption.isCorrect`. La retroalimentación es un texto predefinido por opción (no generado). Cada `AnswerOption` tiene su propio `feedback`.

**Implementación**:
```dart
// En PracticeQuestionWidget:
void _onOptionSelected(AnswerOption option) {
  setState(() {
    _selectedOption = option;
    _answered = true;
  });
  if (option.isCorrect) {
    SemanticsService.announce(option.feedback, TextDirection.ltr);
  } else {
    final correct = widget.question.correctOption;
    SemanticsService.announce(
      '${option.feedback} ${correct.feedback}',
      TextDirection.ltr,
    );
  }
}
```

**Respuesta incorrecta**: Se muestra el feedback de la opción elegida (tono amable) + la respuesta correcta con su feedback. Sin "Incorrecto", "Error", "Mal" (FR-009).

**Rationale**: Retroalimentación predefinida da control total del tono. Cada opción tiene su explicación personalizada.

**Alternatives considered**:
- Feedback genérico "correcto/incorrecto": pierde valor educativo.
- Puntuación/score: contradice anti-gamificación.

## R7: Lecciones de ejemplo — contenido

**Decision**: 5 lecciones cubriendo los fraudes del spec (FR-015):

| ID | Título | RiskRule asociado |
|----|--------|------------------|
| `fake_yape` | "El Yape falso" | `newRecipient` |
| `bank_call_scam` | "Llamadas del banco pidiendo claves" | `unusualAmount`, `unusualTime` |
| `fake_prize` | "El premio que no existe" | `highFrequency` |
| `fake_relative` | "El familiar en apuros" | `newRecipient` |
| `sms_phishing` | "Enlaces peligrosos por mensaje" | `unusualTime` |

Cada lección: ≤ 150 palabras de contenido, 1 pregunta con 3 opciones, retroalimentación por opción.

**Rationale**: 5 lecciones cubre todos los `RiskRule` de 002 y todos los temas del spec. El mapeo multi-regla permite que una lección se sugiera en distintos contextos.

**Alternatives considered**:
- Solo 3 lecciones: cubre el mínimo pero deja `highFrequency` y `unusualTime` sin lecciones.
- Más de 5: fuera del alcance del hackathon.

## R8: Regla de 3 rechazos consecutivos

**Decision**: Contador `lesson_consecutive_rejections` en SharedPreferences. Se incrementa con cada "Ahora no". Se resetea a 0 cuando el usuario acepta ver una lección (o la completa). Cuando `>=3`, no se muestran más sugerencias contextuales. Las lecciones siguen disponibles en la lista manual.

**Implementación**:
```dart
// En LessonSuggestionProvider:
Future<bool> shouldSuggest() async {
  final rejections = await progressRepo.getConsecutiveRejections();
  return rejections < 3;
}
```

**Rationale**: "Consecutivos" es clave — aceptar una lección resetea el contador. Esto permite que un usuario que rechaza a veces pero a veces acepta siga recibiendo sugerencias.

**Alternatives considered**:
- Rechazos totales (no consecutivos): penaliza al usuario que rechaza una vez.
- Sin límite de rechazos: puede volverse molesto.
- Límite por lección: el spec dice "3 rechazos consecutivos" global, no por lección.

## R9: Lista de lecciones accesible

**Decision**: `LessonListScreen` accesible desde "Pedir ayuda" → "Aprender sobre estafas" o desde configuración. Muestra todas las lecciones con título y estado (no vista / completada).

**Implementación**:
```dart
// Rutas:
/easy-mode/lessons                → LessonListScreen
/easy-mode/lessons/:lessonId      → LessonScreen
```

Cada item en la lista es un `ListTile` con:
- Título de la lección
- Icono de estado: nada (no vista), check ✓ (completada)
- Semantics label: "Lección: {título}, {estado}"

**Rationale**: Punto de acceso directo para usuarios que quieren explorar sin esperar sugerencias (Story 3).

**Alternatives considered**:
- Modal/bottom sheet: limita espacio para lista.
- Sección en pantalla principal: ocupa espacio permanente, YAGNI.

## R10: No reanudación al cerrar app

**Decision**: Si el usuario cierra la app durante una lección, al volver la lección no se reanuda automáticamente. El estado de la sesión de lección es efímero (in-memory). Solo `completed` se persiste.

El usuario puede reabrir la lección desde la lista. La pregunta no se marca como completada hasta que se responda.

**Rationale**: Reanudación requeriría persistir posición de lectura, estado de TTS, etc. YAGNI. Las lecciones son < 1 minuto, releerlas es trivial.

**Alternatives considered**:
- Persistir posición: complejidad sin beneficio para contenido de 1 minuto.
- Marcar "en progreso" si se abrió: el spec tiene 3 estados (no vista, en progreso, completada) pero "en progreso" es efímero — solo significa "la abrí ahora".

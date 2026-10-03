# Scam Lessons Contract (011-scam-lessons)

Microlecciones educativas sobre fraudes con sugerencia contextual post-alerta, audio TTS, y pregunta de práctica.

## LessonRepository

Ubicación: `lib/features/scam_lessons/domain/repositories/lesson_repository.dart`

Dart puro. Interfaz abstracta.

```dart
abstract class LessonRepository {
  Future<List<Lesson>> getAllLessons();
  Future<Lesson> getLessonById(String id);
  Future<List<Lesson>> getLessonsByRiskRules(Set<RiskRule> rules);
}
```

**Contrato**:
- `getAllLessons()` retorna todas las lecciones en orden fijo.
- `getLessonById()` lanza `LessonNotFoundException` si el ID no existe.
- `getLessonsByRiskRules()` retorna las lecciones cuyo `relatedRiskRules` intersecta con el set dado. Orden: enum order de la primera regla coincidente.

## LessonProgressRepository

Ubicación: `lib/features/scam_lessons/data/repositories/lesson_progress_repository.dart`

```dart
class LessonProgressRepository {
  final SharedPreferences _prefs;

  LessonProgressRepository(this._prefs);

  Future<bool> isCompleted(String lessonId) async =>
      _prefs.getBool('lesson_${lessonId}_completed') ?? false;

  Future<void> markCompleted(String lessonId) async {
    await _prefs.setBool('lesson_${lessonId}_completed', true);
    await resetRejections();
  }

  Future<Map<String, bool>> getAllProgress(List<String> lessonIds) async {
    return {for (final id in lessonIds) id: await isCompleted(id)};
  }

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

**Contrato**:
- `isCompleted()` retorna `false` si no hay valor guardado (fresh install).
- `markCompleted()` es idempotente y resetea el contador de rechazos.
- `incrementRejections()` es acumulativo. Solo se resetea al completar una lección.
- `getAllProgress()` retorna mapa completo para la lista de lecciones.

## MockLessonRepository

Ubicación: `lib/features/scam_lessons/data/repositories/mock_lesson_repository.dart`

```dart
class MockLessonRepository implements LessonRepository {
  final AppLocalizations _l10n;

  MockLessonRepository(this._l10n);

  @override
  Future<List<Lesson>> getAllLessons() async => _lessons;

  @override
  Future<Lesson> getLessonById(String id) async =>
      _lessons.firstWhere(
        (l) => l.id == id,
        orElse: () => throw LessonNotFoundException(id),
      );

  @override
  Future<List<Lesson>> getLessonsByRiskRules(Set<RiskRule> rules) async =>
      _lessons.where((l) => l.relatedRiskRules.intersection(rules).isNotEmpty).toList();

  late final List<Lesson> _lessons = [
    _buildFakeYape(),
    _buildBankCallScam(),
    _buildFakePrize(),
    _buildFakeRelative(),
    _buildSmsPhishing(),
  ];

  Lesson _buildFakeYape() => Lesson(
    id: 'fake_yape',
    title: _l10n.lessonFakeYapeTitle,
    content: _l10n.lessonFakeYapeContent,
    relatedRiskRules: {RiskRule.newRecipient},
    question: PracticeQuestion(
      prompt: _l10n.lessonFakeYapeQuestionPrompt,
      options: [
        AnswerOption(
          text: _l10n.lessonFakeYapeOptionA,
          isCorrect: false,
          feedback: _l10n.lessonFakeYapeFeedbackA,
        ),
        AnswerOption(
          text: _l10n.lessonFakeYapeOptionB,
          isCorrect: true,
          feedback: _l10n.lessonFakeYapeFeedbackB,
        ),
        AnswerOption(
          text: _l10n.lessonFakeYapeOptionC,
          isCorrect: false,
          feedback: _l10n.lessonFakeYapeFeedbackC,
        ),
      ],
    ),
  );

  // _buildBankCallScam(), _buildFakePrize(), _buildFakeRelative(),
  // _buildSmsPhishing() — same pattern with respective ARB keys
}
```

**Contrato**:
- 5 lecciones con IDs fijos: `fake_yape`, `bank_call_scam`, `fake_prize`, `fake_relative`, `sms_phishing`.
- Cada lección tiene exactamente 1 `PracticeQuestion` con ≥ 3 `AnswerOption`.
- Exactamente 1 opción tiene `isCorrect: true` por pregunta.
- Textos vienen de ARB (localizados).

## PendingLessonTriggerProvider

Ubicación: `lib/features/scam_lessons/presentation/providers/lesson_suggestion_provider.dart`

```dart
@riverpod
class PendingLessonTrigger extends _$PendingLessonTrigger {
  @override
  SuggestionTrigger? build() => null;

  void set(SuggestionTrigger trigger) => state = trigger;
  void clear() => state = null;
}
```

**Contrato**:
- Provider efímero in-memory. Se pierde al cerrar la app.
- Se setea desde el provider de 002 al resolver una alerta.
- Se consume y limpia al mostrar/descartar la sugerencia.

## LessonSuggestionProvider

Ubicación: `lib/features/scam_lessons/presentation/providers/lesson_suggestion_provider.dart`

```dart
@riverpod
Future<LessonSuggestion?> lessonSuggestion(Ref ref) async {
  final trigger = ref.watch(pendingLessonTriggerProvider);
  if (trigger == null) return null;

  // Gate: no sugerir si hay operación en curso
  final opInProgress = ref.watch(operationInProgressProvider);
  if (opInProgress != null) return null;

  // Gate: no sugerir si 3+ rechazos consecutivos
  final progressRepo = ref.read(lessonProgressRepositoryProvider);
  final rejections = await progressRepo.getConsecutiveRejections();
  if (rejections >= 3) return null;

  // Buscar lección relevante no completada
  final lessonRepo = ref.read(lessonRepositoryProvider);
  final candidates = await lessonRepo.getLessonsByRiskRules(trigger.triggeredRules);

  for (final lesson in candidates) {
    final completed = await progressRepo.isCompleted(lesson.id);
    if (!completed) {
      return LessonSuggestion(lesson: lesson, trigger: trigger);
    }
  }

  return null; // Todas las relevantes ya completadas
}
```

**Contrato**:
- Retorna `null` si: no hay trigger, hay operación en curso, 3+ rechazos, o todas las lecciones relevantes están completadas.
- Retorna la primera lección relevante no completada.
- Se re-evalúa reactivamente cuando cambia el trigger o `operationInProgressProvider`.

## LessonNotifier (Provider de lección activa)

Ubicación: `lib/features/scam_lessons/presentation/providers/lesson_provider.dart`

```dart
@riverpod
class LessonNotifier extends _$LessonNotifier {
  @override
  LessonViewState build(String lessonId) {
    return LessonViewState(
      lessonId: lessonId,
      ttsState: TtsState.idle,
      answered: false,
    );
  }

  Future<void> startReading(String content) async {
    final tts = ref.read(ttsServiceProvider);
    tts.setCompletionHandler(() {
      state = state.copyWith(ttsState: TtsState.completed);
    });
    state = state.copyWith(ttsState: TtsState.playing);
    await tts.speak(content);
  }

  Future<void> pauseTts() async {
    await ref.read(ttsServiceProvider).stop();
    state = state.copyWith(ttsState: TtsState.paused);
  }

  Future<void> answerQuestion(AnswerOption selected) async {
    state = state.copyWith(
      answered: true,
      selectedOption: selected,
    );
    await ref.read(lessonProgressRepositoryProvider).markCompleted(lessonId);
  }
}
```

**LessonViewState** (freezed):
```dart
@freezed
class LessonViewState with _$LessonViewState {
  const factory LessonViewState({
    required String lessonId,
    required TtsState ttsState,
    required bool answered,
    AnswerOption? selectedOption,
  }) = _LessonViewState;
}
```

**Contrato**:
- `startReading()` inicia TTS con el contenido de la lección.
- `pauseTts()` detiene TTS (el texto siempre está visible como alternativa).
- `answerQuestion()` marca la lección como completada y guarda la opción elegida para mostrar feedback.
- Estado efímero. No persiste posición de lectura ni estado TTS.

## LessonSuggestionCard Widget

Ubicación: `lib/features/scam_lessons/presentation/widgets/lesson_suggestion_card.dart`

```dart
class LessonSuggestionCard extends ConsumerWidget {
  final LessonSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: '${suggestion.lesson.title}. '
          '${context.l10n.lessonSuggestionAccessibilityLabel}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.lessonSuggestionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(context.l10n.lessonSuggestionBody(suggestion.lesson.title)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(pendingLessonTriggerProvider.notifier).clear();
                        ref.read(lessonProgressRepositoryProvider)
                            .resetRejections();
                        context.push(
                            '/easy-mode/lessons/${suggestion.lesson.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(context.l10n.lessonSuggestionAccept),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref.read(lessonProgressRepositoryProvider)
                            .incrementRejections();
                        ref.read(pendingLessonTriggerProvider.notifier).clear();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(context.l10n.lessonSuggestionReject),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Contrato**:
- 2 botones: "Ver lección" y "Ahora no", ambos ≥ 48dp alto.
- "Ver lección": limpia trigger, resetea rechazos, navega a la lección.
- "Ahora no": incrementa rechazos, limpia trigger.
- `Semantics.label` anuncia el título de la lección y la sugerencia completa.
- `SemanticsService.announce()` al aparecer.

## PracticeQuestionWidget

Ubicación: `lib/features/scam_lessons/presentation/widgets/practice_question_widget.dart`

```dart
class PracticeQuestionWidget extends StatefulWidget {
  final PracticeQuestion question;
  final ValueChanged<AnswerOption> onAnswered;
}
```

**Contrato**:
- Muestra prompt + opciones como botones verticales (full-width, ≥ 48dp).
- Al tocar una opción: `onAnswered` callback, opciones se deshabilitan.
- Si correcta: muestra feedback de la opción elegida en verde (color `secondary`).
- Si incorrecta: muestra feedback de la opción elegida + feedback de la correcta. Sin "Incorrecto"/"Error"/"Mal".
- `SemanticsService.announce(feedback)` al mostrar resultado.
- Botón "Volver" aparece después de responder.

## Contrato de integración con 002 (Escudo antifraude)

Al resolver una alerta en `FraudAlertScreen`:

```dart
// En el provider/handler de resolución de alerta de 002:
void onAlertResolved(RiskAlert alert) {
  ref.read(pendingLessonTriggerProvider.notifier).set(
    SuggestionTrigger(triggeredRules: alert.triggeredRules),
  );
}
```

**Cuándo se resuelve**: cuando el usuario elige "Cancelar", "Continuar de todos modos", o "Consultar a mi persona de confianza" (y completa ese flujo). El trigger se guarda inmediatamente. La sugerencia se muestra después de que la operación termine.

## Contrato de integración con 001 (EasyModeHomeScreen)

```dart
// En EasyModeHomeScreen.build():
final suggestion = ref.watch(lessonSuggestionProvider);

Column(
  children: [
    // Sugerencia de lección (si aplica):
    if (suggestion.valueOrNull != null)
      LessonSuggestionCard(suggestion: suggestion.valueOrNull!),
    // ... propuesta de unlock (009), acciones primarias, extras
  ],
)
```

**Prioridad visual**: La sugerencia de lección aparece encima de las acciones primarias, como la propuesta de 009. Si ambas aplican en la misma sesión, la sugerencia de lección tiene prioridad (es contextual y efímera, la propuesta de 009 puede esperar).

## Contrato de integración con 003 (operación en curso)

```dart
// Gate en LessonSuggestionProvider:
final opInProgress = ref.watch(operationInProgressProvider);
if (opInProgress != null) return null; // No sugerir durante operación
```

Usa `operationInProgressProvider` de 003 para detectar si hay una operación activa. La sugerencia espera hasta que el provider retorne null.

## Contrato de integración con 004 (TTS)

```dart
final tts = ref.read(ttsServiceProvider);
await tts.speak(lesson.content);
await tts.stop();
```

Reutiliza el mismo `TtsService` de 004. El contenido de la lección se pasa como texto plano.

## Rutas de navegación

```
/easy-mode/lessons                → LessonListScreen (lista de todas)
/easy-mode/lessons/:lessonId      → LessonScreen (contenido + pregunta)
```

Registradas como sub-rutas de `/easy-mode` en `go_router`:

```dart
GoRoute(
  path: 'lessons',
  builder: (_, __) => const LessonListScreen(),
  routes: [
    GoRoute(
      path: ':lessonId',
      builder: (_, state) => LessonScreen(
        lessonId: state.pathParameters['lessonId']!,
      ),
    ),
  ],
),
```

## Invariantes

1. **3 componentes por lección**: Texto + audio + pregunta. Sin excepciones.
2. **Nunca interrumpe**: Gate por `operationInProgressProvider`. Sugerencia solo post-operación.
3. **Una sugerencia por alerta**: Un `SuggestionTrigger` produce máximo una sugerencia.
4. **No re-sugiere completadas**: `isCompleted` filtra en el provider de sugerencia.
5. **3 rechazos consecutivos = solo manual**: `consecutiveRejections >= 3` → provider retorna null.
6. **Completar resetea rechazos**: `markCompleted()` llama `resetRejections()`.
7. **Retroalimentación sin negatividad**: Nunca "Incorrecto", "Error", "Mal". Tono amable.
8. **Completada al responder**: Correcta o incorrecta, se marca `completed`.
9. **Accesibilidad**: 48×48 dp, 4.5:1, Semantics labels, TalkBack.
10. **Sin gamificación**: Sin puntos, rachas, insignias, niveles.

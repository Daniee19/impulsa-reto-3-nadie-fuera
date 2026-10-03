# Quickstart: Microlecciones contra Estafas (011-scam-lessons)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Feature 001-easy-mode implementada (pantalla principal)
- Feature 002-fraud-shield implementada (Escudo antifraude, RiskAlert)
- Feature 003-contextual-human-help implementada (operationInProgressProvider)
- Feature 004-voice-text-assistant implementada (TtsService)
- Android emulator o dispositivo con API 26+
- TalkBack para pruebas de accesibilidad

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: Sugerencia post-alerta (US1 — P1, FR-003, SC-001)

1. Iniciar una transferencia a un destinatario nuevo (triggers `newRecipient`)
2. **Expected**: Alerta del Escudo antifraude (002) aparece
3. Resolver la alerta (elegir "Continuar" o "Cancelar")
4. Completar o cancelar la operación
5. Volver a la pantalla principal
6. **Expected**: Aparece sugerencia: "¿Sabías que muchas estafas usan contactos falsos? Aprende a identificarlas en 1 minuto."
7. **Expected**: 2 opciones: "Ver lección" y "Ahora no"
8. **A11y check**: TalkBack anuncia la sugerencia completa con opciones

### VS-2: Ver lección completa con audio y pregunta (US1+US2 — P1, FR-001)

1. Desde la sugerencia (VS-1), tocar "Ver lección"
2. **Expected**: Pantalla de lección "El Yape falso"
3. **Expected**: Texto visible en la pantalla (≤ 150 palabras, ≤ 15 palabras/oración)
4. **Expected**: TTS empieza a leer automáticamente el contenido
5. **Expected**: Botón de pausa visible (≥ 48dp)
6. Esperar a que TTS termine (o pausar)
7. **Expected**: Pregunta de práctica visible con 3 opciones
8. Elegir la opción correcta (B: "Reviso mi saldo real")
9. **Expected**: Feedback positivo: "¡Bien hecho! Siempre revisa tu saldo..."
10. **Expected**: TalkBack anuncia el feedback

### VS-3: Respuesta incorrecta con retroalimentación amable (US2 — P1, FR-009)

1. Abrir lección "El Yape falso" (desde lista o sugerencia)
2. En la pregunta de práctica, elegir opción incorrecta (A: "Devuelvo el dinero")
3. **Expected**: Feedback amable sin "Incorrecto"/"Error"/"Mal"
4. **Expected**: Se muestra la respuesta correcta con su explicación
5. **Expected**: La lección se marca como completada (respondió, aunque mal)
6. **Expected**: TalkBack lee feedback completo

### VS-4: "Ahora no" descarta sin insistir (US1 — P1, FR-006)

1. Provocar sugerencia de lección (VS-1)
2. Tocar "Ahora no"
3. **Expected**: Sugerencia desaparece
4. Navegar por la app, volver a pantalla principal
5. **Expected**: La sugerencia NO reaparece en esta sesión

### VS-5: 3 rechazos consecutivos desactivan sugerencias (FR-006)

1. Provocar y rechazar 3 sugerencias consecutivas (en 3 eventos de alerta distintos)
2. Provocar una 4ta alerta
3. Volver a pantalla principal
4. **Expected**: NO aparece sugerencia de lección
5. Ir a lista de lecciones manualmente
6. **Expected**: Lecciones accesibles desde la lista

### VS-6: Sugerencia NO aparece durante operación (US5 — P1, FR-005, SC-002)

1. Iniciar transferencia → recibir alerta → elegir "Continuar de todos modos"
2. **Expected**: Estás en pantalla de confirmación de la operación
3. **Expected**: NO aparece sugerencia de lección
4. Completar la operación
5. Volver a pantalla principal
6. **Expected**: AHORA aparece la sugerencia

### VS-7: Lista de lecciones con estado (US3 — P2, FR-007, FR-008)

1. Navegar a "Pedir ayuda" → "Aprender sobre estafas" (o configuración → lecciones)
2. **Expected**: Lista con 5 lecciones, títulos claros
3. **Expected**: Lecciones no vistas sin icono de estado
4. Abrir y completar "El Yape falso"
5. Volver a la lista
6. **Expected**: "El Yape falso" marcada con check ✓ (completada)
7. **Expected**: Las demás siguen sin marcar
8. Abrir lección completada
9. **Expected**: Se puede revisar de nuevo (mismo contenido y pregunta)

### VS-8: No re-sugiere lección completada (FR-011)

1. Completar "El Yape falso"
2. Provocar alerta por `newRecipient` de nuevo
3. Volver a pantalla principal
4. **Expected**: Sugerencia ofrece "El familiar en apuros" (siguiente lección con `newRecipient`), NO "El Yape falso"

### VS-9: Accesibilidad con TalkBack (US4 — P2, FR-013, SC-007)

1. Activar TalkBack
2. Provocar sugerencia de lección
3. **Expected**: TalkBack anuncia sugerencia completa + "Ver lección" + "Ahora no"
4. Abrir lección
5. **Expected**: TalkBack lee el contenido de la lección (texto visible)
6. Navegar a la pregunta con swipe
7. **Expected**: TalkBack anuncia la pregunta y las 3 opciones
8. Seleccionar una opción
9. **Expected**: TalkBack lee la retroalimentación completa
10. **Expected**: Todos los botones tienen target ≥ 48×48 dp

## Automated Tests

```bash
# Unit tests de entities y lógica (Dart puro)
flutter test test/features/scam_lessons/domain/

# Unit tests de repositories (SharedPreferences mock)
flutter test test/features/scam_lessons/data/

# Widget tests (sugerencia, lección, pregunta, lista, a11y)
flutter test test/features/scam_lessons/presentation/

# Integration test (flujo completo post-alerta)
flutter test integration_test/scam_lessons_flow_test.dart
```

### Tests de MockLessonRepository (unit)

```
test: getAllLessons retorna 5 lecciones
test: getLessonById('fake_yape') retorna lección correcta
test: getLessonById('unknown') lanza LessonNotFoundException
test: getLessonsByRiskRules({newRecipient}) retorna fake_yape y fake_relative
test: getLessonsByRiskRules({highFrequency}) retorna fake_prize
test: cada lección tiene exactamente 1 opción correcta
test: cada lección tiene ≥ 3 opciones
```

### Tests de LessonProgressRepository (unit)

```
test: isCompleted sin datos → false
test: markCompleted persiste y se lee
test: markCompleted resetea rejections
test: incrementRejections acumula
test: resetRejections pone a 0
test: getAllProgress retorna mapa completo
```

### Tests de LessonSuggestionProvider (unit)

```
test: sin trigger → null
test: con trigger y operación en curso → null
test: con trigger y 3+ rechazos → null
test: con trigger y lección relevante no completada → suggestion
test: con trigger y todas relevantes completadas → null
test: prioridad: primera no completada en orden
```

### Tests de PracticeQuestionWidget (widget)

```
test: muestra prompt y 3 opciones
test: opción correcta muestra feedback positivo
test: opción incorrecta muestra feedback amable + correcta
test: opciones se deshabilitan después de responder
test: feedback no contiene "Incorrecto", "Error", "Mal"
test: SemanticsService.announce al mostrar feedback
```

### A11y guidelines en widget tests

```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Tests específicos:
- LessonSuggestionCard: Semantics label con título y opciones
- PracticeQuestionWidget: opciones navegables por TalkBack
- LessonListScreen: cada item con Semantics label incluyendo estado

## Definition of Done

- [ ] 5 lecciones de ejemplo: Yape falso, llamadas del banco, falso premio, familiar en apuros, SMS con enlaces
- [ ] Cada lección: texto (≤ 150 palabras, ≤ 15 palabras/oración) + audio TTS + pregunta (≥ 3 opciones)
- [ ] Sugerencia contextual post-alerta de 002, mapeada por RiskRule
- [ ] Sugerencia solo post-operación (nunca durante)
- [ ] "Ahora no" sin insistencia. 3 rechazos consecutivos = solo acceso manual
- [ ] No re-sugiere lecciones completadas
- [ ] Lista accesible desde ayuda/configuración con estado (no vista / completada)
- [ ] Retroalimentación amable: sin "Incorrecto"/"Error"/"Mal", tono positivo
- [ ] Completada al responder (correcta o incorrectamente)
- [ ] Audio pausable, texto siempre visible
- [ ] Sin gamificación (sin puntos, niveles, insignias)
- [ ] Textos en ARB, código en inglés
- [ ] Accesibilidad: TalkBack, 4.5:1, 48×48 dp, Semantics labels
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit (repo, progress, suggestion), widget (card, pregunta, lista, a11y), integration

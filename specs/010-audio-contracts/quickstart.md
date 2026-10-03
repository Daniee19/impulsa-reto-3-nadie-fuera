# Quickstart: Contratos Explicados en Audio (010-audio-contracts)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Feature 004-voice-text-assistant implementada (TtsService y ttsServiceProvider)
- Android emulator o dispositivo con API 26+
- TalkBack para pruebas de accesibilidad
- Volumen del dispositivo al máximo para pruebas TTS

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: Resumen con 4 secciones (FR-001, SC-001)

1. Navegar a `/contracts/savings_account/summary`
2. **Expected**: Pantalla muestra 4 secciones visibles: "Qué aceptas", "Cuánto cuesta", "Qué puede salir mal", "Cómo cancelar"
3. **Expected**: Cada sección tiene título y texto en lenguaje simple (≤ 15 palabras/oración)
4. **Expected**: Botón "Aceptar" está deshabilitado (gris, no clickeable)
5. **Expected**: Banner "Asegúrate de que el volumen esté alto" visible

### VS-2: Lectura automática con TTS (FR-002, SC-003)

1. Abrir `/contracts/savings_account/summary`
2. **Expected**: TTS empieza a leer automáticamente "Qué aceptas" después de ~500ms
3. **Expected**: La sección "Qué aceptas" se resalta visualmente (borde lateral)
4. **Expected**: Al terminar sección 1, pausa ~800ms, empieza sección 2
5. **Expected**: Progreso visual: secciones completadas muestran check ✓
6. Esperar a que TTS lea las 4 secciones
7. **Expected**: TTS anuncia "Ya puedes aceptar el contrato"
8. **Expected**: Botón "Aceptar" ahora está habilitado (color primario)

### VS-3: Controles de reproducción (FR-003, SC-004)

1. Abrir resumen de contrato, TTS leyendo sección 1
2. Tocar **Pausar**
3. **Expected**: TTS se detiene, icono cambia a Play
4. Tocar **Continuar**
5. **Expected**: TTS retoma la sección desde el inicio
6. Tocar **Repetir**
7. **Expected**: TTS re-lee la sección actual desde el principio
8. Tocar **Velocidad** (muestra "100%")
9. **Expected**: Cambia a "75%", TTS lee más lento
10. Tocar **Velocidad** de nuevo
11. **Expected**: Cambia a "50%", TTS lee aún más lento
12. Tocar **Velocidad** de nuevo
13. **Expected**: Vuelve a "100%"

### VS-4: Habilitar "Aceptar" por scroll (FR-004, SC-005)

1. Abrir resumen de contrato
2. Pausar TTS inmediatamente
3. **Expected**: Botón "Aceptar" deshabilitado
4. Scrollear manualmente hasta el final del resumen (todas las secciones visibles)
5. **Expected**: Botón "Aceptar" se habilita
6. Tocar "Aceptar"
7. **Expected**: Contrato aceptado, confirmación visual

### VS-5: Habilitar "Aceptar" por audio completo (FR-004, SC-005)

1. Abrir resumen de contrato
2. Dejar TTS leer las 4 secciones sin pausar
3. **Expected**: Al terminar la sección 4, botón "Aceptar" se habilita
4. **Expected**: `sectionsHeard` contiene los 4 tipos
5. Tocar "Aceptar"
6. **Expected**: Contrato aceptado

### VS-6: Contrato completo con lectura por párrafo (FR-005, SC-006)

1. Desde el resumen, tocar "Ver contrato completo"
2. **Expected**: Navega a `/contracts/savings_account/full`
3. **Expected**: Texto legal completo dividido en párrafos (8 para cuenta de ahorro)
4. **Expected**: Cada párrafo tiene un botón "Leer" (icono speaker)
5. Tocar "Leer" en el párrafo 3
6. **Expected**: TTS lee solo ese párrafo, botón cambia a estado "leyendo"
7. Tocar "Leer" en otro párrafo mientras lee
8. **Expected**: TTS detiene el anterior y empieza el nuevo
9. Tocar Back
10. **Expected**: Vuelve al resumen, progreso de revisión conservado

### VS-7: Preguntar al asistente (FR-006)

1. Desde el resumen, tocar "¿Tienes una pregunta?"
2. **Expected**: TTS se pausa si estaba leyendo
3. **Expected**: Navega al asistente de voz (004)
4. Volver al resumen (back)
5. **Expected**: Progreso de revisión conservado (secciones ya oídas)
6. **Expected**: TTS no se reanuda automáticamente (usuario debe tocar Play)

### VS-8: Segundo contrato — préstamo personal (FR-001)

1. Navegar a `/contracts/personal_loan/summary`
2. **Expected**: 4 secciones con contenido diferente al de cuenta de ahorro
3. **Expected**: TTS lee contenido del préstamo (interés, multas, etc.)
4. Completar lectura y aceptar
5. **Expected**: Aceptación registrada con contractId `personal_loan`

### VS-9: Accesibilidad con TalkBack (SC-007, SC-008)

1. Activar TalkBack
2. Abrir resumen de contrato
3. **Expected**: TalkBack anuncia "Leyendo el resumen del contrato" al abrir
4. Navegar a los controles con swipe
5. **Expected**: Cada control anuncia su función: "Pausar lectura", "Repetir esta sección", "Velocidad: 100%"
6. Navegar al botón "Aceptar"
7. **Expected**: TalkBack anuncia "Primero lee o escucha el resumen para poder aceptar" (si deshabilitado) o "Aceptar contrato" (si habilitado)
8. **Expected**: Sección activa anunciada cuando cambia
9. **Expected**: Todos los botones tienen target ≥ 48×48 dp

## Automated Tests

```bash
# Unit tests de entities y lógica de ReviewSession (Dart puro)
flutter test test/features/audio_contracts/domain/

# Unit tests del MockContractRepository
flutter test test/features/audio_contracts/data/

# Widget tests (controles, botón aceptar, a11y)
flutter test test/features/audio_contracts/presentation/

# Integration test (flujo completo)
flutter test integration_test/audio_contracts_flow_test.dart
```

### Tests de ReviewSession (unit, Dart puro)

```
test: reviewCompleted = false con 0 secciones y scrolledToEnd = false
test: reviewCompleted = true con 4 secciones oídas
test: reviewCompleted = true con scrolledToEnd = true (0 secciones)
test: reviewCompleted = false con 3 secciones oídas y scrolledToEnd = false
test: cycleSpeed: normal → slow → slower → normal
```

### Tests de ContractRepository (unit)

```
test: getContractSummary('savings_account') retorna 4 secciones
test: getContractSummary('personal_loan') retorna 4 secciones
test: getContractSummary('unknown') lanza ContractNotFoundException
test: getAvailableContractIds retorna ['savings_account', 'personal_loan']
test: cada sección tiene content no vacío
```

### Tests de ContractReviewNotifier (unit, con mock TTS)

```
test: startAutoRead llama tts.speak con sección 1
test: pauseTts llama tts.stop y cambia estado a paused
test: repeatSection re-lee sección actual
test: cycleSpeed aplica setSpeechRate al TTS
test: markScrolledToEnd habilita reviewCompleted
test: accept retorna ContractAcceptance con ReviewMethod correcto
test: accept falla si reviewCompleted == false
test: onSectionComplete avanza a siguiente sección
test: onSectionComplete en última sección marca completed
```

### A11y guidelines en widget tests

```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Tests específicos:
- TtsPlaybackControls: 3 botones con Semantics labels
- AcceptButton deshabilitado anuncia razón
- ContractSummaryScreen anuncia sección activa con SemanticsService

## Definition of Done

- [ ] 2 contratos de ejemplo (cuenta de ahorro, préstamo personal) con 4 secciones cada uno
- [ ] Textos en ARB, ≤ 15 palabras/oración, sin jerga financiera
- [ ] Lectura automática al abrir (TTS de 004 reutilizado)
- [ ] Highlight visual de sección activa, check ✓ en completadas
- [ ] 3 controles: pausar/reanudar, repetir sección, velocidad (100/75/50%)
- [ ] Botón "Aceptar" deshabilitado hasta completar revisión (audio completo O scroll al final)
- [ ] Pantalla de contrato completo con lectura por párrafo individual
- [ ] Botón "¿Tienes una pregunta?" navega al asistente (004)
- [ ] Banner informativo sobre volumen al abrir
- [ ] Rutas parametrizadas: `/contracts/:contractId/summary`, `/contracts/:contractId/full`
- [ ] Accesibilidad: TalkBack, contraste 4.5:1, 48×48 dp, Semantics labels en español
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit (entities, repo, notifier), widget (controles, botón, a11y), integration

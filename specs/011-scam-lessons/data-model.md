# Data Model: Microlecciones contra Estafas (011-scam-lessons)

## Entities

### Lesson (Microlección)

Unidad de contenido educativo. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Identificador único | Non-empty |
| `title` | `String` | Título localizado | Non-empty |
| `content` | `String` | Texto de la lección (lenguaje simple) | Non-empty, ≤ 150 palabras |
| `relatedRiskRules` | `Set<RiskRule>` | Reglas de 002 que mapean a esta lección | Non-empty |
| `question` | `PracticeQuestion` | Pregunta de práctica | Non-null |

Cada oración del `content` tiene ≤ 15 palabras. Sin jerga financiera.

### PracticeQuestion (Pregunta de práctica)

Pregunta de opción múltiple al final de la lección. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `prompt` | `String` | Enunciado en lenguaje cotidiano (escenario) | Non-empty, ≤ 15 palabras/oración |
| `options` | `List<AnswerOption>` | Opciones de respuesta | Length ≥ 3 |

**Propiedad derivada**:
```dart
AnswerOption get correctOption => options.firstWhere((o) => o.isCorrect);
```

### AnswerOption (Opción de respuesta)

Una opción de la pregunta. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `text` | `String` | Texto de la opción | Non-empty |
| `isCorrect` | `bool` | Si es la respuesta correcta | Exactamente 1 por pregunta |
| `feedback` | `String` | Retroalimentación al elegir esta opción | Non-empty |

**Reglas de retroalimentación** (FR-009):
- Correcta: tono positivo de refuerzo ("¡Bien hecho! Siempre revisa tu saldo...")
- Incorrecta: tono amable sin "Incorrecto", "Error", "Mal" ("Cuidado: dar tu clave nunca es seguro. Mejor opción: ...")

### LessonProgress (Progreso de una lección)

Estado persistido por lección. No es freezed — son valores simples de SharedPreferences.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `completed` | `bool` | `false` | Si se respondió la pregunta |

**State transitions**:
```
not_seen ──→ completed    (usuario responde la pregunta, correcta o incorrectamente)
```

No hay transición inversa. Una lección completada puede revisarse pero no "descompletarse".

### SuggestionTrigger (Disparador de sugerencia)

Datos del evento que dispara una sugerencia. Freezed, efímero (in-memory).

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `triggeredRules` | `Set<RiskRule>` | Reglas de la alerta que se resolvió | Non-empty |

### LessonSuggestion (Sugerencia de lección)

Sugerencia contextual para mostrar al usuario. Freezed, efímera.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `lesson` | `Lesson` | Lección sugerida | Non-null |
| `trigger` | `SuggestionTrigger` | Evento que la disparó | Non-null |

## Example Lessons (Static Data)

### 1. El Yape falso (`fake_yape`)

| Field | Value |
|-------|-------|
| Title | "El Yape falso" |
| Content | "Alguien te escribe diciendo que te mandó dinero por error. Te pide que se lo devuelvas. Pero nunca te enviaron nada. Es una estafa común. Antes de devolver dinero, revisa tu saldo real en la app. Si no entró nada, no devuelvas nada." |
| Related rules | `newRecipient` |
| Question | "Te escriben diciendo que te enviaron dinero por error. ¿Qué haces?" |
| Option A | "Devuelvo el dinero para ser amable" → "Cuidado: si devuelves sin revisar, pierdes tu dinero. Primero verifica tu saldo." |
| Option B ✓ | "Reviso mi saldo real antes de hacer nada" → "¡Bien hecho! Siempre revisa tu saldo. Si no recibiste nada, es una estafa." |
| Option C | "Les doy mi clave para que lo arreglen" → "Nunca compartas tu clave con nadie. Ni el banco te la pide. La mejor opción es revisar tu saldo." |

### 2. Llamadas del banco pidiendo claves (`bank_call_scam`)

| Field | Value |
|-------|-------|
| Title | "Llamadas del banco pidiendo claves" |
| Content | "Te llaman diciendo que son del banco. Te dicen que hay un problema con tu cuenta. Te piden tu clave o tu número de tarjeta. Un banco de verdad nunca te pide esos datos por teléfono. Si recibes esa llamada, cuelga y llama tú al número oficial del banco." |
| Related rules | `unusualAmount`, `unusualTime` |
| Question | "Te llaman diciendo que son del banco y piden tu clave. ¿Qué haces?" |
| Option A ✓ | "Cuelgo y llamo yo al banco" → "¡Correcto! Si el banco necesita algo, tú lo llamas al número oficial." |
| Option B | "Les doy mis datos para solucionar el problema" → "Cuidado: un banco real nunca pide tu clave por teléfono. Si diste tus datos, llama al banco de inmediato." |
| Option C | "Les pido que me manden un correo" → "Los estafadores también envían correos falsos. Lo más seguro es llamar tú al banco." |

### 3. El premio que no existe (`fake_prize`)

| Field | Value |
|-------|-------|
| Title | "El premio que no existe" |
| Content | "Recibes un mensaje diciendo que ganaste un premio o un sorteo. Te piden que pagues un monto pequeño para recibirlo. Nadie regala premios así. Si no participaste en un sorteo, no puedes ganar. Los premios reales nunca te cobran para recibirlos." |
| Related rules | `highFrequency` |
| Question | "Recibes un mensaje diciendo que ganaste un premio. ¿Qué haces?" |
| Option A | "Pago lo que piden porque es poco dinero" → "Aunque sea poco, es una estafa. Después te pedirán más. Nadie regala premios cobrando." |
| Option B | "Comparto mis datos para recibir el premio" → "Nunca compartas tus datos por un premio. Los estafadores los usan para robarte." |
| Option C ✓ | "Lo ignoro porque no participé en ningún sorteo" → "¡Exacto! Si no participaste, no hay premio. Los sorteos reales no te cobran." |

### 4. El familiar en apuros (`fake_relative`)

| Field | Value |
|-------|-------|
| Title | "El familiar en apuros" |
| Content | "Te llaman o escriben haciéndose pasar por un familiar. Dicen que están en una emergencia y necesitan dinero urgente. Te piden que envíes dinero rápido sin contárselo a nadie. Antes de enviar, llama directamente a tu familiar para confirmar." |
| Related rules | `newRecipient` |
| Question | "Un 'familiar' te pide dinero urgente por mensaje. ¿Qué haces?" |
| Option A | "Envío el dinero rápido porque es una emergencia" → "Las estafas usan la urgencia para que no pienses. Siempre confirma primero." |
| Option B ✓ | "Llamo directamente a mi familiar para confirmar" → "¡Muy bien! Siempre verifica llamando tú. Los estafadores no quieren que hagas eso." |
| Option C | "Le pido más detalles por el mismo mensaje" → "Los estafadores pueden inventar detalles. Lo seguro es llamar directamente a tu familiar." |

### 5. Enlaces peligrosos por mensaje (`sms_phishing`)

| Field | Value |
|-------|-------|
| Title | "Enlaces peligrosos por mensaje" |
| Content | "Recibes un mensaje de texto con un enlace. Dice que tu cuenta será bloqueada si no entras ahora. Los bancos no bloquean cuentas por mensaje. Esos enlaces te llevan a páginas falsas que roban tus datos. Nunca toques enlaces de mensajes que no esperabas." |
| Related rules | `unusualTime` |
| Question | "Recibes un mensaje con un enlace diciendo que tu cuenta será bloqueada. ¿Qué haces?" |
| Option A | "Toco el enlace para ver qué pasa" → "Esos enlaces llevan a páginas falsas que roban tus datos. Nunca los abras." |
| Option B | "Le reenvío el mensaje a un amigo para que me ayude" → "No reenvíes mensajes sospechosos. Podrías exponer a otros." |
| Option C ✓ | "Borro el mensaje y lo ignoro" → "¡Correcto! Los bancos nunca te piden datos por mensaje. Si tienes duda, llama al banco." |

## Relationships

```
LessonRepository (abstract)
  ├── getAllLessons() → List<Lesson>
  └── getLessonById(id) → Lesson

MockLessonRepository (data, static + ARB)
  └── 5 lecciones hardcodeadas con textos de AppLocalizations

LessonProgressRepository (data, SharedPreferences)
  ├── isCompleted(lessonId) → bool
  ├── markCompleted(lessonId) → void
  ├── getConsecutiveRejections() → int
  ├── incrementRejections() → void
  └── resetRejections() → void

alertToLessonMap (domain, constante)
  └── Map<RiskRule, List<String>> — mapeo alerta → lecciones relevantes

SuggestionTrigger (efímero, in-memory)
  └── triggeredRules de la alerta resuelta de 002

LessonSuggestionProvider
  ├── Consume: pendingLessonTriggerProvider (SuggestionTrigger?)
  ├── Consume: lessonProgressRepository (completadas + rechazos)
  ├── Consume: lessonRepository (contenido)
  └── Produce: LessonSuggestion? (lección relevante no completada)

EasyModeHomeScreen (de 001)
  └── if suggestion != null → LessonSuggestionCard

LessonSuggestionCard
  ├── "Ver lección" → navega a /easy-mode/lessons/:lessonId
  └── "Ahora no" → incrementa rejections, descarta

LessonScreen
  ├── Texto de la lección (scroll)
  ├── TTS (de 004) lee el contenido
  ├── Controles: pausar (botón)
  └── PracticeQuestionWidget al final

PracticeQuestionWidget
  ├── Prompt (escenario)
  ├── 3+ opciones (botones)
  ├── Al responder: feedback + markCompleted()
  └── "Volver" al finalizar

FraudAlertScreen (de 002)
  └── Al resolver alerta → pendingLessonTriggerProvider.set(trigger)
```

## Reuse from Other Features

| Component | Source | How it's used in 011 |
|-----------|--------|---------------------|
| `TtsService`, `ttsServiceProvider` | 004 | Lee contenido de lecciones en voz alta |
| `RiskRule` enum | 002 | Mapeo alerta → lección relevante |
| `RiskAlert` | 002 | Trigger de sugerencia (triggeredRules) |
| `operationInProgressProvider` | 003 | Gate: no sugerir si hay operación en curso |
| `EasyModeHomeScreen` | 001 | Punto de inserción de LessonSuggestionCard |
| `AccessibleButton` | 001 (core) | Botones de opciones |
| Theme (Atkinson Hyperlegible) | 001 | Tipografía y paleta |

## Validation Rules (from spec)

1. **3 componentes** (FR-001): Cada lección tiene texto + audio + pregunta.
2. **< 1 minuto** (FR-002): Contenido ≤ 150 palabras.
3. **Sugerencia post-alerta** (FR-003, SC-001): Después de resolver alerta, mapeo por `RiskRule`.
4. **Nunca interrumpe** (FR-004, FR-005, SC-002): Solo post-operación. Checks `operationInProgressProvider`.
5. **"Ahora no" sin insistencia** (FR-006): Desaparece, incrementa contador.
6. **3 rechazos = no más sugerencias** (FR-006): `consecutiveRejections >= 3` → solo acceso manual.
7. **Lista accesible** (FR-007, FR-008): Desde ayuda/config. Muestra estado.
8. **Retroalimentación amable** (FR-009): Sin "Incorrecto"/"Error"/"Mal".
9. **Completada al responder** (FR-010): Correcta o incorrecta, se marca completada.
10. **No re-sugiere completadas** (FR-011): Filtro en LessonSuggestionProvider.
11. **Audio pausable** (FR-012): Botón pausa. Texto siempre visible.
12. **Accesibilidad** (FR-013): 48×48 dp, 4.5:1, Semantics, TalkBack.
13. **5 lecciones** (FR-014, FR-015): Los 5 temas del spec cubiertos.

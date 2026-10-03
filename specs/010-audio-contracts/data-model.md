# Data Model: Contratos Explicados en Audio (010-audio-contracts)

## Entities

### ContractSectionType (Tipo de sección)

Enum de las 4 secciones obligatorias de cada resumen. Dart puro. El orden define el orden de lectura TTS.

| Value | UI Label (ARB) | Description |
|-------|---------------|-------------|
| `whatYouAccept` | "Qué aceptas" | Lo que firma o acepta el usuario |
| `cost` | "Cuánto cuesta" | Costos, comisiones, tasas |
| `risks` | "Qué puede salir mal" | Riesgos y protecciones |
| `howToCancel` | "Cómo cancelar" | Proceso de cancelación o salida |

### ContractSection (Sección de contrato)

Una sección del resumen. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `type` | `ContractSectionType` | Tipo de sección | Non-null |
| `title` | `String` | Título localizado (de ARB) | Non-empty |
| `content` | `String` | Texto del resumen (lenguaje simple) | Non-empty, ≤ 15 palabras/oración |

### ContractSummary (Resumen de contrato)

Resumen completo de un contrato con sus 4 secciones. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `id` | `String` | Identificador del contrato | Non-empty |
| `title` | `String` | Nombre del contrato (localizado) | Non-empty |
| `sections` | `List<ContractSection>` | Las 4 secciones del resumen | Length == 4 |
| `fullContractParagraphs` | `List<String>` | Párrafos del contrato completo (simulado) | Non-empty |

### PlaybackSpeed (Velocidad de reproducción)

Enum de velocidades TTS. Dart puro.

| Value | Rate | UI Label (ARB) |
|-------|------|---------------|
| `normal` | `1.0` | "100%" |
| `slow` | `0.75` | "75%" |
| `slower` | `0.5` | "50%" |

Ciclo: `normal` → `slow` → `slower` → `normal`.

### TtsState (Estado del TTS)

Enum de estado de reproducción. Dart puro.

| Value | Description |
|-------|-------------|
| `idle` | Sin reproducir |
| `playing` | Leyendo sección activa |
| `paused` | Pausado por el usuario |
| `completed` | Terminó todas las secciones |

### ReviewSession (Sesión de revisión)

Estado efímero de la revisión en curso. Freezed, Dart puro. No se persiste.

| Field | Type | Default | Description | Validation |
|-------|------|---------|-------------|------------|
| `contractId` | `String` | — | ID del contrato siendo revisado | Non-empty |
| `sectionsHeard` | `Set<ContractSectionType>` | `{}` | Secciones leídas por TTS | Subset of enum |
| `currentSection` | `ContractSectionType?` | `null` | Sección actualmente en lectura | Nullable |
| `scrolledToEnd` | `bool` | `false` | Si el usuario scrolleó hasta el final | — |
| `speed` | `PlaybackSpeed` | `normal` | Velocidad de lectura actual | — |
| `ttsState` | `TtsState` | `idle` | Estado actual del TTS | — |

**Propiedad derivada**:
```dart
bool get reviewCompleted =>
    sectionsHeard.length == ContractSectionType.values.length ||
    scrolledToEnd;
```

`reviewCompleted` es el gate para habilitar el botón "Aceptar".

### ContractAcceptance (Aceptación de contrato)

Registro de que el usuario aceptó un contrato. Freezed, Dart puro.

| Field | Type | Description |
|-------|------|-------------|
| `contractId` | `String` | ID del contrato aceptado |
| `acceptedAt` | `DateTime` | Momento de aceptación |
| `reviewMethod` | `ReviewMethod` | Cómo completó la revisión |

### ReviewMethod (Método de revisión)

Enum de cómo el usuario completó la revisión.

| Value | Description |
|-------|-------------|
| `audio` | Escuchó las 4 secciones por TTS |
| `visual` | Leyó scrolleando hasta el final |

## Example Contracts (Static Data)

### Cuenta de ahorro (`savings_account`)

| Section | Content (ARB, lenguaje simple) |
|---------|-------------------------------|
| Qué aceptas | "Abres una cuenta de ahorro. El banco guarda tu dinero." |
| Cuánto cuesta | "No tiene costo mensual. Sacar dinero de otro banco cuesta un sol." |
| Qué puede salir mal | "Tu dinero está protegido. Si el banco cierra, el gobierno te devuelve hasta cien mil soles." |
| Cómo cancelar | "Puedes cerrar tu cuenta cuando quieras. Ve a una oficina o llama. No cobran por cerrarla." |

Full contract: 8 párrafos simulados de texto legal simplificado.

### Préstamo personal (`personal_loan`)

| Section | Content (ARB, lenguaje simple) |
|---------|-------------------------------|
| Qué aceptas | "El banco te presta dinero. Tú lo devuelves poco a poco cada mes." |
| Cuánto cuesta | "Pagas lo que pediste más un interés. El interés es quince por ciento al año." |
| Qué puede salir mal | "Si no pagas a tiempo, cobran una multa. También puede afectar tu historial." |
| Cómo cancelar | "Puedes pagar todo lo que debes de una vez. Llama al banco para pedir el monto exacto." |

Full contract: 10 párrafos simulados de texto legal simplificado.

## Relationships

```
ContractRepository (abstract)
  └── getContractSummary(id) → ContractSummary

MockContractRepository (data, static JSON + ARB)
  └── Loads from assets/contracts/*.json + AppLocalizations

ReviewSession (presentation, efímera)
  ├── contractId → ContractSummary
  ├── sectionsHeard → tracks TTS progress
  ├── scrolledToEnd → tracks visual progress
  ├── speed → applied to TtsService (de 004)
  └── reviewCompleted → gates AcceptButton

ContractSummaryScreen
  ├── ref.watch(contractReviewProvider) → ReviewSession
  ├── TtsPlaybackControls (pausar, repetir, velocidad)
  ├── AcceptButton (disabled until reviewCompleted)
  ├── "Ver contrato completo" → FullContractScreen
  └── "¿Tienes una pregunta?" → VoiceAssistant (004)

FullContractScreen
  ├── paragraphs from ContractSummary.fullContractParagraphs
  └── per-paragraph "Leer" button → TtsService.speak()

TtsService (de 004, reutilizado)
  ├── speak(text) → reproduce texto
  ├── stop() → detiene
  ├── pause() → pausa (si soportado)
  └── setSpeechRate(rate) → cambia velocidad
```

## Reuse from Other Features

| Component | Source | How it's used in 010 |
|-----------|--------|---------------------|
| `TtsService` | 004 | Lectura de secciones y párrafos |
| `ttsServiceProvider` | 004 | Provider para acceder al TTS |
| `AccessibleButton` | 001 (core) | Botones de controles y "Aceptar" |
| Theme (Atkinson Hyperlegible, palette) | 001 | Tipografía y colores |
| `VoiceAssistant` screen | 004 | "¿Tienes una pregunta?" navega al asistente |

## Validation Rules (from spec)

1. **4 secciones obligatorias** (FR-001, SC-001): Todo contrato tiene exactamente 4 secciones. `ContractSummary.sections.length == 4`.
2. **Lenguaje simple** (FR-001, SC-002): Cada oración ≤ 15 palabras, sin jerga financiera.
3. **Lectura automática** (FR-002, SC-003): Al abrir el resumen, TTS empieza a leer la sección 1.
4. **Controles disponibles** (FR-003): Pausar, repetir sección, velocidad (3 niveles).
5. **Botón "Aceptar" bloqueado** (FR-004, SC-005): `AcceptButton.enabled = reviewSession.reviewCompleted`.
6. **Doble vía** (FR-004): Audio completo (4 secciones oídas) O scroll al final habilitan "Aceptar".
7. **Contrato completo accesible** (FR-005, SC-006): Lectura por párrafo individual.
8. **Integración con 004** (FR-006): Preguntas via asistente de voz con contexto del contrato.
9. **Volumen bajo** (FR-007): Banner informativo al inicio.
10. **Accesibilidad** (SC-007, SC-008): Controles 48×48 dp, contraste 4.5:1, Semantics labels, TalkBack anuncia sección activa y estado de botón.

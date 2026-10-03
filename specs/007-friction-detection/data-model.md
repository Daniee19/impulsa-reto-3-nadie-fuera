# Data Model: Detección de Fricción (007-friction-detection)

## Entities

### FrictionType (Tipo de señal de fricción)

Enum de señales detectables. Dart puro.

| Value | Description | Threshold |
|-------|-------------|-----------|
| `repeatedBackNavigation` | Retroceder 3+ veces en el mismo flujo | 3 |
| `prolongedInactivity` | 20+ segundos sin interactuar en un paso | 20 s |
| `repeatedError` | 3+ errores del mismo tipo en el mismo campo | 3 |

### FrictionThresholds (Umbrales configurables)

Constantes inyectables para testing. No persisten. Dart puro.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `backNavigationCount` | `int` | `3` | Retrocesos antes de ofrecer ayuda |
| `inactivitySeconds` | `int` | `20` | Segundos de inactividad antes de ofrecer ayuda |
| `repeatedErrorCount` | `int` | `3` | Errores repetidos antes de ofrecer ayuda |

### FrictionSignal (Señal de fricción detectada)

Registro de una señal detectada. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `type` | `FrictionType` | Tipo de señal | Non-null |
| `flowId` | `String` | Identificador del flujo (ej: `pay-bill`) | Non-empty |
| `stepRoute` | `String` | Ruta del paso donde ocurrió | Non-empty |
| `stepName` | `String` | Nombre legible del paso (del observer de 003) | Non-empty |
| `occurrences` | `int` | Veces que ocurrió (retrocesos o errores contados) | >= threshold |
| `detectedAt` | `DateTime` | Momento de la detección | Non-null |

### FrictionOffer (Ofrecimiento de ayuda)

Estado del ofrecimiento mostrado al usuario. No es freezed — es el state del provider.

| Field | Type | Description |
|-------|------|-------------|
| `signal` | `FrictionSignal` | Señal que disparó el ofrecimiento |
| `status` | `FrictionOfferStatus` | Estado actual del ofrecimiento |

**Enum `FrictionOfferStatus`**:
| Value | Description |
|-------|-------------|
| `hidden` | No hay ofrecimiento visible |
| `showing` | Ofrecimiento visible en pantalla |
| `dismissed` | Usuario eligió "No, estoy bien" |
| `acceptedExplain` | Usuario eligió "Sí, explícame" (delega a 004 TTS) |
| `acceptedHuman` | Usuario eligió "Hablar con alguien" (delega a 003) |

**State transitions**:
```
hidden ──→ showing       (señal detectada, pantalla no excluida, no dismissed)
showing ──→ dismissed     (usuario toca "No, estoy bien")
showing ──→ acceptedExplain  (usuario toca "Sí, explícame")
showing ──→ acceptedHuman    (usuario toca "Hablar con alguien")
showing ──→ hidden        (usuario cambia de flujo/operación)
dismissed ──→ (terminal para esta señal+operación)
acceptedExplain ──→ hidden   (explicación TTS completada)
acceptedHuman ──→ hidden     (navegó a 003, overlay desaparece)
```

### FrictionContext (Contexto de fricción para 003)

Extensión del HelpContext de 003 con datos de fricción. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `signalType` | `FrictionType` | Qué tipo de fricción se detectó | Non-null |
| `occurrences` | `int` | Cuántas veces ocurrió (ej: "retrocedió 3 veces") | > 0 |
| `stepName` | `String` | Nombre legible del paso donde se trabó | Non-empty |
| `humanReadable` | `String` | Descripción para el asesor/familiar en español | Non-empty, ≤ 15 palabras |

**Generación de `humanReadable`**:
| FrictionType | Template |
|-------------|----------|
| `repeatedBackNavigation` | "Retrocedió {n} veces en {stepName}" |
| `prolongedInactivity` | "Estuvo sin interactuar en {stepName}" |
| `repeatedError` | "Cometió el mismo error {n} veces en {stepName}" |

### ExcludedScreenPatterns (Pantallas excluidas)

No es una entidad — es una constante en el detector.

| Pattern | Matches | Reason |
|---------|---------|--------|
| `/confirm$` (regex) | Todas las pantallas de confirmación | Confirmación de pago/transferencia |
| `fraud-alert` | `/easy-mode/fraud-alert` | Alerta del escudo antifraude |
| `assistant/consent` | `/easy-mode/assistant/consent` | Consentimiento de micrófono |
| `trusted-person/consent` | Consentimiento de persona de confianza | Consentimiento 006 |
| `/help/` | `/easy-mode/help/*` | Ya está en pantalla de ayuda |

## Relationships

```
NavigationObserver (de 003, core/)
  └── navigationContextProvider ──→ FrictionProvider (escucha cambios)
                                       ├── FrictionDetector (domain, Dart puro)
                                       │   ├── cuenta retrocesos por flujo
                                       │   ├── maneja timer de inactividad
                                       │   ├── cuenta errores por campo+tipo
                                       │   └── evalúa exclusiones de pantalla
                                       ├── FrictionOffer (state del overlay)
                                       │   └── FrictionOfferOverlay (widget)
                                       │       ├── "Sí, explícame" ──→ TTS de 004
                                       │       ├── "Hablar con alguien" ──→ 003 + FrictionContext
                                       │       └── "No, estoy bien" ──→ dismiss
                                       └── FrictionContext ──→ ContextCollector de 003
                                                                └── HelpContext enriquecido

operationInProgressProvider (de 003)
  └── datos de operación en curso para enriquecer FrictionContext

Providers de 001 (pay-bill, send-money)
  └── notifican errores de validación ──→ FrictionProvider.onValidationError()
```

## Reuse from Other Features

| Component | Source | How it's used in 007 |
|-----------|--------|---------------------|
| `NavigationObserver` | 003 (`core/router/`) | Fuente de datos de navegación: ruta actual, nombre de pantalla, detección de pops |
| `navigationContextProvider` | 003 | Provider que FrictionProvider escucha para detectar retrocesos y cambios de pantalla |
| `operationInProgressProvider` | 003 | Datos de operación en curso para enriquecer FrictionContext |
| `ContextCollector` | 003 (`domain/services/`) | Construye HelpContext seguro, se extiende para incluir FrictionContext |
| TTS service | 004 | Lee la explicación contextual cuando el usuario elige "Sí, explícame" |
| `HelpContactPickerScreen` | 003 | Destino de navegación cuando el usuario elige "Hablar con alguien" |
| ShellRoute con HelpFab | 003 | Se reutiliza para inyectar el FrictionOfferOverlay |

## Validation Rules (from spec)

1. **Solo en flujos activos** (FR-006): La detección solo opera dentro de flujos de pagar recibo y enviar dinero. No en pantalla principal, saldo ni configuración.
2. **Nunca en pantallas excluidas** (FR-003): Confirmacoón de pago, alertas de fraude, consentimientos.
3. **Un solo ofrecimiento** (FR-005): Si múltiples señales disparan a la vez, un solo overlay.
4. **No re-ofrecer** (FR-004): Después de "No, estoy bien", no vuelve a aparecer para esa señal + operación.
5. **Reset con interacción** (FR-007): El timer de inactividad se reinicia con cualquier toque/escritura/voz.
6. **Errores de voz no cuentan** (FR-009): Solo errores de validación de datos, no errores de reconocimiento de voz de 004.
7. **Contexto enriquecido** (FR-008): Cuando el usuario elige "Hablar con alguien", el HelpContext incluye tipo de fricción, paso y ocurrencias.
8. **Accesibilidad** (FR-010, FR-012): Overlay legible por TalkBack, contraste 4.5:1, áreas táctiles 48×48 dp, aparición anunciada por `SemanticsService.announce`.
9. **Lenguaje empático** (FR-011): Frases ≤ 15 palabras, sin jerga. Textos en ARB.

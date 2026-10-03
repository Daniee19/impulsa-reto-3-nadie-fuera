# Data Model: Auditoría de Accesibilidad para Lector de Pantalla (005-screen-reader-audit)

## Entities

Esta feature es transversal — no define entidades de dominio nuevas. Define utilities y estándares que aplican a las entidades existentes de 001-004.

### AmountToWords (Utilidad — no entidad)

Clase estática en `lib/core/a11y/amount_to_words.dart`. Dart puro.

| Method | Input | Output | Example |
|--------|-------|--------|---------|
| `convert(double)` | Monto en soles | Texto en español con moneda | `120.50` → `"ciento veinte soles con cincuenta céntimos"` |

**Reglas de conversión**:
| Input | Output |
|-------|--------|
| `0.00` | "cero soles" |
| `1.00` | "un sol" |
| `2.00` | "dos soles" |
| `0.01` | "un céntimo" |
| `0.50` | "cincuenta céntimos" |
| `50.00` | "cincuenta soles" |
| `120.50` | "ciento veinte soles con cincuenta céntimos" |
| `1000.00` | "mil soles" |
| `2350.00` | "dos mil trescientos cincuenta soles" |
| `2350.50` | "dos mil trescientos cincuenta soles con cincuenta céntimos" |

**Limitaciones del prototipo**: Rango 0 a 999,999. Números negativos no aplican (los montos siempre son positivos).

### Semantics Label Standards (Estándar — no entidad)

Convenciones de etiquetas para todas las pantallas:

| Elemento | Semantics label pattern | Example |
|----------|------------------------|---------|
| Botón de acción principal | Verbo + objeto | "Pagar recibo" |
| Botón de acción secundaria | Verbo + contexto | "Volver a la pantalla anterior" |
| Monto en pantalla | AmountToWords.convert(amount) | "ciento veinte soles" |
| Saldo de cuenta | "Saldo disponible: " + AmountToWords | "Saldo disponible: dos mil cuatrocientos cincuenta soles" |
| Estado de operación | "Estado: " + descripción | "Estado: pago realizado" |
| Campo de texto | Propósito del campo | "Escribe el monto a enviar" |
| Icono de acción | Acción, no icono | "Pagar recibo" (no "icono de billete") |
| Imagen decorativa | ExcludeSemantics | (no se lee) |
| Imagen informativa | Descripción de lo que comunica | "Operación exitosa" |

**Reglas**:
- ≤15 palabras por etiqueta (Principio VI).
- En español peruano neutral (Principio VII).
- Sin jerga técnica ("CTA", "validar", "autenticación" — prohibidos).
- Dos elementos adyacentes nunca tienen la misma etiqueta (FR-010).

### Screen Announce Messages (Mensajes — no entidad)

Mensajes enviados via `SemanticsService.announce` en transiciones:

| Evento | ARB key | Mensaje |
|--------|---------|---------|
| App abierta | `announceHomeScreen` | "Pantalla principal" |
| Ver saldo | `announceBalance` | "Tu saldo es {amount}" |
| Recibo pagado | `announcePaymentSuccess` | "Pago realizado. Pagaste {amount} al recibo de {service}" |
| Dinero enviado | `announceTransferSuccess` | "Dinero enviado. Enviaste {amount} a {name}" |
| Alerta de fraude | `announceFraudAlert` | "Alerta de seguridad. {riskMessage}" |
| Conectando ayuda | `announceHelpConnecting` | "Te estamos conectando con {name}" |
| Ayuda conectada | `announceHelpConnected` | "Conectado con {name}" |
| Familiar no responde | `announceHelpNoResponse` | "No pudimos comunicarte con {name}" |
| Asistente responde | `announceAssistantResponse` | "{response}" |
| Error de operación | `announceError` | "{errorMessage}" |

Los mensajes con parámetros (`{amount}`, `{name}`) usan `AmountToWords.convert()` para montos.

### Accessibility Audit Checklist (Documento — no entidad)

Estructura del guion de prueba manual en `docs/talkback_test_checklist.md`:

| Section | Content |
|---------|---------|
| Preparación | Activar TalkBack, cerrar ojos, timer 10 min |
| Flujo N | Pantalla → acción → qué debe oírse → campo para problemas |
| Resumen | Total de problemas encontrados, por gravedad |

**Flujos** (7 total):
1. Ver saldo (001)
2. Pagar recibo completo (001)
3. Enviar dinero completo (001)
4. Pedir ayuda con contexto (003)
5. Recibir alerta de fraude (002)
6. Usar asistente de voz (004)
7. Conectar con ayuda humana (003)

## Relationships

```
AmountToWords ──→ usado por Semantics labels en:
                  ├── 001: BalanceScreen, PayBillConfirmScreen, SendMoneyConfirmScreen, SuccessScreen
                  ├── 002: FraudAlertScreen (monto de la operación alertada)
                  ├── 003: HelpConnectingScreen (monto de operación en curso)
                  └── 004: OperationSummaryScreen (monto del resumen)

screenAnnounce() ──→ usado en transiciones de:
                     ├── 001: carga de home, resultado de saldo, éxito de pago/transferencia
                     ├── 002: aparición de alerta de fraude
                     ├── 003: conexión/desconexión de ayuda, fallback
                     └── 004: respuestas del asistente, resultado de operación

A11y tests ──→ verifican todas las pantallas de 001-004
TalkBack checklist ──→ cubre los 7 flujos principales
```

## Validation Rules (from spec)

1. **100% etiquetas** (FR-001, FR-002): Ningún elemento interactivo ni informativo sin Semantics label en español.
2. **Orden lógico** (FR-003): Título → información → acciones en cada pantalla.
3. **Montos en palabras** (FR-004, FR-005): Nunca "S/ 120", siempre "ciento veinte soles".
4. **Anuncios automáticos** (FR-006): Todo cambio de pantalla/estado se anuncia via SemanticsService.
5. **Sin gestos complejos** (FR-007): Todo completable con toque simple en área ≥48dp.
6. **Imágenes correctas** (FR-008): Decorativas excluidas, informativas con descripción.
7. **Iconos descriptivos** (FR-009): "Pagar recibo" no "icono de billete".
8. **Etiquetas únicas** (FR-010): No hay dos interactivos adyacentes con la misma etiqueta.
9. **Lenguaje simple** (FR-011): ≤15 palabras, sin jerga.
10. **Temporales duraderos** (FR-012): Toasts ≥5 segundos o no dependen de tiempo.

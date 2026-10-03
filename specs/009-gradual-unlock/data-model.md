# Data Model: Desbloqueo Gradual de Funciones (009-gradual-unlock)

## Entities

### ExtraFeature (Función extra)

Enum de funciones desbloqueables. Dart puro. El orden define la prioridad de propuesta (FR-006).

| Value | UI Label (ARB) | Description | Priority |
|-------|---------------|-------------|----------|
| `transactionHistory` | "Ver movimientos" | Lista de últimas transacciones ficticias | 1 (primero) |
| `mobileRecharge` | "Recargar celular" | Formulario de recarga con monto fijo | 2 |
| `qrPayment` | "Pagar con QR" | Simulación de escaneo y pago QR | 3 |

### FeatureState (Estado de una función extra)

Enum del ciclo de vida de una función extra.

| Value | Description |
|-------|-------------|
| `locked` | Bloqueada, no visible. Estado inicial. |
| `unlockedHidden` | Desbloqueada pero oculta por el usuario ("Volver a solo 4 acciones"). Reactivable sin cumplir condiciones. |
| `active` | Activa y visible en la pantalla principal. |

**State transitions**:
```
locked ──→ active              (usuario acepta propuesta "Sí, actívalo")
locked ──→ active              (usuario activa manualmente desde configuración después de practicar)
active ──→ unlockedHidden      (usuario elige "Volver a solo 4 acciones")
unlockedHidden ──→ active      (usuario reactiva desde configuración, FR-010)
```

`locked` → `unlockedHidden` no ocurre directamente. Siempre pasa por `active` primero.

### ConfidenceMetrics (Métricas de confianza)

Contadores que miden la confianza del usuario. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `successfulOpsWithoutHelp` | `int` | Operaciones exitosas completadas sin pedir ayuda | ≥ 0 |
| `practiceSessionsCompleted` | `int` | Sesiones de práctica (008) completadas | ≥ 0 |

**Umbrales de confianza** (fijos para prototipo):
| Metric | Threshold | Notes |
|--------|-----------|-------|
| `successfulOpsWithoutHelp` | 5 | Pagar recibo o enviar dinero sin tocar "Pedir ayuda" |
| `practiceSessionsCompleted` | 3 | Sesiones completas en 008 (entrar + hacer al menos 1 operación + salir) |

La confianza se alcanza cuando **cualquiera** de los umbrales se cumple (OR, no AND). El spec dice "5 operaciones exitosas sin pedir ayuda, **o** 3 sesiones de práctica."

### UnlockThresholds (Umbrales configurables)

Constantes inyectables para testing. Dart puro.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `opsWithoutHelp` | `int` | `5` | Operaciones sin ayuda para proponer |
| `practiceSessions` | `int` | `3` | Sesiones de práctica para proponer |
| `maxRejections` | `int` | `3` | Rechazos antes de dejar de proponer (FR-005) |

### UnlockProposal (Propuesta de desbloqueo)

Propuesta activa para mostrar al usuario. Freezed, Dart puro.

| Field | Type | Description | Validation |
|-------|------|-------------|------------|
| `feature` | `ExtraFeature` | Función propuesta | Non-null |

**No tiene estado interno** — el estado de la propuesta (mostrada, aceptada, rechazada) se maneja en el provider, no en la entidad.

### ExtraFeatureConfig (Configuración de función extra)

Metadata estática por función. Constante, no persistida.

| Field | Type | Description |
|-------|------|-------------|
| `feature` | `ExtraFeature` | Enum value |
| `nameKey` | `String` | ARB key del nombre |
| `descriptionKey` | `String` | ARB key de descripción (≤ 15 palabras) |
| `proposalMessageKey` | `String` | ARB key del mensaje de propuesta |
| `iconData` | `IconData` | Icono del botón |
| `route` | `String` | Ruta de go_router |

**Valores**:
| Feature | Proposal message | Route |
|---------|-----------------|-------|
| `transactionHistory` | "Ya manejas bien tus pagos. ¿Quieres ver tus movimientos?" | `/easy-mode/transactions` |
| `mobileRecharge` | "¿Quieres recargar tu celular desde la app?" | `/easy-mode/recharge` |
| `qrPayment` | "¿Quieres pagar con código QR?" | `/easy-mode/qr-payment` |

## Relationships

```
FeatureFlagRepository (SharedPreferences)
  ├── FeatureState per ExtraFeature (persiste)
  ├── ConfidenceMetrics (persiste)
  └── rejection counts per ExtraFeature (persiste)

UnlockEvaluator (domain, Dart puro)
  └── evaluate(metrics, states, rejections) → UnlockProposal?

EasyModeHomeScreen (de 001)
  ├── ref.watch(unlockProposalProvider) → UnlockProposalCard?
  ├── ref.watch(activeExtraFeaturesProvider) → ExtraFeaturesSection?
  └── 4 acciones principales (siempre)

Providers de 001 (pay-bill, send-money)
  └── al completar operación sin ayuda → featureFlagRepo.incrementOpsWithoutHelp()

PracticeSession provider (de 008)
  └── al completar sesión → featureFlagRepo.incrementPracticeSessions()

"Sí, actívalo" → featureFlagRepo.setState(feature, active)
"Practicar primero" → navega a 008 con función incluida
"No, por ahora no" → featureFlagRepo.incrementRejection(feature)
"Volver a solo 4 acciones" → featureFlagRepo.resetToBasicView()
Configuración → reactivar individual con toggle
```

## Reuse from Other Features

| Component | Source | How it's used in 009 |
|-----------|--------|---------------------|
| `EasyModeHomeScreen` | 001 | Se extiende para mostrar propuesta y sección extra |
| `AccountRepository`, etc. | 001 | Las funciones extra usan los mismos repos (ej: transactionHistory lee OperationRepository) |
| Estilo de botones (AccessibleButton) | 001 (core) | Botones extra usan misma estética accesible |
| Practice mode (ProviderScope override) | 008 | "Practicar primero" navega a 008 incluyendo función nueva |
| `navigationContextProvider` | 003 | Para tracking de "en qué pantalla pidió ayuda" (detectar flag helpRequested) |

## Validation Rules (from spec)

1. **Inicio con 4** (FR-001, SC-001): Todas las extras empiezan en `locked`. Un usuario nuevo ve exactamente 4 botones.
2. **Propuesta por confianza** (FR-002, SC-002): El evaluator solo propone si metrics cumplen algún umbral.
3. **Una por sesión** (FR-006): `proposalShownThisSession` flag en el provider, in-memory.
4. **3 rechazos = no más propuestas auto** (FR-005, SC-008): `rejections >= maxRejections` → skip en evaluator. Activación manual en config sigue disponible.
5. **Extras en sección secundaria** (FR-008, SC-006): Si hay extras activas, van en "Más funciones", nunca reemplazan las 4 primarias.
6. **Reversible siempre** (FR-009, FR-011): "Volver a solo 4 acciones" cambia active → unlockedHidden. Nunca elimina.
7. **Reactivable sin condiciones** (FR-010): unlockedHidden → active desde config, sin evaluator.
8. **Accesibilidad** (FR-007, FR-012): Botones extra 48×48 dp, contraste 4.5:1, TalkBack anuncia propuesta.
9. **Sin gamificación**: Sin puntos, niveles ni insignias.

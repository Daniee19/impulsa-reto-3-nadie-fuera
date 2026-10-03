# Data Model: Modo Práctica (008-practice-mode)

## Entities

### PracticeSession (Sesión de práctica)

Estado de la sesión de práctica activa. No es freezed — es el state del provider. Efímero, no persiste.

| Field | Type | Description |
|-------|------|-------------|
| `active` | `bool` | Si el modo práctica está activo |
| `guideEnabled` | `bool` | Si la guía paso a paso está activada |
| `startedAt` | `DateTime?` | Momento en que se activó la sesión |

**State transitions**:
```
inactive ──→ active (guideEnabled: pending)   (usuario toca "Practicar")
active (pending) ──→ active (guideEnabled: true)   (usuario elige "Sí, guíame")
active (pending) ──→ active (guideEnabled: false)  (usuario elige "No, ya sé")
active ──→ inactive                           (usuario toca "Salir de práctica")
active ──→ inactive                           (app se cierra, FR-013)
```

### PracticeGuideStep (Instrucción de la guía)

Instrucción predefinida por paso de flujo. No es una entidad persistida — es un valor constante en un mapa.

| Field | Type | Description |
|-------|------|-------------|
| `routePattern` | `String` | Patrón de ruta que activa esta instrucción |
| `instruction` | `String` | Texto de la instrucción (ARB key) |
| `stepNumber` | `int` | Número de paso en el flujo |
| `totalSteps` | `int` | Total de pasos del flujo |

**Instrucciones predefinidas**:
| Route | Step | Instruction (ARB) |
|-------|------|-------------------|
| `/practice/balance` | 1/1 | "Aquí ves tu saldo de práctica." |
| `/practice/pay-bill` | 1/3 | "Elige el recibo que quieres pagar." |
| `/practice/pay-bill/:id/confirm` | 2/3 | "Revisa el monto y toca Confirmar práctica." |
| `/practice/success` (payment) | 3/3 | "¡Listo! Pagaste con dinero de prueba." |
| `/practice/send-money` | 1/3 | "Elige a quién enviarle dinero." |
| `/practice/send-money/confirm` | 2/3 | "Revisa los datos y toca Confirmar práctica." |
| `/practice/success` (transfer) | 3/3 | "¡Listo! Enviaste dinero de prueba." |

Todas las instrucciones ≤ 15 palabras, en ARB.

### PracticeData (Datos ficticios de práctica)

No es una entidad nueva — reutiliza las entidades de 001 (Account, Bill, SavedContact, Operation) con datos ficticios distintos. Definidos como constantes en los repositorios de práctica.

**Datos ficticios**:

| Entity | Practice data |
|--------|--------------|
| Account | "Cuenta de práctica", ****0000, S/ 5,000.00 |
| Bills | Luz ficticia (S/ 95.00), Agua ficticia (S/ 38.00), Teléfono ficticio (S/ 55.00) |
| Contacts | Ana García (****1111), Pedro Ruiz (****2222), Lucía Torres (****3333) |
| Operations | Lista vacía al iniciar |

**Nota**: Los nombres de contactos son genéricos, no relacionados con los datos reales del usuario (spec: "nombres inventados").

### PracticeConfirmation (Confirmación sin biometría)

No es una entidad — es un override del comportamiento de confirmación.

| Aspect | Real mode | Practice mode |
|--------|-----------|---------------|
| Button text | "Confirmar con huella" | "Confirmar práctica" |
| Biometric check | `local_auth` | Siempre exitoso |
| Effect | Muta repos reales | Muta repos práctica (aislados) |

### PracticeRiskEngine (Motor de riesgo simulado)

No es una entidad nueva — implementa la interfaz `RiskEngine` de 002 con lógica simplificada.

| Condition | Triggers |
|-----------|----------|
| `amount > 500` | `RiskAlert(triggeredRules: {unusualAmount})` |
| everything else | `null` (no alert) |

Umbral fijo a S/ 500 (spec: "para que ocurra al menos una vez"). Los recibos ficticios son < S/ 100, así que solo se triggeerea al enviar dinero con monto alto.

## Relationships

```
EasyModeHomeScreen (de 001)
  └── Botón "Practicar" ──→ PracticeEntryScreen
                              ├── "¿Quieres guía?" → PracticeSession.guideEnabled
                              └── ProviderScope override
                                    ├── PracticeAccountRepository (implements AccountRepository)
                                    ├── PracticeBillRepository (implements BillRepository)
                                    ├── PracticeContactRepository (implements ContactRepository)
                                    ├── PracticeOperationRepository (implements OperationRepository)
                                    ├── PracticeRiskEngine (implements RiskEngine)
                                    ├── PracticeBiometricAuth (always succeeds)
                                    └── practiceTheme (verde en vez de azul)

                              Screens reutilizadas de 001:
                              ├── BalanceScreen ← PracticeAccountRepository
                              ├── PayBillScreen ← PracticeBillRepository
                              ├── PayBillConfirmScreen ← "Confirmar práctica"
                              ├── SendMoneyScreen ← PracticeContactRepository
                              ├── SendMoneyConfirmScreen ← "Confirmar práctica"
                              └── OperationSuccessScreen ← + "Practicar otra vez"

PracticeBanner ──→ visible en todas las pantallas (via ShellRoute)
PracticeGuideOverlay ──→ visible si guideEnabled (via ShellRoute)
  └── lee navigationContextProvider (de 003) para saber en qué paso está
```

## Reuse from Other Features

| Component | Source | How it's used in 008 |
|-----------|--------|---------------------|
| `AccountRepository` interface | 001 | Implementada por `PracticeAccountRepository` |
| `BillRepository` interface | 001 | Implementada por `PracticeBillRepository` |
| `ContactRepository` interface | 001 | Implementada por `PracticeContactRepository` |
| `OperationRepository` interface | 001 | Implementada por `PracticeOperationRepository` |
| All screens (Balance, PayBill, SendMoney, etc.) | 001 | Reutilizadas sin modificación, reciben datos del repo override |
| `RiskEngine` interface | 002 | Implementada por `PracticeRiskEngine` (umbral S/ 500) |
| `FraudAlertScreen` | 002 | Reutilizada sin modificación |
| `navigationContextProvider` | 003 | Leído por `PracticeGuideOverlay` para instrucciones por paso |
| TTS service | 004 | Anuncia entrada/salida del modo práctica |
| `app_theme.dart` (ThemeData) | 001 | Base para `practiceTheme()` (copyWith verde) |

## Validation Rules (from spec)

1. **Aislamiento total** (FR-006, SC-001): Ninguna operación en modo práctica toca los repos reales. Garantizado por ProviderScope override + test de aislamiento.
2. **Indicador permanente** (FR-003, SC-002): PracticeBanner visible en 100% de las pantallas de práctica.
3. **Cambio visual** (FR-004): Color verde distinguible del azul real, contraste 4.5:1.
4. **Sin biometría** (FR-007): "Confirmar práctica" reemplaza huella/PIN.
5. **Guía opcional** (FR-008): Pregunta antes de cada acción. Instrucciones ≤ 15 palabras.
6. **Alerta simulada** (FR-010): PracticeRiskEngine activa alerta al enviar > S/ 500.
7. **No persiste** (FR-013): PracticeSession se destruye al cerrar la app (in-memory).
8. **Reiniciable** (FR-014): Reset restaura saldo y recibos ficticios al estado inicial.
9. **Accesibilidad** (FR-015, FR-016): TalkBack anuncia modo práctica al entrar, en cada pantalla, y al salir. Contraste, áreas táctiles, labels.
10. **Sin gamificación** (assumption): Sin puntuación, niveles ni insignias.

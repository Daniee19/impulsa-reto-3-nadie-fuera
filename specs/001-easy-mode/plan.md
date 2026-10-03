# Implementation Plan: Modo Fácil

**Branch**: `001-easy-mode` | **Date**: 2026-10-02 | **Spec**: `specs/001-easy-mode/spec.md`

**Input**: Feature specification from `/specs/001-easy-mode/spec.md`

## Summary

Pantalla principal simplificada para adultos mayores con 4 acciones (ver saldo, pagar recibo, enviar dinero, pedir ayuda), cada una completable en máximo 3 pasos. Confirmación explícita antes de mover dinero. Datos simulados con repositorios en memoria detrás de interfaces abstractas. Esta feature establece la estructura base del proyecto: core (tema accesible, router, l10n, a11y helpers) y el patrón de feature module que reutilizarán las demás features.

## Technical Context

**Language/Version**: Flutter stable 3.x / Dart 3 (null safety), SDK ^3.13.4

**Primary Dependencies**:
| Paquete | Uso | Licencia | Verificado |
|---------|-----|----------|------------|
| `flutter_riverpod` | Estado | MIT | pub.dev ✅ |
| `riverpod_annotation` | Codegen de providers | MIT | pub.dev ✅ |
| `riverpod_generator` | Generador (dev) | MIT | pub.dev ✅ |
| `go_router` | Navegación | BSD-3 | pub.dev ✅ |
| `freezed_annotation` | Anotaciones modelos | MIT | pub.dev ✅ |
| `freezed` | Generador modelos (dev) | MIT | pub.dev ✅ |
| `json_annotation` | Anotaciones JSON | BSD-3 | pub.dev ✅ |
| `json_serializable` | Generador JSON (dev) | BSD-3 | pub.dev ✅ |
| `build_runner` | Code generation (dev) | BSD-3 | pub.dev ✅ |
| `google_fonts` | Atkinson Hyperlegible | Apache-2.0 | pub.dev ✅ |
| `intl` | Localización | BSD-3 | pub.dev ✅ |
| `flutter_localizations` | Soporte l10n (SDK) | BSD-3 | Flutter SDK ✅ |
| `very_good_analysis` | Linter (dev) | MIT | pub.dev ✅ |
| `accessibility_tools` | Auditoría a11y (dev) | MIT | pub.dev ✅ |

Todas las licencias son MIT, BSD-3 o Apache-2.0 — conforme con Principio II de la constitución y la tabla del PDF de licencias.

**Storage**: Repositorios en memoria (datos simulados). Sin base de datos, sin backend real. Interfaces abstractas en dominio permiten swap a API real sin tocar UI.

**Testing**: `flutter_test` — widget tests con `androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`; unit tests para dominio; integration tests por flujo crítico.

**Target Platform**: Android first (minSdk 26)

**Project Type**: Mobile app (Flutter)

**Performance Goals**: 60 fps en todas las pantallas. Transiciones suaves.

**Constraints**: WCAG 2.2 AA obligatorio. Datos ficticios. Sin conexión a banco real. Interfaz en español peruano neutro.

**Scale/Scope**: ~8 pantallas (home + 4 flujos con sub-pantallas). Prototipo de hackathon para 4 semanas.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Notas |
|-----------|--------|-------|
| I. Accessibility First | ✅ PASS | Spec cubre: 48dp targets, 18/28sp texto, 4.5:1 contraste, Semantics labels, max 4 acciones por pantalla, sin dependencia de gestos/color/imágenes, anuncios de estado |
| II. Stack & Dependency Governance | ✅ PASS | Todas las dependencias listadas tienen licencia MIT/BSD/Apache. Linter cambia de `flutter_lints` a `very_good_analysis` per constitución |
| III. Clean Architecture by Feature | ✅ PASS | Estructura `lib/features/easy_mode/{domain,data,presentation}` + `lib/core/` |
| IV. Security & Privacy | ✅ PASS | Sin secretos (datos mock). Sin datos reales. Sin credenciales. |
| V. Testing & Quality Gates | ✅ PASS | Plan incluye widget tests a11y, unit tests dominio ≥80%, integration tests por flujo |
| VI. UX for Cognitive Accessibility | ✅ PASS | Spec exige: frases ≤15 palabras, sin jerga, confirmación antes de mover dinero, errores explicativos |
| VII. Code Style & Localization | ✅ PASS | ARB en español, `very_good_analysis`, Conventional Commits, `snake_case` archivos, `PascalCase` clases |

**Resultado**: Todos los gates pasan. No hay violaciones que justificar.

**Nota**: El proyecto actual usa `flutter_lints` — se debe migrar a `very_good_analysis` como parte del setup base.

## Project Structure

### Documentation (this feature)

```text
specs/001-easy-mode/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (repository interfaces)
└── tasks.md             # Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart            # Tema accesible global (Atkinson Hyperlegible, 18/28sp, alto contraste)
│   ├── router/
│   │   └── app_router.dart           # go_router config con rutas del modo fácil
│   ├── l10n/
│   │   ├── arb/
│   │   │   └── app_es.arb            # Strings en español peruano
│   │   └── l10n.dart                 # Export de generated localizations
│   ├── a11y/
│   │   └── a11y_helpers.dart         # SemanticsService.announce wrapper, constantes a11y
│   └── presentation/
│       └── widgets/
│           ├── accessible_button.dart    # Botón accesible reutilizable (≥48dp, semantics)
│           ├── confirmation_screen.dart  # Pantalla de confirmación genérica
│           └── error_message.dart        # Widget de error en lenguaje sencillo
├── features/
│   └── easy_mode/
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── account.dart          # Cuenta (freezed)
│       │   │   ├── bill.dart             # Recibo (freezed)
│       │   │   ├── saved_contact.dart    # Contacto guardado (freezed)
│       │   │   └── operation.dart        # Operación completada (freezed)
│       │   └── repositories/
│       │       ├── account_repository.dart    # Interfaz abstracta
│       │       ├── bill_repository.dart       # Interfaz abstracta
│       │       ├── contact_repository.dart    # Interfaz abstracta
│       │       └── operation_repository.dart  # Interfaz abstracta
│       ├── data/
│       │   └── repositories/
│       │       ├── mock_account_repository.dart
│       │       ├── mock_bill_repository.dart
│       │       ├── mock_contact_repository.dart
│       │       └── mock_operation_repository.dart
│       └── presentation/
│           ├── providers/
│           │   ├── account_provider.dart
│           │   ├── bill_provider.dart
│           │   ├── contact_provider.dart
│           │   └── operation_provider.dart
│           ├── screens/
│           │   ├── easy_mode_home_screen.dart     # 4 botones grandes
│           │   ├── balance_screen.dart            # Ver saldo (1 paso)
│           │   ├── pay_bill_screen.dart           # Lista de recibos
│           │   ├── pay_bill_confirm_screen.dart   # Confirmación pago
│           │   ├── send_money_screen.dart         # Selección contacto + monto
│           │   ├── send_money_confirm_screen.dart # Confirmación envío
│           │   ├── help_screen.dart               # Opciones de ayuda
│           │   └── operation_success_screen.dart  # Resultado exitoso/fallido
│           └── widgets/
│               └── action_card.dart               # Tarjeta de acción grande para home
├── app.dart              # MaterialApp.router con ProviderScope, tema, l10n
└── main.dart             # runApp entry point

test/
├── core/
│   └── theme/
│       └── app_theme_test.dart
└── features/
    └── easy_mode/
        ├── domain/
        │   └── entities/             # Unit tests para entidades
        └── presentation/
            └── screens/
                ├── easy_mode_home_screen_test.dart    # Widget test + a11y guidelines
                ├── balance_screen_test.dart
                ├── pay_bill_flow_test.dart
                ├── send_money_flow_test.dart
                └── help_screen_test.dart

integration_test/
└── easy_mode_flows_test.dart         # Integration tests: saldo, pago, transferencia
```

**Structure Decision**: Clean architecture por feature según Principio III de la constitución. `lib/core/` contiene la infraestructura compartida (tema, router, l10n, a11y). `lib/features/easy_mode/` contiene el feature module completo con domain → data → presentation. Los widgets accesibles reutilizables van en `lib/core/presentation/widgets/` porque los reutilizarán otras features.

## Complexity Tracking

No hay violaciones que justificar. Todos los gates de la constitución pasan.

# Implementation Plan: Persona de Confianza con Permisos Limitados

**Branch**: `006-trusted-person` | **Date**: 2026-10-02 | **Spec**: `specs/006-trusted-person/spec.md`

**Input**: Feature specification from `/specs/006-trusted-person/spec.md`

## Summary

Registro y gestión de una persona de confianza con permisos granulares (avisos de seguridad, pedidos de ayuda, ayudar a configurar). Los datos sensibles (nombre, teléfono, consentimientos) se persisten con `flutter_secure_storage`. Las notificaciones al familiar son simuladas. Esta feature expone un servicio (`TrustedPersonRepository` + providers) que consumen 002-fraud-shield y 003-contextual-human-help para decidir si muestran la opción del familiar. Reutiliza la arquitectura establecida en 001-easy-mode.

## Technical Context

**Language/Version**: Flutter stable 3.x / Dart 3 (null safety), SDK ^3.13.4

**Primary Dependencies** (nuevas respecto a 001):
| Paquete | Uso | Licencia | Verificado |
|---------|-----|----------|------------|
| `flutter_secure_storage` | Persistir datos del familiar y consentimientos | BSD-3 | pub.dev ✅ |

Paquetes ya establecidos en 001 (reutilizados): `flutter_riverpod`, `riverpod_annotation`, `go_router`, `freezed`, `google_fonts`, `intl`, `very_good_analysis`, `accessibility_tools`.

**Storage**: `flutter_secure_storage` para datos de la persona de confianza (nombre, teléfono, permisos, consentimientos). Es el mecanismo exigido por la constitución (Principio IV) para credenciales y datos sensibles. Los datos del familiar incluyen teléfono personal, que califica como dato sensible bajo Ley 29733.

**Testing**: Unit tests para dominio (entidades, validaciones). Widget tests con guidelines a11y para pantallas de registro/edición/permisos. Integration test para flujo completo de registro → activar permisos → verificar que 002/003 responden.

**Target Platform**: Android first (minSdk 26)

**Project Type**: Feature module dentro de la app Flutter existente

**Constraints**: Datos ficticios. Lado del familiar simulado. Una sola persona de confianza por usuario. Ley 29733 requiere consentimiento granular.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Notas |
|-----------|--------|-------|
| I. Accessibility First | ✅ PASS | FR-012 exige 48dp, 4.5:1 contraste, etiquetas TalkBack. Pantallas de registro siguen el patrón de una pregunta por pantalla (Carmen). Max 4 acciones en configuración |
| II. Stack & Dependency Governance | ✅ PASS | `flutter_secure_storage` BSD-3 — aprobada por constitución y listada en PDF de licencias. Registrar en THIRD_PARTY_LICENSES.md |
| III. Clean Architecture by Feature | ✅ PASS | `lib/features/trusted_person/{domain,data,presentation}`. Providers de dominio consumidos por 002/003 vía imports de la interfaz |
| IV. Security & Privacy | ✅ PASS | Datos sensibles (teléfono) en `flutter_secure_storage`. Consentimiento granular por permiso (FR-013, Ley 29733). Familiar no ve saldo/movimientos (FR-004). Familiar no ejecuta operaciones (FR-005) |
| V. Testing & Quality Gates | ✅ PASS | Unit tests dominio ≥80%, widget tests a11y, integration test flujo completo |
| VI. UX for Cognitive Accessibility | ✅ PASS | Frases ≤15 palabras. Explicación de cada permiso en una línea. Confirmación antes de cambiar/quitar persona de confianza. Patrón sugerencia-aprobación |
| VII. Code Style & Localization | ✅ PASS | Textos en ARB, `very_good_analysis`, snake_case |

**Resultado**: Todos los gates pasan. Sin violaciones.

## Project Structure

### Documentation (this feature)

```text
specs/006-trusted-person/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── trusted-person-service.md
└── tasks.md             # (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/trusted_person/
├── domain/
│   ├── entities/
│   │   ├── trusted_person.dart           # Persona de confianza (freezed)
│   │   ├── trusted_permission.dart       # Enum + metadata de permisos
│   │   ├── consent_record.dart           # Registro de consentimiento (freezed)
│   │   └── config_suggestion.dart        # Sugerencia de configuración (freezed)
│   └── repositories/
│       ├── trusted_person_repository.dart # Interfaz abstracta — EL SERVICIO QUE CONSUMEN 002/003
│       └── config_suggestion_repository.dart
├── data/
│   └── repositories/
│       ├── secure_storage_trusted_person_repository.dart  # Implementación con flutter_secure_storage
│       └── mock_config_suggestion_repository.dart
└── presentation/
    ├── providers/
    │   ├── trusted_person_provider.dart       # Provider global, consumido por 002/003
    │   └── config_suggestion_provider.dart
    ├── screens/
    │   ├── trusted_person_setup_screen.dart   # Pantalla "Mi persona de confianza" (entry point)
    │   ├── trusted_person_register_screen.dart # Nombre + teléfono
    │   ├── trusted_person_permissions_screen.dart # 3 permisos con toggles
    │   ├── trusted_person_detail_screen.dart  # Ver/editar persona registrada
    │   ├── trusted_person_change_screen.dart  # Confirmar cambio
    │   ├── trusted_person_remove_screen.dart  # Confirmar quitar
    │   └── config_suggestion_screen.dart      # Ver sugerencia pendiente
    └── widgets/
        └── permission_toggle.dart            # Toggle de permiso con explicación

test/features/trusted_person/
├── domain/
│   ├── entities/
│   │   └── trusted_person_test.dart
│   └── repositories/                        # Contract tests
└── presentation/
    └── screens/
        ├── trusted_person_register_screen_test.dart
        ├── trusted_person_permissions_screen_test.dart
        └── config_suggestion_screen_test.dart

integration_test/
└── trusted_person_flow_test.dart
```

**Cómo consumen 002 y 003 este servicio**:
```
002-fraud-shield y 003-contextual-human-help importan:
  - TrustedPersonRepository (interfaz) para consultar si hay persona registrada
  - TrustedPermission (enum) para verificar permisos activos
  - trustedPersonProvider (Riverpod) para reactividad

Ejemplo en 002:
  final person = ref.watch(trustedPersonProvider);
  if (person != null && person.hasPermission(TrustedPermission.securityAlerts)) {
    // mostrar opción "Consultar a mi persona de confianza"
  }
```

**Structure Decision**: Feature module en `lib/features/trusted_person/` siguiendo el patrón de 001-easy-mode. El servicio público es la interfaz `TrustedPersonRepository` + el provider `trustedPersonProvider`, que otros features importan desde `domain/repositories/` y `presentation/providers/`.

## Complexity Tracking

No hay violaciones que justificar.

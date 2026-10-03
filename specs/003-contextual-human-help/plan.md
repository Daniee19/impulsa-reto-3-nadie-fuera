# Implementation Plan: Ayuda Humana con Contexto

**Branch**: `003-contextual-human-help` | **Date**: 2026-10-02 | **Spec**: `specs/003-contextual-human-help/spec.md`

**Input**: Feature specification from `/specs/003-contextual-human-help/spec.md`

## Summary

Botón "Pedir ayuda" global visible en todas las pantallas. Al tocar, el usuario elige a quién contactar (persona de confianza o asesor del banco) y por qué canal (llamada, chat, videollamada con intérprete). El sistema captura automáticamente el contexto real de la sesión (pantalla actual, paso en el flujo, operación en curso) usando un observer de go_router y un provider de Riverpod, y lo envía junto con la solicitud de ayuda. Las conexiones son simuladas, pero el contexto es real. Reemplaza el botón "Pedir ayuda" simulado de 001-easy-mode (US4).

## Technical Context

**Language/Version**: Flutter stable 3.x / Dart 3 (null safety), SDK ^3.13.4

**Primary Dependencies**: Ninguna nueva. Reutiliza todo de 001-easy-mode. Consume `trustedPersonProvider` de 006-trusted-person.

**Storage**: Consentimiento de contexto gestionado por 006-trusted-person (el permiso `helpRequests` ya cubre esta funcionalidad). El paquete de contexto es efímero (in-memory, no se persiste).

**Testing**: Unit tests para el servicio de contexto (Dart puro). Widget tests con a11y para pantallas de ayuda y botón global. Integration test: pedir ayuda en medio de un flujo → contexto correcto → volver sin perder datos.

**Target Platform**: Android first (minSdk 26)

**Project Type**: Feature module dentro de la app Flutter existente

**Constraints**: Conexiones simuladas. Contexto real. Consentimiento obligatorio para familiar (Ley 29733). Nunca enviar datos sensibles en el contexto.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Notas |
|-----------|--------|-------|
| I. Accessibility First | ✅ PASS | Botón de ayuda 48dp, 4.5:1, TalkBack en todas las pantallas. Videollamada con intérprete LSP (Ley 29973). Announce al recibir foco |
| II. Stack & Dependency Governance | ✅ PASS | Sin dependencias nuevas. go_router observer es API nativa de go_router |
| III. Clean Architecture by Feature | ✅ PASS | Contexto en `domain/services/`. Pantallas en `presentation/`. Cross-feature via provider de 006 |
| IV. Security & Privacy | ✅ PASS | FR-016: contexto nunca incluye contraseñas/PIN/biométricos/cuentas completas. Consentimiento explícito para familiar (Ley 29733). Asesor no requiere consentimiento adicional (relación contractual) |
| V. Testing & Quality Gates | ✅ PASS | Unit tests contexto. Widget tests a11y. Integration test flujo completo |
| VI. UX for Cognitive Accessibility | ✅ PASS | ≤15 palabras. Sin jerga. Progreso preservado al volver de ayuda. Máximo 2 toques para pedir ayuda |
| VII. Code Style & Localization | ✅ PASS | Textos en ARB. snake_case. Conventional Commits |

**Resultado**: Todos los gates pasan.

## Project Structure

### Documentation (this feature)

```text
specs/003-contextual-human-help/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── context-service-contract.md
└── tasks.md             # (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/features/contextual_help/
├── domain/
│   ├── entities/
│   │   ├── help_context.dart             # Paquete de contexto (freezed)
│   │   ├── help_channel.dart             # Enum de canales (call, chat, video)
│   │   └── help_request.dart             # Solicitud completa (freezed)
│   ├── services/
│   │   └── context_collector.dart        # Recolecta contexto real — Dart puro
│   └── repositories/
│       └── help_session_repository.dart  # Interfaz para sesiones de ayuda simuladas
├── data/
│   └── repositories/
│       └── mock_help_session_repository.dart  # Simulación de conexiones
└── presentation/
    ├── providers/
    │   ├── navigation_context_provider.dart   # Observer de go_router + provider de estado
    │   ├── help_context_provider.dart         # Construye HelpContext completo
    │   └── help_session_provider.dart         # Gestiona sesión de ayuda simulada
    ├── screens/
    │   ├── help_contact_picker_screen.dart    # Elegir a quién contactar
    │   ├── help_channel_picker_screen.dart    # Elegir canal (llamada/chat/video)
    │   ├── help_connecting_screen.dart        # "Te estamos conectando..."
    │   └── help_fallback_screen.dart          # Familiar no respondió, ofrecer asesor
    └── widgets/
        └── help_fab.dart                     # Botón flotante global "Pedir ayuda"

lib/core/router/
└── navigation_observer.dart                  # GoRouterObserver que trackea ruta actual

test/features/contextual_help/
├── domain/
│   └── services/
│       └── context_collector_test.dart       # Unit tests del colector (Dart puro)
└── presentation/
    └── screens/
        ├── help_contact_picker_screen_test.dart
        └── help_channel_picker_screen_test.dart

integration_test/
└── contextual_help_flow_test.dart
```

**Botón de ayuda global**: `HelpFab` es un `FloatingActionButton` incluido en el `Scaffold` de todas las pantallas del Modo Fácil via un wrapper o directamente en cada screen. Siempre visible, 48dp, con Semantics label "Pedir ayuda".

**Integración con 001**: Reemplaza el `HelpScreen` simulado de 001-easy-mode (US4). Las rutas de help se anidam bajo `/easy-mode/help/`.

**Integración con 006**: Consulta `trustedPersonProvider` para mostrar/ocultar opción del familiar y verificar permiso `helpRequests`.

## Complexity Tracking

No hay violaciones que justificar.

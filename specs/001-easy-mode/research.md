# Research: Modo Fácil (001-easy-mode)

## R1: Riverpod con codegen en clean architecture

**Decision**: Usar `@riverpod` annotation (riverpod_generator) para todos los providers. Los providers del feature viven en `presentation/providers/` y reciben las interfaces de repositorio via `ref.watch`.

**Rationale**: El codegen elimina boilerplate (`StateNotifierProvider`, `FutureProvider` manual) y el compilador valida los tipos. La constitución lo exige explícitamente (Principio II: "flutter_riverpod con riverpod_annotation (codegen)").

**Patrón de inyección**:
- Un provider global por repositorio en `lib/features/easy_mode/presentation/providers/` que expone la interfaz abstracta y se overridea en `ProviderScope` con la implementación mock.
- Los providers de pantalla dependen solo de la interfaz, nunca de la implementación concreta.

**Alternatives considered**:
- Providers manuales sin codegen: más boilerplate, menos type-safe. Descartado por la constitución.
- `setState` en widgets: solo permitido en widgets visuales puros de hoja (Principio II).

## R2: go_router para navegación del Modo Fácil

**Decision**: Rutas declarativas con `GoRouter`. Ruta base `/easy-mode` con sub-rutas para cada flujo.

**Rationale**: `go_router` (BSD-3) es el paquete exigido por la constitución. Soporta deep linking, rutas nombradas, y el patrón de sub-rutas anidadas necesario para los flujos de 3 pasos.

**Estructura de rutas**:
```
/easy-mode                          → EasyModeHomeScreen
/easy-mode/balance                  → BalanceScreen
/easy-mode/pay-bill                 → PayBillScreen (lista)
/easy-mode/pay-bill/:billId/confirm → PayBillConfirmScreen
/easy-mode/send-money               → SendMoneyScreen (contacto + monto)
/easy-mode/send-money/confirm       → SendMoneyConfirmScreen
/easy-mode/help                     → HelpScreen
/easy-mode/success                  → OperationSuccessScreen
```

**Navegación "Volver"**: `context.pop()` preserva el estado del flujo porque los datos se mantienen en el provider (no en el widget). FR-010 cumplido.

**Alternatives considered**:
- Navigator 2.0 directo: más verbose, sin API declarativa. go_router lo abstrae.
- auto_route: requiere dependencia adicional no listada en constitución ni PDF.

## R3: Modelos freezed para entidades de dominio

**Decision**: Cada entidad de dominio es una clase `@freezed` en `domain/entities/`. Dart puro, sin imports de Flutter ni de la capa data.

**Rationale**: `freezed` (MIT) genera `==`, `hashCode`, `copyWith`, `toString` y pattern matching. La constitución lo exige (Principio II). Las entidades son inmutables y autodocumentadas.

**Patrón**: `@freezed` + `@JsonSerializable` para que las entidades puedan serializarse si se necesita persistencia futura, aunque para el prototipo los datos son in-memory.

**Alternatives considered**:
- Clases Dart manuales con `==` override: propenso a errores, más código. Descartado.
- `equatable`: redundante si ya se usa freezed.

## R4: Localización con ARB

**Decision**: Usar `flutter_localizations` + `intl` con archivos ARB en `lib/core/l10n/arb/`. Un solo locale por ahora: `es` (español peruano neutro).

**Rationale**: La constitución prohíbe hard-coded strings en widgets (Principio VII). ARB es el mecanismo estándar de Flutter para l10n. Un solo archivo `app_es.arb` cubre todo el Modo Fácil.

**Configuración en pubspec.yaml**:
```yaml
flutter:
  generate: true
```
Con `l10n.yaml`:
```yaml
arb-dir: lib/core/l10n/arb
template-arb-file: app_es.arb
output-localization-file: app_localizations.dart
```

**Convención de claves ARB**: `featureName_screenName_elementDescription`, ej: `easyMode_home_checkBalanceButton`.

**Alternatives considered**:
- `easy_localization`: dependencia extra innecesaria. ARB nativo cubre la necesidad.
- Strings en constantes Dart: no cumple con la constitución (deben estar en ARB).

## R5: Tema accesible global

**Decision**: Un `ThemeData` único en `lib/core/theme/app_theme.dart` con:
- Tipografía: Atkinson Hyperlegible vía `google_fonts` (diseñada para baja visión)
- Tamaños: body ≥18sp, display/montos ≥28sp
- Contraste: colores que cumplen WCAG 2.2 AA (4.5:1 texto, 3:1 iconos/bordes)
- Touch targets: `MaterialTapTargetSize.padded` + constraints mínimos de 48dp
- No limitar `MediaQuery.textScalerOf`: la app respeta el escalado del sistema hasta 200%

**Paleta base** (alto contraste sobre fondo blanco):
- Primary: azul oscuro (#1A3C6E) — contraste >7:1 sobre blanco
- Error: rojo oscuro (#B3261E) — contraste >5:1
- Surface: blanco (#FFFFFF)
- OnSurface: negro (#1C1B1F) — máximo contraste
- Secondary: verde oscuro (#2E7D32) para acciones exitosas

**Rationale**: La constitución (Principio I) y la spec (FR-006, FR-007) exigen estos mínimos. Atkinson Hyperlegible es la fuente recomendada en el PDF para legibilidad.

**Alternatives considered**:
- Lexend: también en el PDF, pero Atkinson Hyperlegible tiene mejor soporte para caracteres con tilde en español.
- Múltiples temas (claro/oscuro): fuera del alcance para el prototipo. Un tema de alto contraste es suficiente.

## R6: Repositorios mock detrás de interfaces

**Decision**: Cada repositorio tiene una interfaz abstracta en `domain/repositories/` y una implementación mock en `data/repositories/`. Los mocks almacenan datos en listas/mapas en memoria con datos ficticios precargados.

**Rationale**: El usuario lo pidió explícitamente: "Datos simulados con repositorios en memoria detrás de interfaces, para cambiarlos por una API real sin tocar la UI." Alineado con Principio III (dependencias apuntan hacia dominio).

**Datos ficticios precargados**:
- 1 cuenta: Rosa Martínez, S/ 2,450.00
- 3 recibos pendientes: Luz (S/ 85.50), Agua (S/ 42.00), Gas (S/ 63.20)
- 3 contactos: Valeria Martínez, Carlos López, María Sánchez
- Operaciones: lista vacía al inicio (se llenan al ejecutar pagos/envíos)

**Simulación de latencia**: `Future.delayed(Duration(milliseconds: 300))` para simular llamadas de red reales. Los estados de loading se manejan con `AsyncValue` de Riverpod.

**Alternatives considered**:
- JSON hardcoded en assets: agrega complejidad de parseo innecesaria para un mock.
- Supabase/Firebase: el PDF los menciona para backend simulado, pero para esta feature los datos in-memory son más simples y rápidos de iterar. Se puede migrar a Supabase en features futuras.

## R7: Widgets accesibles reutilizables

**Decision**: Tres widgets base en `lib/core/presentation/widgets/` que encapsulan los requisitos de accesibilidad y serán reutilizados por todas las features:

1. **AccessibleButton**: botón con área ≥48dp, `Semantics` label, `tooltip`, alto contraste. Parámetros: texto, icono, onPressed.
2. **ConfirmationScreen**: scaffold con resumen de operación (destinatario, monto), botón confirmar, botón volver. Lee automáticamente por TalkBack.
3. **ErrorMessage**: muestra error en lenguaje sencillo con acción sugerida. Usa `SemanticsService.announce`.

**Rationale**: Los 3 arquetipos (Rosa, Luis, Carmen) necesitan estos patrones en todas las pantallas. Centralizarlos en core evita repetir lógica de a11y en cada feature.

## R8: Migración de linter

**Decision**: Reemplazar `flutter_lints` por `very_good_analysis` en `analysis_options.yaml` y `pubspec.yaml`.

**Rationale**: La constitución (Principio VII) exige `very_good_analysis`. El proyecto actual usa `flutter_lints` (el template default de Flutter).

**Cambios**:
- `pubspec.yaml`: reemplazar `flutter_lints: ^6.0.0` por `very_good_analysis: ^6.0.0`
- `analysis_options.yaml`: cambiar `include: package:flutter_lints/flutter.yaml` a `include: package:very_good_analysis/analysis_options.yaml`

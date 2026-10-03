# Research: Modo Práctica (008-practice-mode)

## R1: Reutilizar pantallas de 001 sin duplicar — ProviderScope override

**Decision**: Envolver las rutas del modo práctica en un `ProviderScope` con overrides que reemplazan los repositorios reales (mock de producción) por repositorios de práctica. Las pantallas de 001 (BalanceScreen, PayBillScreen, etc.) reciben los datos sin saber si vienen del repo real o del de práctica.

**Implementación**:
```dart
// En el builder de la ruta /easy-mode/practice:
ProviderScope(
  overrides: [
    accountRepositoryProvider.overrideWith(
      (_) => PracticeAccountRepository(),
    ),
    billRepositoryProvider.overrideWith(
      (_) => PracticeBillRepository(),
    ),
    contactRepositoryProvider.overrideWith(
      (_) => PracticeContactRepository(),
    ),
    operationRepositoryProvider.overrideWith(
      (_) => PracticeOperationRepository(),
    ),
  ],
  child: child,
)
```

**Rationale**: Este es el patrón documentado de Riverpod para testing y sandboxing. Las pantallas de 001 usan `ref.watch(accountRepositoryProvider)` — no saben ni les importa qué implementación reciben. Cero duplicación de UI.

**Prerequisite**: Los providers de repositorio de 001 deben estar definidos como overridables (no como providers finales hardcoded). El research de 001 (R1, R6) ya describe este patrón exacto: "provider global por repositorio que se overridea en ProviderScope con la implementación mock."

**Alternatives considered**:
- Duplicar las pantallas de 001 con variantes de práctica: viola DRY, doble mantenimiento.
- Flag global `isPracticeMode` que cada pantalla consulta: dispersa la lógica, error-prone.
- Parámetros en los constructores de cada screen: invasivo, modifica 001.

## R2: Variante visual del tema

**Decision**: Un `ThemeData` alternativo para modo práctica que hereda del tema principal (`app_theme.dart` de 001-R5) y cambia solo el color de acento y el `colorScheme.primary`. El banner permanente usa este color.

**Implementación**:
```dart
// lib/features/practice_mode/presentation/theme/practice_theme.dart
ThemeData practiceTheme(ThemeData base) {
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF2E7D32), // Verde — distinto del azul real
      onPrimary: Colors.white,
    ),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: const Color(0xFF2E7D32),
    ),
  );
}
```

**Color elegido**: Verde oscuro (#2E7D32) — ya está en la paleta del tema principal (R5 de 001, usado para "acciones exitosas"). Contraste >5:1 sobre blanco. Visualmente distinto del azul (#1A3C6E) del modo real. Cumple WCAG 4.5:1 para texto.

**Aplicación**: El `ProviderScope` override también inyecta el tema de práctica. Alternativamente, un `Theme` widget envuelve el child del ShellRoute de práctica.

**Alternatives considered**:
- Borde de color alrededor de toda la pantalla: más invasivo visualmente, puede interferir con el layout.
- Fondo de diferente color: puede romper el contraste de los textos existentes.
- Solo el banner sin cambio de color: insuficiente para baja visión (SC-003 exige 90% de distinción).

## R3: Banner permanente "Modo práctica - dinero de prueba"

**Decision**: Un `Container` fijo en la parte superior del `Scaffold` body, dentro del ShellRoute de práctica. Siempre visible, no dismissable. Con `Semantics` para TalkBack.

**Implementación**:
```dart
class PracticeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFF2E7D32), // Verde práctica
      child: Text(
        AppLocalizations.of(context).practiceMode_banner,
        // "Modo práctica - dinero de prueba"
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
```

**Accesibilidad**:
- `Semantics(label: ...)` en el banner.
- FR-016: Al entrar a cada pantalla en modo práctica, `SemanticsService.announce("Modo práctica")`.
- Contraste: blanco sobre verde #2E7D32 = >5:1. Cumple.

**Ubicación**: Dentro del ShellRoute de práctica, encima del `child`:
```dart
Column(
  children: [
    const PracticeBanner(),
    Expanded(child: child),
  ],
)
```

**Alternatives considered**:
- AppBar subtitle: se perdería en pantallas que ya tienen AppBar con título propio.
- Overlay: puede tapar contenido y ser confuso.

## R4: Anuncios TTS al entrar y salir

**Decision**: Al navegar a `/easy-mode/practice`, reproducir un anuncio TTS: "Entraste al modo práctica. Aquí usas dinero de mentira. Nada de lo que hagas toca tu cuenta real." Al navegar de vuelta a `/easy-mode`, reproducir: "Saliste del modo práctica. Ahora estás en tu cuenta real."

**Implementación**: `SemanticsService.announce()` para TalkBack + el servicio TTS de 004 (si el usuario tiene audio habilitado). Ambos mecanismos son complementarios: TalkBack para usuarios ciegos, TTS para usuarios videntes que se benefician del audio.

```dart
// Al entrar:
SemanticsService.announce(
  AppLocalizations.of(context).practiceMode_enterAnnouncement,
  TextDirection.ltr,
);
await ref.read(ttsServiceProvider).speak(
  AppLocalizations.of(context).practiceMode_enterAnnouncement,
);
```

**Alternatives considered**:
- Solo TalkBack: no llega a usuarios videntes que no usan lector de pantalla.
- Solo TTS: no llega a usuarios que tienen TalkBack pero no TTS.
- Dialog modal: bloquea, el usuario tiene que interactuar para seguir.

## R5: Confirmación sin biometría — "Confirmar práctica"

**Decision**: En modo práctica, la confirmación de operaciones monetarias reemplaza el botón de huella/PIN por un botón "Confirmar práctica" que ejecuta directamente. No se llama a `local_auth`.

**Implementación**: El provider de confirmación biométrica se overridea en el ProviderScope de práctica con una implementación que siempre retorna `true`:

```dart
biometricAuthProvider.overrideWith(
  (_) => PracticeBiometricAuth(), // always succeeds
),
```

Alternativamente, si la pantalla de confirmación (`ConfirmationScreen` de 001-R7) recibe el texto del botón como parámetro, basta con pasar `"Confirmar práctica"` vía un provider. El comportamiento de "confirmar" ya existe — solo cambia la etiqueta y se salta la biometría.

**Rationale**: FR-007 dice que la confirmación NO debe requerir biometría en modo práctica. El spec lo justifica: "para evitar confusión con operaciones reales y para no requerir biometría en un contexto sin riesgo."

**Alternatives considered**:
- Mostrar huella pero aceptar cualquier input: confuso, el usuario piensa que usó su huella real.
- Eliminar confirmación: pierde valor pedagógico del flujo completo.

## R6: Repositorios de práctica — datos ficticios aislados

**Decision**: 4 clases que implementan las interfaces abstractas de 001 con datos ficticios independientes. Datos in-memory, se reinician al crear la instancia (=cada vez que se entra a práctica).

**Datos ficticios de práctica**:
| Repository | Data |
|------------|------|
| `PracticeAccountRepository` | "Cuenta de práctica", ****0000, S/ 5,000.00 |
| `PracticeBillRepository` | Luz ficticia (S/ 95.00), Agua ficticia (S/ 38.00), Teléfono ficticio (S/ 55.00) |
| `PracticeContactRepository` | "Ana García", "Pedro Ruiz", "Lucía Torres" (nombres genéricos, no reales del usuario) |
| `PracticeOperationRepository` | Lista vacía. Acepta `createOperation()` pero en lista in-memory aislada. |

**Aislamiento garantizado**:
- Los repos de práctica NO importan ni referencian los repos reales.
- No hay forma de que un repo de práctica mute el estado del repo real: son instancias distintas con datos distintos.
- El test de aislamiento verifica que los providers del repo real no reciben llamadas durante una sesión de práctica.

**Reinicio**: `PracticeAccountRepository.reset()` restaura el saldo a S/ 5,000 y los recibos a `pending`. Se llama al tocar "Reiniciar práctica" (FR-014).

**Alternatives considered**:
- Copiar datos del repo real al de práctica: mezcla datos, riesgo de leaks.
- Flag en los repos reales para modo práctica: viola separación, un bug podría mutar datos reales.

## R7: Simulación de alerta de fraude (002) en práctica

**Decision**: Overridear el `RiskEngine` de 002 con un `PracticeRiskEngine` que activa la alerta `unusualAmount` cuando el monto supera S/ 500. Esto garantiza que al menos una operación en práctica triggeree la alerta (los recibos son < S/ 100, pero enviar > S/ 500 la activa).

**Implementación**:
```dart
class PracticeRiskEngine implements RiskEngine {
  @override
  RiskAlert? evaluate({
    required OperationContext context,
    required List<Operation> history,
  }) {
    if (context.amount > 500) {
      return RiskAlert(
        triggeredRules: {RiskRule.unusualAmount},
        operation: context,
      );
    }
    return null;
  }
}
```

**Nota educativa**: Cuando la guía está activa (R8) y aparece la alerta, se muestra una explicación adicional encima o debajo de la alerta:
```
"Esta alerta aparece cuando algo parece inusual. Es para protegerte."
```
Texto en ARB, ≤ 15 palabras.

**Presentación**: La misma `FraudAlertScreen` de 002, sin cambios. El `PracticeRiskEngine` produce el mismo tipo de `RiskAlert`, así que la pantalla no necesita saber que está en práctica. La nota educativa se inyecta como un widget adicional visible solo cuando `practiceGuideActiveProvider` es true.

**Alternatives considered**:
- Mostrar la alerta siempre: fatiga, pierde valor educativo.
- Crear una pantalla de alerta separada para práctica: duplicación innecesaria.

## R8: Guía paso a paso opcional

**Decision**: Al iniciar cualquier acción en modo práctica, un dialog pregunta "¿Quieres que te guíe paso a paso?" con "Sí, guíame" y "No, ya sé". Si acepta, un overlay en la parte superior de cada pantalla del flujo muestra una instrucción breve.

**Implementación**: Un provider `practiceGuideProvider` (bool + mapa de instrucciones). Las instrucciones son un Map de ruta a texto (ARB), definidas por flujo:

```dart
const _guideSteps = {
  '/easy-mode/practice/pay-bill': 'Paso 1: Elige el recibo que quieres pagar.',
  '/easy-mode/practice/pay-bill/:id/confirm': 'Paso 2: Revisa el monto y toca Confirmar práctica.',
  '/easy-mode/practice/send-money': 'Paso 1: Elige a quién enviarle dinero.',
  // ...
};
```

**Overlay**: `PracticeGuideOverlay` widget que lee el `navigationContextProvider` y muestra la instrucción correspondiente a la ruta actual, solo si la guía está activa.

```dart
class PracticeGuideOverlay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guideActive = ref.watch(practiceGuideActiveProvider);
    if (!guideActive) return const SizedBox.shrink();

    final route = ref.watch(navigationContextProvider).currentRoute;
    final instruction = PracticeGuideSteps.forRoute(route);
    if (instruction == null) return const SizedBox.shrink();

    return Container(
      // Instrucción en la parte superior, debajo del banner
      padding: const EdgeInsets.all(12),
      color: Colors.amber.shade50,
      child: Text(instruction, style: ...),
    );
  }
}
```

**Alternatives considered**:
- Tooltips en los elementos: complejos, difíciles de controlar, no secuenciales.
- Coachmarks (pointy highlights): requieren librería extra, complejidad visual.
- Tutorial fuera de la app: no es "modo práctica", es documentación.

## R9: Rutas de navegación para modo práctica

**Decision**: Sub-rutas bajo `/easy-mode/practice/` que mapean a las mismas pantallas de 001 pero envueltas en el ProviderScope de práctica.

**Estructura de rutas**:
```
/easy-mode/practice                          → PracticeEntryScreen (ofrece guía)
/easy-mode/practice/home                     → EasyModeHomeScreen (reusada, con repos práctica)
/easy-mode/practice/balance                  → BalanceScreen (reusada)
/easy-mode/practice/pay-bill                 → PayBillScreen (reusada)
/easy-mode/practice/pay-bill/:billId/confirm → PayBillConfirmScreen (reusada)
/easy-mode/practice/send-money               → SendMoneyScreen (reusada)
/easy-mode/practice/send-money/confirm       → SendMoneyConfirmScreen (reusada)
/easy-mode/practice/success                  → OperationSuccessScreen (reusada, con "Practicar otra vez")
```

**ShellRoute de práctica**:
```dart
ShellRoute(
  builder: (context, state, child) => ProviderScope(
    overrides: [...practiceOverrides],
    child: Theme(
      data: practiceTheme(Theme.of(context)),
      child: Column(
        children: [
          const PracticeBanner(),
          if (guideActive) PracticeGuideOverlay(route: state.uri.path),
          Expanded(child: child),
        ],
      ),
    ),
  ),
  routes: [/* rutas de práctica que apuntan a screens de 001 */],
)
```

**Botón "Salir de práctica"**: Visible en el AppBar o como un FAB alternativo. Navega a `/easy-mode` y reproduce el anuncio TTS de salida.

**Alternatives considered**:
- Mismas rutas con query param `?practice=true`: confunde deep linking, dificulta el ShellRoute con overrides.
- Rutas completamente separadas (`/practice/...`): pierde la relación jerárquica con easy-mode.

## R10: Test de aislamiento de datos

**Decision**: Un test de integración que verifica que los repositorios reales NUNCA reciben llamadas durante una sesión de práctica.

**Implementación**:
```dart
test('practice mode never touches real repositories', () async {
  final realAccountRepo = MockAccountRepository();
  final realBillRepo = MockBillRepository();

  // Montar la app con repos reales trackeados
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accountRepositoryProvider.overrideWith((_) => realAccountRepo),
        billRepositoryProvider.overrideWith((_) => realBillRepo),
      ],
      child: const App(),
    ),
  );

  // Entrar a modo práctica
  await tester.tap(find.text('Practicar'));
  await tester.pumpAndSettle();

  // Completar un pago en práctica
  // ...

  // Verificar que repos reales nunca fueron llamados
  verifyNever(realAccountRepo).getAccount();
  verifyNever(realAccountRepo).updateBalance(any, any);
  verifyNever(realBillRepo).payBill(any);
});
```

**Rationale**: SC-001 exige "100% de las operaciones en modo práctica usan datos ficticios y no afectan datos reales". Este test es la prueba verificable de ese criterio.

**Alternatives considered**:
- Solo unit tests de cada repo: no prueban el aislamiento end-to-end.
- Code review manual: no es reproducible ni automático.

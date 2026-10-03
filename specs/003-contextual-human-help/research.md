# Research: Ayuda Humana con Contexto (003-contextual-human-help)

## R1: Captura de contexto con GoRouterObserver

**Decision**: Implementar un `NavigationObserver` que extiende `NavigatorObserver` (compatible con go_router via `observers` param) y actualiza un `navigationContextProvider` cada vez que cambia la ruta. El provider expone la ruta actual, el nombre de la pantalla legible, y metadata del flujo.

**Rationale**: El usuario lo pidió: "un observer de go_router y un provider de Riverpod" para registrar el contexto real. `GoRouter` acepta una lista de `NavigatorObserver` en su constructor. El observer escribe en un provider que cualquier widget puede leer.

**Implementación**:
```dart
class NavigationObserver extends NavigatorObserver {
  final Ref ref;
  NavigationObserver(this.ref);

  @override
  void didPush(Route route, Route? previousRoute) {
    ref.read(navigationContextProvider.notifier).update(route);
  }
  // didPop, didReplace...
}
```

El provider mantiene:
- `currentRoute`: path de la ruta actual (ej: `/easy-mode/pay-bill/123/confirm`)
- `screenName`: nombre legible en español (ej: "Confirmación de pago")
- `flowStep`: paso dentro del flujo si aplica (ej: "Paso 2 de 3")

**Mapa ruta → nombre legible**: Un Map<String, String> en el observer o en un helper, que mapea patrones de ruta a nombres de pantalla en español. Se define en la capa de presentación (no en dominio).

**Alternatives considered**:
- `GoRouter.of(context).routeInformationProvider`: requiere BuildContext, no funciona fuera de widgets.
- Tracking manual (cada pantalla notifica al provider): propenso a olvidos, el observer es automático.

## R2: Provider de contexto de operación en curso

**Decision**: Un `operationInProgressProvider` (Riverpod StateNotifier) que los flows de 001 actualizan cuando el usuario está en medio de un pago o transferencia. Contiene: tipo de operación, monto, destinatario, ID del recibo/contacto.

**Rationale**: FR-005 exige que el contexto incluya la operación en curso con monto y destinatario. La ruta sola no tiene esos datos. Los providers de 001 (pay_bill, send_money) ya manejan esos datos; solo necesitan escribir un snapshot en el provider de operación en curso.

**Patrón**: Los providers de 001 llaman `ref.read(operationInProgressProvider.notifier).set(...)` cuando el usuario inicia un flujo, y `clear()` cuando completa o cancela.

**Alternatives considered**:
- Parsear datos de la ruta (query params): mezcla datos de negocio con navegación. Sucio.
- Leer directamente los providers de 001 desde 003: acopla 003 a la estructura interna de 001.

## R3: ContextCollector — servicio Dart puro

**Decision**: Clase `ContextCollector` en `domain/services/` que recibe los datos crudos del observer y del provider de operación, y construye un `HelpContext` limpio, filtrando datos sensibles.

**Rationale**: Separar la recolección del contexto (presentación/observer) de la construcción del paquete seguro (dominio). El collector es testeable sin widgets: le pasas strings y retorna un HelpContext.

**Filtros de seguridad** (FR-016):
- Nunca incluye contraseñas, PIN, datos biométricos
- Número de cuenta enmascarado (solo últimos 4 dígitos)
- Monto y destinatario sí se incluyen (son datos operativos, no secretos)

**Alternatives considered**:
- Construir HelpContext directamente en el widget: mezcla lógica con UI, no testeable.

## R4: Botón de ayuda global (HelpFab)

**Decision**: Un `FloatingActionButton` persistente en todas las pantallas del Modo Fácil. Se implementa como un widget reutilizable `HelpFab` que se incluye en el `floatingActionButton` de cada Scaffold, o via un shell route de go_router que envuelve todas las pantallas con un Scaffold con el FAB.

**Rationale**: FR-001 exige que el botón esté "visible y accesible desde cualquier pantalla con un solo toque". Un FAB es el patrón estándar de Material para acción principal persistente. 48dp mínimo (lo cumple por defecto, Material FAB es 56dp).

**Implementación preferida**: Shell route de go_router que provee un `Scaffold` con `HelpFab` a todas las rutas del Modo Fácil. Esto evita repetir el FAB en cada pantalla.

```dart
ShellRoute(
  builder: (context, state, child) => Scaffold(
    body: child,
    floatingActionButton: const HelpFab(),
  ),
  routes: [/* todas las rutas de easy_mode */],
)
```

**Alternatives considered**:
- Botón en AppBar: menos visible que FAB, no cumple "desde cualquier pantalla" si no hay AppBar.
- Overlay permanente: más complejo, interfiere con gestos de navegación.
- Incluir manualmente en cada Scaffold: repetitivo, propenso a olvidos.

## R5: Canales de comunicación simulados

**Decision**: 3 canales para asesor (call, chat, videoWithInterpreter), 2 para familiar (call, chat). Todos simulados: al seleccionar un canal, se navega a `HelpConnectingScreen` que muestra "Te estamos conectando..." por 2 segundos y luego un mensaje de confirmación con el contexto que se envió.

**Canales**:
| Canal | Disponible para | UI |
|-------|-----------------|-----|
| `call` | Familiar + Asesor | "Llamar a [nombre]" / "Llamar al banco" |
| `chat` | Familiar + Asesor | "Escribir a [nombre]" / "Escribir al banco" |
| `videoWithInterpreter` | Solo Asesor | "Videollamada con intérprete de lengua de señas" |

**Rationale**: La videollamada con intérprete es un diferenciador del proyecto que responde al reclamo #037 (discapacidad auditiva). Solo disponible para asesor porque el familiar no tiene infraestructura de intérprete.

**Simulación del contexto enviado**: La pantalla de conexión muestra un card con el contexto que "recibiría" la persona contactada:
```
"Contexto enviado a Valeria:
Rosa está en: Confirmación de pago
Operación: Pagar recibo de Luz por S/ 120.00"
```

Esto demuestra al panel que el contexto funciona, sin comunicación real.

**Alternatives considered**:
- Conexión real con livekit_client: está en el PDF de licencias, pero fuera del alcance de esta feature individual. Se integraría en una iteración futura.

## R6: Fallback a asesor cuando familiar no responde

**Decision**: Timer de 60 segundos (simulado). Si el usuario eligió al familiar, después del timeout se muestra `HelpFallbackScreen`: "No pudimos comunicarte con [nombre]. ¿Quieres hablar con un asesor del banco?" con opciones "Sí" y "Volver". El asesor recibe el mismo contexto.

**Rationale**: FR-010 exige fallback. El timeout es simulado (en el prototipo, se puede triggerear con un botón de "simular no respuesta" o esperar los 60s).

**Alternatives considered**:
- Sin fallback: el usuario se queda sin ayuda si el familiar no responde. Inaceptable.
- Fallback automático sin preguntar: el usuario puede no querer hablar con un extraño del banco.

## R7: Consentimiento de contexto — delegado a 006

**Decision**: El consentimiento para compartir contexto con el familiar ya está cubierto por el permiso `helpRequests` de 006-trusted-person. Si el permiso está activo, se comparte contexto. Si no, se contacta al familiar pero sin contexto (US4-AS4: "Rosa necesita ayuda" sin detalles).

**Rationale**: 006 ya implementa consentimiento granular con ConsentRecord. Agregar otro layer de consentimiento sería redundante. El permiso `helpRequests` = "cuando pidas ayuda puedes elegir a Valeria" implica consentimiento para compartir contexto operativo con ella.

**Refinamiento**: Si se necesita granularidad más fina (permiso de ayuda pero SIN contexto), se agrega un flag `contextSharingEnabled` al TrustedPerson. Para el prototipo, `helpRequests` activo = contexto compartido.

**Alternatives considered**:
- Pantalla de consentimiento separada cada vez: fatiga del usuario, contradice el spec que dice "sin volver a pedir permiso".
- Consentimiento único en 003: duplica lógica de 006.

## R8: Preservación del progreso del flujo

**Decision**: El botón de ayuda navega a las pantallas de help con `context.push()` (no `go()`), apilando las pantallas de ayuda sobre la ruta actual. Al terminar la ayuda, `context.pop()` vuelve exactamente donde estaba. Los datos del flujo están en providers de Riverpod, no en el widget tree, así que sobreviven la navegación.

**Rationale**: FR-011 exige que el progreso se preserve. Como los datos de 001 (monto, recibo seleccionado, contacto) están en Riverpod providers (no en StatefulWidget local), push/pop no los pierde. Es el patrón más simple y robusto.

**Alternatives considered**:
- Modal/overlay en vez de ruta: más complejo de manejar con a11y y TalkBack.
- Guardar estado antes de navegar y restaurar: innecesario si los providers ya lo mantienen.

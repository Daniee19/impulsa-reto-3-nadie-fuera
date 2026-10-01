# Feature Specification: Detección de Fricción

**Feature Branch**: `007-friction-detection`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "La app detecta cuando el usuario parece trabado: retrocede 3+ veces, se queda sin interactuar 20+ segundos, o comete el mismo error repetido. Ofrece ayuda amable y opcional. Nunca interrumpe confirmaciones de pago ni insiste si el usuario dice que no."

**Depends on**: [specs/001-easy-mode](../001-easy-mode/spec.md) — detecta fricción dentro de los flujos del Modo Fácil. [specs/003-contextual-human-help](../003-contextual-human-help/spec.md) — una de las opciones de ayuda ofrecidas. [specs/004-voice-text-assistant](../004-voice-text-assistant/spec.md) — otra opción de ayuda ofrecida.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rosa retrocede varias veces pagando un recibo (Priority: P1)

Rosa está intentando pagar su recibo de luz. Llegó a la pantalla de confirmación, pero se asustó y tocó "Volver". Volvió a llegar a la confirmación, y otra vez retrocedió. A la tercera vez que retrocede, la app le muestra un mensaje suave en la parte inferior de la pantalla: "Parece que necesitas ayuda con este paso. ¿Quieres que te explique?" Con tres opciones: "Sí, explícame", "Hablar con alguien", "No, estoy bien". Rosa toca "Sí, explícame" y el asistente de voz le dice en lenguaje simple qué hace el botón de confirmar y que su dinero está seguro.

**Why this priority**: Retroceder repetidamente es la señal más clara de que un usuario tiene miedo o no entiende el paso. Para los adultos mayores, el miedo al error es la barrera #1. Detectar esto y ofrecer ayuda proactiva es lo que diferencia una app accesible de una que simplemente "funciona".

**Independent Test**: Se puede probar retrocediendo 3 veces en el mismo paso de un flujo y verificando que aparece el ofrecimiento de ayuda. Entrega valor: el usuario recibe ayuda antes de abandonar la operación.

**Acceptance Scenarios**:

1. **Given** el usuario retrocede 3 o más veces dentro del mismo flujo de una operación, **When** toca "Volver" la tercera vez, **Then** aparece un mensaje de ofrecimiento de ayuda, amable y no intrusivo, con opciones claras.
2. **Given** aparece el ofrecimiento de ayuda, **When** el usuario elige "Sí, explícame", **Then** el asistente de voz (004) da una explicación breve del paso actual en lenguaje simple.
3. **Given** aparece el ofrecimiento de ayuda, **When** el usuario elige "Hablar con alguien", **Then** se activa el flujo de Ayuda humana con contexto (003), incluyendo en el contexto que el usuario estaba trabado en ese paso específico.
4. **Given** aparece el ofrecimiento de ayuda, **When** el usuario elige "No, estoy bien", **Then** el mensaje desaparece y no vuelve a aparecer para esa misma operación.

---

### User Story 2 - Carmen se queda quieta 20 segundos en un paso (Priority: P1)

Carmen está en el flujo de "Enviar dinero". Llegó al paso donde debe ingresar el monto, pero se queda mirando la pantalla sin tocar nada durante 20 segundos. La app le muestra suavemente: "¿Necesitas ayuda con este paso?" Con las mismas tres opciones. Carmen toca "Sí, explícame" y el asistente le dice: "Escribe cuánto dinero quieres enviar. Por ejemplo, 50."

**Why this priority**: La inactividad prolongada en un paso específico indica confusión o indecisión. Los adultos mayores con dislexia (como Carmen) se paralizan ante formularios que no entienden. Ofrecer ayuda sin que la tengan que buscar reduce el abandono.

**Independent Test**: Se puede probar quedándose inmóvil 20 segundos en un paso de un flujo y verificando que aparece el ofrecimiento.

**Acceptance Scenarios**:

1. **Given** el usuario lleva 20 segundos o más sin interactuar en un paso de un flujo, **When** se cumple el tiempo, **Then** aparece el ofrecimiento de ayuda con las tres opciones.
2. **Given** el usuario estaba inactivo pero ahora interactúa, **When** toca cualquier elemento antes de que aparezca el ofrecimiento, **Then** el temporizador se reinicia y el ofrecimiento no aparece.

---

### User Story 3 - Luis comete el mismo error repetido (Priority: P2)

Luis está intentando escribir un monto pero sigue ingresando texto no válido (letras en vez de números). Después de 3 errores del mismo tipo, la app le ofrece ayuda: "Parece que hay un problema con este campo. ¿Te ayudo?" Luis elige "Sí, explícame" y el asistente le dice por voz: "En este campo solo puedes escribir números. Por ejemplo, 50."

**Why this priority**: P2 porque es menos frecuente que la inactividad o los retrocesos, pero cubre un patrón real de fricción especialmente para usuarios con dislexia o baja visión que pueden equivocarse en la entrada de datos.

**Independent Test**: Se puede probar ingresando el mismo tipo de dato incorrecto 3 veces y verificando que aparece el ofrecimiento.

**Acceptance Scenarios**:

1. **Given** el usuario comete el mismo tipo de error 3 o más veces en el mismo campo o paso, **When** ocurre el tercer error, **Then** aparece el ofrecimiento de ayuda con las tres opciones.
2. **Given** el usuario ya recibió el ofrecimiento por error repetido y dijo "No, estoy bien", **When** sigue cometiendo errores, **Then** no vuelve a aparecer el ofrecimiento para ese mismo campo en esa sesión.

---

### User Story 4 - El ofrecimiento no interrumpe una confirmación de pago (Priority: P1)

Rosa está en la pantalla de confirmación de un pago y se queda 25 segundos leyendo el resumen antes de confirmar. La app NO muestra el ofrecimiento de ayuda porque está en una pantalla de confirmación. La pausa en una confirmación es normal (el usuario está verificando los datos antes de mover dinero). Interrumpir aquí sería contraproducente y podría causar un error.

**Why this priority**: P1 porque es una restricción de seguridad. Las pantallas de confirmación de operaciones monetarias (pagar recibo, enviar dinero) y las alertas del escudo antifraude son momentos donde el usuario DEBE poder tomarse su tiempo sin interrupciones. Un ofrecimiento de ayuda en ese momento podría distraer y causar una confirmación accidental.

**Independent Test**: Se puede probar quedándose inactivo 20+ segundos en una pantalla de confirmación y verificando que NO aparece el ofrecimiento.

**Acceptance Scenarios**:

1. **Given** el usuario está en una pantalla de confirmación de pago o transferencia, **When** pasan 20+ segundos de inactividad, **Then** NO aparece ningún ofrecimiento de ayuda.
2. **Given** el usuario está en una pantalla de alerta del escudo antifraude, **When** pasan 20+ segundos, **Then** NO aparece el ofrecimiento de ayuda (la alerta ya es una forma de asistencia).
3. **Given** el usuario está en la pantalla de consentimiento de micrófono o permisos, **When** pasan 20+ segundos, **Then** NO aparece el ofrecimiento (son decisiones que requieren tiempo).

---

### User Story 5 - La fricción detectada se envía como contexto a la ayuda humana (Priority: P2)

Rosa elige "Hablar con alguien" después del ofrecimiento de ayuda. Se activa el flujo de Ayuda humana con contexto (003). El asesor o familiar recibe, además del contexto normal (pantalla, paso, operación), información adicional: "Rosa retrocedió 3 veces en la confirmación del pago de su recibo de luz por S/ 120." Esto le permite al asesor entender inmediatamente que Rosa tiene miedo de confirmar, no que no sabe dónde está el botón.

**Why this priority**: P2 porque enriquece la ayuda humana pero no es estrictamente necesario para que funcione. Sin embargo, es lo que convierte una llamada genérica de soporte en una atención personalizada.

**Independent Test**: Se puede probar activando una señal de fricción, eligiendo ayuda humana, y verificando que el contexto incluye el tipo de fricción detectada.

**Acceptance Scenarios**:

1. **Given** el usuario elige "Hablar con alguien" desde el ofrecimiento de ayuda por fricción, **When** se activa el flujo de ayuda humana (003), **Then** el contexto enviado incluye: tipo de fricción detectada (retrocesos, inactividad, o errores repetidos), paso específico donde ocurrió, y datos de la operación en curso.
2. **Given** el asesor o familiar recibe el contexto con fricción, **When** lo lee, **Then** la información de fricción se presenta en lenguaje comprensible (ej: "Se trabó 3 veces en la confirmación del pago").

---

### Edge Cases

- Que pasa si el usuario retrocede por razones legítimas (quiere cambiar un dato)? El ofrecimiento aparece igual a los 3 retrocesos, pero con "No, estoy bien" se descarta sin consecuencias. Es preferible ofrecer ayuda de más que de menos.
- Que pasa si el usuario deja el teléfono en la mesa y vuelve después de 20 segundos? El ofrecimiento aparece. Si toca "No, estoy bien", desaparece. No hay penalización.
- Que pasa si se activan dos señales a la vez (inactividad + retrocesos)? Se muestra un solo ofrecimiento de ayuda. No se apilan mensajes.
- Que pasa si el usuario está en la pantalla principal del Modo Fácil (sin flujo activo) y pasan 20 segundos? NO aparece ofrecimiento: la inactividad solo se detecta dentro de flujos activos (pasos de pagar, enviar, etc.), no en la pantalla principal.
- Que pasa si el usuario dijo "No, estoy bien" y luego cambia de opinión? Siempre puede tocar el botón "Pedir ayuda" (003) que está disponible en toda la app.
- Que pasa si el usuario usa el asistente de voz (004) y comete errores de reconocimiento? Los errores de reconocimiento de voz no cuentan como "error repetido" para esta feature. Solo cuentan errores de validación de datos (formato incorrecto, campo vacío, etc.).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE detectar tres señales de fricción dentro de los flujos activos del Modo Fácil: retroceso repetido (3+ veces en el mismo flujo), inactividad prolongada (20+ segundos en un paso), y error repetido del mismo tipo (3+ veces en el mismo campo o paso).
- **FR-002**: Cuando se detecta una señal de fricción, el sistema DEBE mostrar un ofrecimiento de ayuda no intrusivo con un mensaje amable y tres opciones: "Sí, explícame" (activa explicación por voz del asistente 004), "Hablar con alguien" (activa ayuda humana 003), y "No, estoy bien" (descarta el ofrecimiento).
- **FR-003**: El ofrecimiento de ayuda NUNCA DEBE aparecer en pantallas de confirmación de operaciones monetarias (pago, transferencia), alertas del escudo antifraude, ni pantallas de consentimiento o permisos.
- **FR-004**: Si el usuario elige "No, estoy bien", el ofrecimiento NO DEBE volver a aparecer para esa misma señal en esa misma operación.
- **FR-005**: Si se detectan múltiples señales de fricción simultáneas, el sistema DEBE mostrar un solo ofrecimiento, no varios.
- **FR-006**: La detección de inactividad DEBE aplicarse solo dentro de flujos activos (pasos de pagar recibo, enviar dinero, etc.), NO en la pantalla principal ni en pantallas informativas (ver saldo).
- **FR-007**: El temporizador de inactividad DEBE reiniciarse con cualquier interacción del usuario (toque, escritura, voz).
- **FR-008**: Cuando el usuario elige "Hablar con alguien", el contexto enviado a la ayuda humana (003) DEBE incluir el tipo de fricción detectada, el paso donde ocurrió, y los datos de la operación en curso.
- **FR-009**: Los errores de reconocimiento de voz del asistente (004) NO DEBEN contar como "error repetido" para la detección de fricción. Solo cuentan errores de validación de datos ingresados.
- **FR-010**: El ofrecimiento de ayuda DEBE cumplir los requisitos de accesibilidad: legible por lector de pantalla, contraste 4.5:1, área táctil mínima de 48x48 dp en las opciones.
- **FR-011**: El mensaje del ofrecimiento DEBE usar lenguaje simple y empático (frases de máximo 15 palabras, sin jerga). Ejemplo: "Parece que necesitas ayuda con este paso."
- **FR-012**: La aparición del ofrecimiento DEBE anunciarse automáticamente por el lector de pantalla.

### Key Entities

- **Señal de fricción**: Un patrón de comportamiento que indica que el usuario puede estar trabado. Tipos: retroceso repetido (3+ veces), inactividad prolongada (20+ segundos), error repetido (3+ veces del mismo tipo). Se detecta por flujo/paso, no globalmente.
- **Ofrecimiento de ayuda**: Mensaje no intrusivo que aparece cuando se detecta fricción. Atributos: señal que lo disparó, paso donde ocurrió, opciones disponibles (explicar, hablar con alguien, descartar), estado (activo, descartado).
- **Contexto de fricción**: Información adicional que se agrega al paquete de contexto de ayuda humana (003) cuando el ofrecimiento se originó por fricción. Atributos: tipo de señal, número de ocurrencias, paso específico.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de las señales de fricción (retroceso 3+, inactividad 20+s, error repetido 3+) disparan el ofrecimiento de ayuda en los flujos activos.
- **SC-002**: El 0% de los ofrecimientos aparecen en pantallas de confirmación, alertas de fraude o pantallas de consentimiento.
- **SC-003**: El ofrecimiento aparece en menos de 2 segundos después de detectar la señal de fricción.
- **SC-004**: El 80% de los usuarios de prueba (adultos mayores de 60 anos) perciben el ofrecimiento como "amable" o "útil", no como "molesto" o "intrusivo".
- **SC-005**: Al menos el 50% de los usuarios de prueba que reciben el ofrecimiento eligen una opción de ayuda (explícame o hablar con alguien) en vez de descartarlo.
- **SC-006**: El 100% de los casos donde el usuario elige "Hablar con alguien" incluyen el contexto de fricción en la información enviada a la ayuda humana.
- **SC-007**: Después de descartar un ofrecimiento ("No, estoy bien"), no vuelve a aparecer para esa señal en esa operación en el 100% de los casos.

## Assumptions

- Los umbrales de detección son fijos para el prototipo: 3 retrocesos, 20 segundos de inactividad, 3 errores del mismo tipo. No se ajustan dinámicamente por usuario.
- La detección opera solo dentro de flujos activos del Modo Fácil (pagar recibo, enviar dinero). No aplica en la pantalla principal, pantalla de saldo, ni en configuración.
- "Sí, explícame" activa una explicación contextual breve del asistente de voz (004) sobre el paso actual. La explicación es predefinida por paso, no generada libremente por la IA.
- "Hablar con alguien" delega completamente al flujo de 003-contextual-human-help, agregando el contexto de fricción al paquete de contexto normal.
- El ofrecimiento es un mensaje superpuesto suave (no un diálogo modal que bloquee la pantalla), para que no se sienta como una interrupción.
- Las pantallas excluidas de detección incluyen: confirmación de pago/transferencia, alertas del escudo antifraude (002), pantalla de consentimiento de micrófono (004), y pantalla de consentimiento de persona de confianza (006).
- Si el usuario descarta el ofrecimiento y luego quiere ayuda, puede usar el botón "Pedir ayuda" (003) que está siempre disponible.

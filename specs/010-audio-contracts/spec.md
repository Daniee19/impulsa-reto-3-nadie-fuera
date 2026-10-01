# Feature Specification: Contratos Explicados en Audio

**Feature Branch**: `010-audio-contracts`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Contratos explicados en audio. Antes de aceptar un producto o condición (por ejemplo, abrir una cuenta de ahorro o aceptar términos), la app muestra y lee en voz alta un resumen en lenguaje simple: qué acepta, cuánto cuesta, qué riesgos tiene y cómo cancelar. El usuario puede pausar, repetir, ir más lento y hacer preguntas al asistente. El contrato completo siempre sigue disponible, y el resumen indica claramente que no lo reemplaza. No se permite aceptar sin haber visto u oído el resumen. Para el hackathon los contratos son de ejemplo."

**Depends on**: [specs/001-easy-mode](../001-easy-mode/spec.md) — interfaz base donde se presentan productos. [specs/004-voice-text-assistant](../004-voice-text-assistant/spec.md) — el asistente responde preguntas del usuario sobre el contrato.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Carmen escucha el resumen antes de aceptar una cuenta de ahorro (Priority: P1)

Carmen quiere abrir una cuenta de ahorro. Antes de ver el botón "Aceptar", la app le presenta una pantalla con el resumen del contrato en lenguaje simple. El resumen tiene cuatro secciones claras: qué está aceptando, cuánto le cuesta, qué riesgos tiene, y cómo puede cancelar después. La app empieza a leer el resumen en voz alta automáticamente. Carmen puede pausar la lectura, repetir una sección, o bajar la velocidad. Al terminar de escuchar (o leer), se habilita el botón "Aceptar". Carmen también ve un enlace "Ver contrato completo" y una nota que dice: "Este resumen te ayuda a entender. El documento completo está disponible abajo."

**Why this priority**: Es el flujo principal de la feature. La guía técnica dice: "Carmen escucha un resumen en lenguaje simple antes de firmar su crédito." Sin este flujo no hay feature. La lectura en voz alta es esencial para usuarios con dislexia o baja visión que no pueden procesar texto denso.

**Independent Test**: Se puede probar navegando a la aceptación de un producto y verificando que el resumen aparece, se lee en voz alta, tiene controles de reproducción, y que el botón "Aceptar" no está habilitado hasta que el usuario haya visto u oído el resumen completo.

**Acceptance Scenarios**:

1. **Given** el usuario llega al paso de aceptar un producto o condición, **When** se muestra la pantalla de contrato, **Then** ve un resumen en lenguaje simple con cuatro secciones: qué acepta, cuánto cuesta, qué riesgos tiene, y cómo cancelar.
2. **Given** el resumen está visible, **When** la pantalla se carga, **Then** la app empieza a leer el resumen en voz alta automáticamente.
3. **Given** el resumen se está leyendo, **When** el usuario toca "Pausar", **Then** la lectura se detiene y el botón cambia a "Continuar".
4. **Given** el resumen terminó de leerse (o el usuario lo leyó desplazándose hasta el final), **When** mira el botón "Aceptar", **Then** el botón está habilitado. Antes de eso, está deshabilitado con una nota: "Primero escucha o lee el resumen."

---

### User Story 2 - Carmen repite y desacelera una sección que no entendió (Priority: P1)

Carmen está escuchando el resumen de un préstamo personal. La sección de "riesgos" menciona algo sobre intereses y no lo entiende bien. Toca "Repetir sección" y la app vuelve a leer solo la sección de riesgos. Sigue sin entender, así que toca "Más lento" y la app lee la misma sección a velocidad reducida. Ahora entiende.

**Why this priority**: P1 porque sin controles de reproducción, el audio es una barrera más, no una ayuda. El usuario necesita control total sobre el ritmo. Los adultos mayores procesan información más lento y necesitan repetición sin sentir presión.

**Independent Test**: Se puede probar reproduciendo el resumen, tocando "Repetir sección" y verificando que solo se repite la sección actual, y tocando "Más lento" para verificar que la velocidad disminuye perceptiblemente.

**Acceptance Scenarios**:

1. **Given** el resumen se está leyendo por secciones, **When** el usuario toca "Repetir sección", **Then** la app vuelve a leer la sección actual desde el inicio sin saltar a otra sección.
2. **Given** el resumen se está leyendo, **When** el usuario toca "Más lento", **Then** la velocidad de lectura disminuye un nivel (máximo 2 reducciones). El botón indica la velocidad actual.
3. **Given** la velocidad ya está al mínimo, **When** el usuario toca "Más lento", **Then** el botón se deshabilita con una nota: "Ya estás en la velocidad más lenta."
4. **Given** el usuario redujo la velocidad, **When** toca "Velocidad normal", **Then** la lectura vuelve a la velocidad estándar.

---

### User Story 3 - Carmen le pregunta al asistente qué significa un término (Priority: P2)

Carmen está leyendo el resumen del contrato y ve la palabra "comisión de mantenimiento". No la entiende. Toca "Preguntar al asistente" y escribe (o dice por voz): "¿Qué es comisión de mantenimiento?" El asistente (004) le responde en lenguaje simple: "Es un cobro mensual que el banco hace por tener la cuenta abierta. En este caso son 5 soles al mes." Carmen vuelve al resumen y sigue escuchando.

**Why this priority**: P2 porque el resumen ya está en lenguaje simple, pero siempre habrá términos que algún usuario no conozca. La integración con el asistente (004) cierra la brecha de comprensión sin abandonar la pantalla del contrato.

**Independent Test**: Se puede probar pausando el resumen, tocando "Preguntar al asistente", haciendo una pregunta sobre un término del contrato, y verificando que el asistente responde en contexto y que el usuario vuelve al resumen.

**Acceptance Scenarios**:

1. **Given** el usuario está en la pantalla de resumen del contrato, **When** toca "Preguntar al asistente", **Then** se abre el asistente (004) con el contexto del contrato actual, sin salir de la pantalla de resumen.
2. **Given** el usuario hace una pregunta sobre un término del contrato, **When** el asistente responde, **Then** la respuesta está en lenguaje simple (máximo 15 palabras por oración) y hace referencia al contexto del contrato que el usuario está revisando.
3. **Given** el usuario terminó de consultar al asistente, **When** cierra la consulta, **Then** vuelve al resumen exactamente donde lo dejó, y la lectura en voz alta se puede retomar.

---

### User Story 4 - Luis revisa el contrato con TalkBack (Priority: P2)

Luis, que es ciego, llega a la pantalla del contrato. TalkBack anuncia: "Resumen del contrato: Cuenta de ahorro básica. Sección 1 de 4: Qué estás aceptando." Luis navega por las secciones con gestos de deslizar. Cada sección se lee completa. Los controles (pausar, repetir, más lento, preguntar al asistente) son accesibles por TalkBack con etiquetas claras. El botón "Aceptar" anuncia su estado: "Aceptar — deshabilitado, primero escucha o lee el resumen" o "Aceptar — disponible."

**Why this priority**: P2 porque la accesibilidad por lector de pantalla es transversal (005), pero merece un escenario específico aquí para garantizar que la interacción con controles de audio funciona con TalkBack.

**Independent Test**: Se puede probar con TalkBack activado, navegando por las secciones del resumen, usando los controles de reproducción, y verificando que el estado del botón "Aceptar" se anuncia correctamente.

**Acceptance Scenarios**:

1. **Given** el usuario tiene TalkBack activo, **When** llega a la pantalla de resumen del contrato, **Then** TalkBack anuncia el título del contrato, la sección actual, y el número total de secciones.
2. **Given** TalkBack está activo, **When** el usuario navega los controles de reproducción, **Then** cada control tiene etiqueta descriptiva en español ("Pausar lectura", "Repetir esta sección", "Lectura más lenta", "Preguntar al asistente").
3. **Given** TalkBack está activo, **When** el usuario llega al botón "Aceptar", **Then** TalkBack anuncia si está habilitado o deshabilitado y la razón.

---

### User Story 5 - Carmen accede al contrato completo (Priority: P2)

Carmen ya escuchó el resumen y quiere ver el contrato completo antes de aceptar. Toca "Ver contrato completo". Se abre el documento completo (largo, con lenguaje legal). Carmen puede desplazarse por él. La app no lo lee en voz alta automáticamente (es muy largo), pero Carmen puede seleccionar un párrafo y tocar "Leer esto" para que se lea. El botón "Volver al resumen" está siempre visible.

**Why this priority**: P2 porque la mayoría de usuarios no necesitará leer el contrato completo — el resumen cubre lo esencial. Pero la transparencia exige que siempre esté disponible y accesible.

**Independent Test**: Se puede probar tocando "Ver contrato completo" desde el resumen, verificando que se muestra el documento, que se puede seleccionar un párrafo para lectura, y que el botón "Volver al resumen" funciona.

**Acceptance Scenarios**:

1. **Given** el usuario está en la pantalla de resumen, **When** toca "Ver contrato completo", **Then** ve el documento completo del contrato.
2. **Given** el usuario está viendo el contrato completo, **When** selecciona un párrafo y toca "Leer esto", **Then** la app lee en voz alta solo ese párrafo.
3. **Given** el usuario está viendo el contrato completo, **When** toca "Volver al resumen", **Then** vuelve a la pantalla de resumen con el progreso de lectura conservado.

---

### Edge Cases

- Que pasa si el usuario cierra la app mientras escucha el resumen? Al volver, el resumen se muestra desde el inicio. El botón "Aceptar" vuelve a estar deshabilitado (debe volver a escuchar o leer el resumen completo).
- Que pasa si el usuario intenta aceptar sin haber escuchado ni leído el resumen? El botón "Aceptar" está deshabilitado. Si por algún motivo el usuario intenta activarlo, ve una nota: "Primero escucha o lee el resumen completo."
- Que pasa si el usuario tiene el volumen del dispositivo en silencio? La app detecta el volumen bajo y muestra un aviso: "Tu volumen está bajo. Puedes subir el volumen o leer el resumen." El resumen de texto siempre está visible y se puede desplazar; el audio no es la única vía.
- Que pasa si el asistente no entiende la pregunta sobre el contrato? El asistente responde: "No estoy seguro de entenderte. ¿Puedes preguntar de otra manera?" (nunca inventa información sobre el contrato).
- Que pasa si el contrato no tiene una de las cuatro secciones (por ejemplo, no tiene costo)? La sección se omite del resumen y el resumen indica: "Este producto no tiene costo asociado." No se muestra una sección vacía.
- Que pasa si el usuario ya aceptó un contrato y quiere volver a revisarlo? Para el prototipo, los contratos aceptados no se almacenan. Cada navegación al producto muestra el resumen de nuevo.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Antes de aceptar cualquier producto o condición, el sistema DEBE mostrar un resumen del contrato en lenguaje simple (máximo 15 palabras por oración, sin jerga financiera).
- **FR-002**: El resumen DEBE contener exactamente cuatro secciones: (1) qué está aceptando el usuario, (2) cuánto le cuesta, (3) qué riesgos tiene, y (4) cómo puede cancelar. Si alguna sección no aplica, se indica explícitamente ("Este producto no tiene costo asociado").
- **FR-003**: El sistema DEBE leer el resumen en voz alta automáticamente al mostrar la pantalla. La lectura se organiza por secciones.
- **FR-004**: El usuario DEBE poder pausar y reanudar la lectura en voz alta en cualquier momento.
- **FR-005**: El usuario DEBE poder repetir la sección actual de la lectura sin tener que escuchar todo el resumen de nuevo.
- **FR-006**: El usuario DEBE poder reducir la velocidad de lectura. Se permiten 2 niveles de reducción. Un botón para volver a velocidad normal DEBE estar disponible.
- **FR-007**: El botón "Aceptar" DEBE estar deshabilitado hasta que el usuario haya escuchado el resumen completo (lectura por voz terminada) o lo haya leído (desplazamiento hasta el final del resumen de texto).
- **FR-008**: Mientras el botón "Aceptar" está deshabilitado, DEBE mostrar una nota visible: "Primero escucha o lee el resumen."
- **FR-009**: El resumen DEBE incluir una nota visible y permanente: "Este resumen te ayuda a entender. El documento completo está disponible abajo." o equivalente.
- **FR-010**: El usuario DEBE poder acceder al contrato completo desde la pantalla de resumen mediante un enlace o botón "Ver contrato completo".
- **FR-011**: Desde el contrato completo, el usuario DEBE poder seleccionar un párrafo y solicitar que se lea en voz alta ("Leer esto").
- **FR-012**: El usuario DEBE poder volver del contrato completo al resumen conservando el progreso de lectura.
- **FR-013**: El usuario DEBE poder consultar al asistente (004) desde la pantalla de resumen para preguntar sobre términos o secciones del contrato. El asistente recibe el contexto del contrato actual.
- **FR-014**: El asistente NUNCA DEBE inventar información sobre el contrato. Si no entiende la pregunta, DEBE pedir que se reformule.
- **FR-015**: Si el volumen del dispositivo está bajo o en silencio, el sistema DEBE mostrar un aviso sugiriendo subir el volumen o leer el resumen. El texto del resumen DEBE estar siempre visible como alternativa al audio.
- **FR-016**: Los controles de reproducción (pausar, repetir, más lento, velocidad normal) DEBEN cumplir los requisitos de accesibilidad: área táctil mínima 48×48 dp, contraste 4.5:1, etiquetas para lector de pantalla en español.
- **FR-017**: Para el hackathon, los contratos son de ejemplo (ficticios). DEBE haber al menos 2 contratos de muestra: uno para cuenta de ahorro y uno para préstamo personal.

### Key Entities

- **Contrato de ejemplo**: Documento ficticio asociado a un producto bancario. Atributos: nombre del producto, documento completo (texto legal simulado), resumen en lenguaje simple (4 secciones). Para el prototipo: cuenta de ahorro, préstamo personal.
- **Resumen de contrato**: Versión simplificada del contrato, estructurada en 4 secciones fijas (qué acepta, costo, riesgos, cancelación). Atributos: secciones con texto en lenguaje simple, estado de lectura (no leído, en progreso, completado), velocidad de reproducción actual.
- **Sesión de revisión**: El estado del usuario mientras revisa un contrato. Atributos: sección actual, progreso de lectura (por audio o por scroll), velocidad seleccionada, consultas al asistente realizadas. No persiste si el usuario cierra la app.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de los productos que requieren aceptación muestran el resumen antes de permitir aceptar. No hay forma de aceptar sin haber visto u oído el resumen.
- **SC-002**: El 90% de los usuarios de prueba (adultos mayores de 60 años) comprenden las cuatro secciones del resumen sin necesidad de ver el contrato completo.
- **SC-003**: El 85% de los usuarios de prueba logran pausar, repetir o desacelerar la lectura sin asistencia.
- **SC-004**: El usuario puede escuchar el resumen completo de un contrato de ejemplo en menos de 3 minutos a velocidad normal.
- **SC-005**: Un usuario ciego puede navegar las secciones del resumen y usar todos los controles de reproducción con TalkBack.
- **SC-006**: El 80% de los usuarios de prueba que consultan al asistente sobre un término del contrato reportan que la respuesta les ayudó a entender.
- **SC-007**: El resumen indica claramente que no reemplaza al contrato completo en el 100% de los casos (nota siempre visible).

## Assumptions

- Los contratos de ejemplo para el hackathon son ficticios pero realistas en estructura: un contrato de cuenta de ahorro (sin costo, bajo riesgo) y un contrato de préstamo personal (con costo, intereses, riesgos).
- El resumen en lenguaje simple es predefinido por contrato, no generado dinámicamente por IA. Cada contrato de ejemplo tiene su resumen ya escrito.
- La lectura en voz alta organizada por secciones permite que los controles "Repetir sección" funcionen sobre unidades de contenido con sentido completo.
- "Haber leído el resumen" se detecta por: (a) la lectura por voz llegó al final, o (b) el usuario desplazó el texto del resumen hasta el final. Ambos caminos habilitan el botón "Aceptar".
- El contrato completo en el prototipo es un texto simulado de 1-2 páginas. No se espera que el usuario lo lea, pero debe estar disponible por transparencia.
- La integración con el asistente (004) pasa el contexto del contrato actual (nombre del producto, secciones del resumen) para que las respuestas sean relevantes. El asistente usa su intent `explicar_termino` para responder.
- La velocidad reducida tiene 2 niveles: 75% y 50% de la velocidad normal. No se permite velocidad más rápida que la normal (el objetivo es comprensión, no rapidez).
- La lectura en voz alta automática respeta la configuración del dispositivo: si el volumen está en silencio, el audio no se fuerza, pero se avisa al usuario.
- Para el prototipo, la aceptación del contrato no tiene efecto persistente (no se "abre" la cuenta ni se "firma" el préstamo). El flujo termina con un mensaje de confirmación simulado.

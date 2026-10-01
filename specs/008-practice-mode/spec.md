# Feature Specification: Modo Práctica

**Feature Branch**: `008-practice-mode`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "El usuario puede practicar las 4 acciones del Modo Fácil con dinero ficticio y sin riesgo. Se distingue claramente del modo real. Incluye guías paso a paso opcionales y simula una alerta del Escudo antifraude. Nada afecta la cuenta real."

**Depends on**: [specs/001-easy-mode](../001-easy-mode/spec.md) — replica los mismos 4 flujos con datos ficticios. [specs/002-fraud-shield](../002-fraud-shield/spec.md) — simula una alerta de fraude dentro del modo práctica.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rosa entra al modo práctica por primera vez (Priority: P1)

Rosa tiene miedo de equivocarse con dinero real. Desde la pantalla principal del Modo Fácil, toca "Practicar". La app anuncia en voz alta: "Entraste al modo práctica. Aquí usas dinero de mentira. Nada de lo que hagas toca tu cuenta real." La pantalla cambia de color (un borde o fondo distintivo) y muestra permanentemente el texto "Modo práctica - dinero de prueba" en la parte superior. Rosa ve los mismos 4 botones que en el modo real y puede practicar sin riesgo.

**Why this priority**: El miedo al error es la barrera principal de Rosa. Sin un espacio seguro para equivocarse, nunca se atreverá a usar la app con dinero real. La guía técnica lo llama "Rosa practica sin miedo a equivocarse antes de pagar de verdad."

**Independent Test**: Se puede probar tocando "Practicar" desde la pantalla principal y verificando que el entorno visual cambia, el anuncio de voz se reproduce, y el indicador permanente es visible. Entrega valor: el usuario sabe que está en un espacio seguro.

**Acceptance Scenarios**:

1. **Given** el usuario está en la pantalla principal del Modo Fácil, **When** toca "Practicar", **Then** entra al modo práctica con un anuncio en voz alta explicando que es dinero de prueba.
2. **Given** el usuario entró al modo práctica, **When** mira la pantalla, **Then** ve un indicador visual permanente ("Modo práctica - dinero de prueba") y un cambio de color distintivo respecto al modo real.
3. **Given** el usuario está en modo práctica con TalkBack, **When** TalkBack lee la pantalla, **Then** anuncia que está en modo práctica antes de leer los botones de acción.

---

### User Story 2 - Rosa practica pagando un recibo con guía (Priority: P1)

Rosa toca "Pagar recibo" dentro del modo práctica. La app le pregunta: "¿Quieres que te guíe paso a paso?" Rosa dice que sí. En cada paso del flujo, ve una breve instrucción en lenguaje simple arriba de la pantalla: "Paso 1: Elige el recibo que quieres pagar." Rosa selecciona un recibo ficticio, ve la confirmación con monto ficticio, confirma (sin huella real, solo un botón "Confirmar práctica"), y ve el mensaje de éxito. En todo momento el indicador de práctica está visible.

**Why this priority**: La guía paso a paso convierte el modo práctica de un sandbox vacío en una herramienta de aprendizaje. Rosa no solo practica, aprende qué hacer en cada momento. Esto es lo que construye la confianza para después operar con dinero real.

**Independent Test**: Se puede probar eligiendo "Pagar recibo" en modo práctica con la guía activada, siguiendo los pasos, y verificando que cada paso tiene instrucción y que la operación se completa con datos ficticios.

**Acceptance Scenarios**:

1. **Given** el usuario inicia una acción en modo práctica, **When** la app pregunta si quiere guía, **Then** muestra dos opciones claras: "Sí, guíame" y "No, ya sé".
2. **Given** el usuario eligió guía paso a paso, **When** avanza por cada paso del flujo, **Then** ve una instrucción breve y clara en la parte superior de la pantalla explicando qué hacer.
3. **Given** el usuario llega a la confirmación en modo práctica, **When** confirma, **Then** la confirmación NO requiere huella ni biometría (solo un botón "Confirmar práctica") y la operación se procesa con datos ficticios.
4. **Given** el usuario completó la operación de práctica, **When** ve el resultado, **Then** muestra un mensaje de éxito con datos ficticios y opción de "Practicar otra vez" o "Volver al modo real".

---

### User Story 3 - Rosa practica y aparece una alerta simulada del Escudo antifraude (Priority: P2)

Rosa está practicando enviar dinero. Envía un monto alto a un contacto ficticio. La app simula una alerta del Escudo antifraude: "Este envío es más alto de lo habitual. ¿Quieres continuar?" con las mismas tres opciones que en el modo real (cancelar, continuar, consultar persona de confianza). La guía le explica: "Esta alerta aparece cuando algo parece inusual. Es para protegerte." Rosa aprende a reconocerla sin estrés.

**Why this priority**: P2 porque es educativo, no funcional. Pero que Rosa reconozca la alerta de fraude antes de verla con dinero real reduce significativamente el pánico y la probabilidad de que llame al banco asustada.

**Independent Test**: Se puede probar enviando un monto alto en modo práctica y verificando que aparece la alerta simulada con la misma apariencia que la real, más la explicación educativa.

**Acceptance Scenarios**:

1. **Given** el usuario hace una operación en modo práctica que activaría el escudo antifraude, **When** avanza hacia la confirmación, **Then** ve una alerta simulada idéntica en apariencia a la real, con las tres opciones.
2. **Given** la guía está activada, **When** aparece la alerta simulada de fraude, **Then** se muestra una explicación educativa adicional: "Esta alerta aparece cuando algo parece inusual. Es para protegerte."
3. **Given** el usuario interactúa con la alerta simulada, **When** elige cualquier opción, **Then** la operación continúa o se cancela según la opción, pero todo con datos ficticios.

---

### User Story 4 - Rosa sale del modo práctica (Priority: P1)

Rosa terminó de practicar y quiere volver al modo real. Toca "Salir de práctica" (visible en todo momento). La app anuncia en voz alta: "Saliste del modo práctica. Ahora estás en tu cuenta real." El color y el indicador de práctica desaparecen. Rosa está de vuelta en la pantalla principal del Modo Fácil normal.

**Why this priority**: La transición clara es esencial para la seguridad. Si Rosa no se da cuenta de que volvió al modo real, podría confirmar operaciones pensando que sigue practicando. El anuncio por voz y el cambio visual eliminan esta confusión.

**Independent Test**: Se puede probar tocando "Salir de práctica" y verificando que el anuncio de voz se reproduce, el indicador visual desaparece, y la app vuelve al modo real.

**Acceptance Scenarios**:

1. **Given** el usuario está en modo práctica, **When** toca "Salir de práctica", **Then** la app anuncia en voz alta que volvió al modo real y el indicador visual de práctica desaparece.
2. **Given** el usuario salió de modo práctica, **When** inicia una operación, **Then** la operación usa datos reales (simulados del prototipo) y no datos de práctica.
3. **Given** el usuario usa TalkBack, **When** sale del modo práctica, **Then** TalkBack anuncia automáticamente el cambio de modo.

---

### User Story 5 - Rosa practica sin la guía (Priority: P2)

Rosa ya practicó varias veces y se siente más segura. Entra al modo práctica, la app pregunta si quiere guía, y Rosa dice "No, ya sé". Practica los flujos sin instrucciones en pantalla, pero con los mismos datos ficticios y el indicador de práctica visible. Si se traba, siempre puede tocar "Pedir ayuda" (que en modo práctica también funciona, simulado).

**Why this priority**: P2 porque la mayoría de usuarios usarán la guía al principio. Pero el modo sin guía es necesario para usuarios que quieren practicar la fluidez, no aprender los pasos.

**Independent Test**: Se puede probar rechazando la guía y completando una operación. Verifica que no hay instrucciones pero sí indicador de práctica y datos ficticios.

**Acceptance Scenarios**:

1. **Given** el usuario rechaza la guía paso a paso, **When** usa el modo práctica, **Then** los flujos funcionan igual que en el modo real pero con datos ficticios y sin instrucciones superpuestas.
2. **Given** el usuario está en modo práctica sin guía, **When** toca "Pedir ayuda", **Then** el botón de ayuda funciona (simulado) como en el modo real.

---

### Edge Cases

- Que pasa si el usuario cierra la app estando en modo práctica y la vuelve a abrir? Vuelve a la pantalla principal del Modo Fácil (modo real). El modo práctica no persiste entre sesiones.
- Que pasa si el usuario intenta entrar al modo práctica sin estar en el Modo Fácil? El botón "Practicar" solo existe dentro del Modo Fácil; no hay acceso desde otros puntos.
- Que pasa con el saldo en modo práctica? Se muestra un saldo ficticio predefinido (ej: S/ 5,000.00) que no tiene relación con el saldo real del usuario.
- Que pasa si el usuario "gasta" todo el saldo de práctica? El saldo ficticio se puede reiniciar tocando "Reiniciar práctica", volviendo al saldo inicial.
- Que pasa si el usuario confunde modo práctica con modo real? El indicador permanente, el cambio de color, y los anuncios de voz al entrar y salir son las tres barreras contra esta confusión. El lector de pantalla también lo anuncia.
- Que pasa si el usuario tiene la guía activada y toca "Pedir ayuda"? La ayuda se ofrece simulada; la guía se pausa y se retoma al volver.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El modo práctica DEBE ser accesible desde un botón "Practicar" en la pantalla principal del Modo Fácil.
- **FR-002**: Al entrar al modo práctica, el sistema DEBE reproducir un anuncio en voz alta indicando que es modo práctica con dinero de prueba, y que nada afecta la cuenta real.
- **FR-003**: El modo práctica DEBE mostrar un indicador visual permanente ("Modo práctica - dinero de prueba") en la parte superior de todas las pantallas mientras esté activo.
- **FR-004**: El modo práctica DEBE tener un cambio de color distintivo respecto al modo real (borde, fondo o acento) que sea perceptible incluso con baja visión, manteniendo el contraste 4.5:1.
- **FR-005**: El modo práctica DEBE incluir las mismas 4 acciones del Modo Fácil (ver saldo, pagar recibo, enviar dinero, pedir ayuda) con flujos idénticos en estructura pero usando datos completamente ficticios.
- **FR-006**: Ninguna operación en modo práctica DEBE afectar los datos reales (simulados del prototipo) de la cuenta del usuario.
- **FR-007**: La confirmación de operaciones en modo práctica NO DEBE requerir biometría (huella). DEBE usar un botón "Confirmar práctica" en su lugar.
- **FR-008**: Al iniciar cualquier acción en modo práctica, el sistema DEBE ofrecer una guía paso a paso opcional con dos opciones: "Sí, guíame" y "No, ya sé".
- **FR-009**: La guía paso a paso DEBE mostrar una instrucción breve y clara (máximo 15 palabras, sin jerga) en la parte superior de la pantalla en cada paso del flujo.
- **FR-010**: El modo práctica DEBE simular al menos una alerta del Escudo antifraude (002) cuando la operación cumple las condiciones (monto alto). La alerta simulada DEBE tener la misma apariencia que la real, con una nota educativa adicional si la guía está activada.
- **FR-011**: El botón "Salir de práctica" DEBE estar visible en todo momento dentro del modo práctica.
- **FR-012**: Al salir del modo práctica, el sistema DEBE reproducir un anuncio en voz alta confirmando que el usuario volvió al modo real y DEBE eliminar todos los indicadores visuales de práctica.
- **FR-013**: El modo práctica NO DEBE persistir entre sesiones. Si el usuario cierra y reabre la app, vuelve al modo real.
- **FR-014**: El usuario DEBE poder reiniciar los datos ficticios del modo práctica (restaurar saldo y recibos iniciales) en cualquier momento.
- **FR-015**: El modo práctica DEBE cumplir los mismos requisitos de accesibilidad que el modo real: etiquetas para lector de pantalla, contraste, áreas táctiles, y anuncios de cambios de estado.
- **FR-016**: El lector de pantalla DEBE anunciar que el usuario está en modo práctica al entrar, al navegar cada pantalla, y al salir.

### Key Entities

- **Sesión de práctica**: El periodo en que el usuario está en modo práctica. Atributos: saldo ficticio actual, operaciones de práctica realizadas, guía activa (sí/no). No persiste entre sesiones de la app.
- **Datos ficticios de práctica**: Conjunto de datos separados de los datos reales. Incluye: saldo ficticio (ej: S/ 5,000), recibos ficticios (luz, agua, teléfono), contactos ficticios con nombres inventados. No se mezclan con datos reales.
- **Guía paso a paso**: Instrucciones opcionales que se superponen en cada paso de un flujo en modo práctica. Atributos: texto de instrucción por paso, estado (activa/inactiva), acción asociada.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de las operaciones en modo práctica usan datos ficticios y no afectan datos reales en ningún escenario verificado.
- **SC-002**: El indicador visual "Modo práctica - dinero de prueba" es visible en el 100% de las pantallas durante la sesión de práctica.
- **SC-003**: El 90% de los usuarios de prueba (adultos mayores de 60 anos) distinguen correctamente cuándo están en modo práctica y cuándo en modo real.
- **SC-004**: El 85% de los usuarios de prueba completan al menos un flujo completo (pagar recibo o enviar dinero) en modo práctica en su primer intento con la guía activada.
- **SC-005**: El 80% de los usuarios de prueba que practican al menos una vez reportan sentirse "más seguros" o "más preparados" para operar con dinero real.
- **SC-006**: El anuncio por voz se reproduce al entrar y salir del modo práctica en el 100% de los casos.
- **SC-007**: La alerta simulada del Escudo antifraude aparece al menos una vez durante una sesión de práctica completa (cuando se hacen operaciones de monto alto).

## Assumptions

- El saldo ficticio inicial es S/ 5,000.00 — suficiente para practicar varias operaciones sin agotarlo rápido, pero no tan alto que parezca irreal.
- Los datos ficticios de práctica son predefinidos: 3 recibos ficticios (luz, agua, teléfono) con montos fijos, y 3 contactos ficticios con nombres genéricos (no nombres reales del usuario).
- La guía paso a paso tiene instrucciones predefinidas por paso para cada uno de los 4 flujos. No son generadas dinámicamente por IA.
- "Confirmar práctica" reemplaza la huella para evitar confusión con operaciones reales y para no requerir biometría en un contexto sin riesgo.
- El cambio de color del modo práctica usa un tono diferenciado (por ejemplo, azul o verde) que mantenga el contraste 4.5:1 para accesibilidad.
- La alerta simulada del Escudo antifraude se activa cuando el usuario envía más de S/ 500 ficticios (umbral fijo para práctica), para que ocurra al menos una vez.
- El botón "Pedir ayuda" en modo práctica funciona de forma simulada (no conecta con nadie real). Muestra un mensaje de confirmación simulado.
- El modo práctica no tiene puntuación, niveles, insignias ni gamificación. La guía técnica explica que la gamificación infantil es condescendiente para adultos mayores.

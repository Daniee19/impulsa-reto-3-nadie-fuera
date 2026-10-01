# Feature Specification: Escudo Antifraude

**Feature Branch**: `002-fraud-shield`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Antes de enviar dinero o pagar un recibo, la app detecta operaciones inusuales (monto mucho mayor al habitual, destinatario nuevo, horario extraño o varias operaciones seguidas) y hace una pausa. Explica el riesgo en lenguaje muy simple, sin palabras técnicas, y ofrece tres opciones: cancelar, continuar de todos modos o consultar a su persona de confianza. Nunca bloquea al usuario sin explicarle por qué."

**Depends on**: [specs/001-easy-mode](../001-easy-mode/spec.md) — el escudo se activa dentro de los flujos de "Pagar recibo" y "Enviar dinero" del Modo Fácil.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Alerta por monto inusual (Priority: P1)

Rosa quiere pagar un recibo de luz por S/ 850, cuando sus pagos habituales son de alrededor de S/ 120. Antes de llegar a la pantalla de confirmación final, la app hace una pausa y le muestra un aviso claro: "Este pago es mucho más alto de lo que sueles pagar. ¿Quieres continuar?" Le ofrece tres opciones: cancelar el pago, continuar de todos modos, o consultar a Valeria (su persona de confianza). Rosa entiende el riesgo, decide llamar a Valeria, y Valeria le confirma que sí, este mes el recibo vino más alto. Rosa vuelve y continúa.

**Why this priority**: El monto inusual es la señal de alerta más clara y frecuente en fraudes contra adultos mayores. Es también la más fácil de entender para el usuario: "esto cuesta más de lo normal". Es la regla que más confianza genera porque protege sin confundir.

**Independent Test**: Se puede probar simulando un pago cuyo monto supere el umbral del historial del usuario. Entrega valor inmediato: el usuario recibe protección ante un posible error o fraude.

**Acceptance Scenarios**:

1. **Given** el usuario inicia un pago o transferencia cuyo monto supera significativamente su promedio habitual, **When** avanza hacia la confirmación, **Then** la app muestra una pantalla de pausa con una explicación simple del riesgo y tres opciones claras: cancelar, continuar o consultar a su persona de confianza.
2. **Given** la pantalla de alerta se muestra, **When** el usuario elige "Cancelar", **Then** vuelve a la pantalla anterior sin perder los datos ingresados y sin que se ejecute ningún movimiento de dinero.
3. **Given** la pantalla de alerta se muestra, **When** el usuario elige "Continuar de todos modos", **Then** avanza a la pantalla de confirmación normal del flujo de pago/transferencia (definida en 001-easy-mode).
4. **Given** la pantalla de alerta se muestra, **When** el usuario elige "Consultar a mi persona de confianza", **Then** se envía un aviso a la persona de confianza registrada (simulado en el prototipo) y el usuario ve un mensaje: "Le avisamos a [nombre]. Puedes esperarle o continuar."

---

### User Story 2 - Alerta por destinatario nuevo (Priority: P1)

Luis quiere enviar dinero a alguien que no está en sus contactos habituales (en el prototipo, un contacto que nunca ha recibido dinero de él). La app hace una pausa y le dice: "Nunca le has enviado dinero a esta persona. Revisa que sea la persona correcta." Le ofrece las mismas tres opciones. TalkBack lee la alerta completa en voz alta.

**Why this priority**: Los fraudes por suplantación de identidad ("me dieron el número equivocado") son una de las estafas más comunes contra adultos mayores. Detectar un destinatario nuevo es la segunda señal de alerta más importante.

**Independent Test**: Se puede probar iniciando una transferencia a un contacto que no tiene historial de transacciones. Entrega valor: el usuario es alertado antes de enviar dinero a alguien por primera vez.

**Acceptance Scenarios**:

1. **Given** el usuario inicia una transferencia a un destinatario al que nunca le ha enviado dinero, **When** avanza hacia la confirmación, **Then** ve la pantalla de pausa explicando que es la primera vez que envía dinero a esta persona, con las tres opciones.
2. **Given** el usuario usa lector de pantalla, **When** aparece la alerta de destinatario nuevo, **Then** el lector de pantalla anuncia la alerta completa y las tres opciones en orden lógico.
3. **Given** el usuario elige consultar a su persona de confianza, **When** se envía el aviso, **Then** el aviso incluye el nombre del destinatario y el monto para que la persona de confianza pueda opinar con contexto.

---

### User Story 3 - Alerta por múltiples operaciones seguidas (Priority: P2)

Carmen ha hecho 3 pagos en los últimos 10 minutos. Cuando intenta hacer un cuarto, la app pausa y le dice: "Has hecho varios pagos seguidos. ¿Está todo bien?" Con las mismas tres opciones. Esto protege contra un escenario donde alguien más esté usando el teléfono de Carmen o donde Carmen esté siendo presionada para hacer pagos rápidos.

**Why this priority**: Es P2 porque es menos frecuente que las alertas por monto o destinatario, pero cubre un patrón de fraude real (presión para hacer múltiples pagos rápidos) y un escenario de uso no autorizado del dispositivo.

**Independent Test**: Se puede probar realizando varias operaciones simuladas en secuencia rápida. Entrega valor: protección contra uso no autorizado o presión externa.

**Acceptance Scenarios**:

1. **Given** el usuario ha realizado 3 o más operaciones monetarias en los últimos 10 minutos, **When** intenta iniciar otra operación, **Then** ve la pantalla de pausa preguntando si todo está bien, con las tres opciones.
2. **Given** el usuario elige "Cancelar" tras la alerta de múltiples operaciones, **When** vuelve a la pantalla principal, **Then** puede iniciar una nueva operación más tarde sin restricciones (no queda bloqueado).

---

### User Story 4 - Alerta por horario inusual (Priority: P3)

Rosa intenta hacer una transferencia a las 2 de la mañana, algo que nunca hace. La app pausa y le dice: "Estás haciendo un pago a una hora poco habitual para ti. ¿Está todo bien?" Con las mismas tres opciones. Esto cubre el escenario de que alguien esté usando el teléfono de Rosa mientras ella duerme.

**Why this priority**: Es P3 porque es la señal más débil (hay razones legítimas para operar de madrugada) y la más propensa a falsos positivos. Pero suma como capa adicional de protección.

**Independent Test**: Se puede probar configurando el horario simulado fuera del rango habitual del usuario. Entrega valor: protección adicional contra uso no autorizado en horarios atípicos.

**Acceptance Scenarios**:

1. **Given** el usuario inicia una operación monetaria en un horario fuera de su patrón habitual, **When** avanza hacia la confirmación, **Then** ve la pantalla de pausa mencionando que el horario es poco habitual, con las tres opciones.

---

### User Story 5 - Combinación de señales (Priority: P2)

Rosa intenta enviar un monto alto a un destinatario nuevo. La app detecta ambas señales y muestra una sola pantalla de pausa que menciona ambos riesgos: "Nunca le has enviado dinero a esta persona y el monto es más alto de lo habitual." No muestra dos alertas separadas; combina la información en un solo mensaje claro.

**Why this priority**: Es P2 porque múltiples señales simultáneas indican mayor riesgo. El usuario no debe ser bombardeado con alertas sucesivas; una sola pantalla combinada es más clara y menos frustrante.

**Independent Test**: Se puede probar iniciando una transferencia que active dos o más reglas simultáneamente. Entrega valor: comunicación clara del riesgo total sin fatiga de alertas.

**Acceptance Scenarios**:

1. **Given** una operación activa más de una regla de riesgo a la vez, **When** se muestra la alerta, **Then** se presenta una sola pantalla de pausa que menciona todas las razones en un solo mensaje, con las mismas tres opciones.
2. **Given** la pantalla de alerta combinada, **When** el usuario elige cualquiera de las tres opciones, **Then** la opción aplica a toda la operación (no necesita responder a cada riesgo por separado).

---

### Edge Cases

- Que pasa si la persona de confianza no está registrada? El botón "Consultar a mi persona de confianza" no aparece; solo se muestran "Cancelar" y "Continuar de todos modos".
- Que pasa si el usuario siempre paga montos altos? Las reglas se basan en el historial simulado del usuario; si su promedio es alto, un monto similar no dispara alerta.
- Que pasa si el usuario cancela y luego vuelve a intentar la misma operación? La alerta se muestra de nuevo; cancelar no "aprueba" la operación para intentos futuros.
- Que pasa si la operación es legítima y el usuario se siente frustrado por la pausa? La explicación es breve y empática ("Solo queremos asegurarnos"), y "Continuar de todos modos" siempre está disponible. Nunca se bloquea sin salida.
- Que pasa si el lector de pantalla está activo cuando aparece la alerta? La alerta se anuncia automáticamente al aparecer, y las tres opciones son navegables y descriptivas.
- Que pasa si todas las reglas se activan al mismo tiempo? Se muestra una sola pantalla combinada; no se apilan alertas.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE evaluar cada operación monetaria (pago de recibo y transferencia) contra reglas de riesgo antes de la confirmación final.
- **FR-002**: Las reglas de riesgo para el prototipo DEBEN incluir: monto significativamente mayor al promedio habitual del usuario, destinatario sin historial previo de transacciones, más de 3 operaciones monetarias en 10 minutos, y operación en horario fuera del patrón habitual del usuario.
- **FR-003**: Cuando una o más reglas de riesgo se activan, el sistema DEBE mostrar una pantalla de pausa antes de la confirmación final, interrumpiendo el flujo normal del Modo Fácil.
- **FR-004**: La pantalla de pausa DEBE explicar el riesgo en lenguaje simple (frases de máximo 15 palabras, sin jerga) y DEBE ofrecer exactamente tres opciones: cancelar la operación, continuar de todos modos, o consultar a la persona de confianza.
- **FR-005**: Si el usuario no tiene persona de confianza registrada, la pantalla de pausa DEBE mostrar solo dos opciones: cancelar y continuar.
- **FR-006**: Si el usuario elige "Cancelar", DEBE volver al paso anterior sin perder datos ingresados y sin ejecutar ningún movimiento de dinero.
- **FR-007**: Si el usuario elige "Continuar de todos modos", DEBE avanzar a la pantalla de confirmación normal del flujo de pago o transferencia (según 001-easy-mode).
- **FR-008**: Si el usuario elige "Consultar a mi persona de confianza", el sistema DEBE enviar un aviso a la persona de confianza con el tipo de operación, destinatario y monto, y DEBE mostrar al usuario un mensaje confirmando que se envió el aviso.
- **FR-009**: Cuando múltiples reglas se activan para una misma operación, el sistema DEBE mostrar una sola pantalla de pausa combinada, nunca alertas separadas en secuencia.
- **FR-010**: La pantalla de pausa DEBE cumplir los mismos requisitos de accesibilidad que el Modo Fácil: área táctil mínima de 48x48 dp, contraste de 4.5:1, etiquetas para lectores de pantalla, y lectura lógica en voz alta.
- **FR-011**: La aparición de la pantalla de pausa DEBE anunciarse automáticamente para usuarios de lectores de pantalla.
- **FR-012**: El escudo NUNCA DEBE bloquear una operación sin explicar por qué ni sin ofrecer al menos la opción de cancelar o continuar.
- **FR-013**: Los datos de historial de operaciones, umbrales de riesgo y persona de confianza DEBEN ser simulados (datos ficticios) para el prototipo.
- **FR-014**: El mensaje de la pantalla de pausa DEBE ser empático y no alarmista (ej: "Solo queremos asegurarnos" en vez de "Operación sospechosa detectada").

### Key Entities

- **Regla de riesgo**: Una condición que, al cumplirse, activa la pantalla de pausa. Atributos: tipo (monto inusual, destinatario nuevo, frecuencia alta, horario inusual), descripción en lenguaje simple. Para el prototipo hay 4 reglas fijas.
- **Alerta de riesgo**: Una instancia de una o más reglas activadas para una operación concreta. Atributos: operación asociada, reglas activadas, mensaje combinado, opciones disponibles (2 o 3 según si hay persona de confianza).
- **Persona de confianza**: Un familiar o persona cercana registrada que puede recibir avisos cuando el usuario enfrenta una operación sospechosa. Atributos: nombre, relación, medio de contacto. Datos simulados. Una sola persona de confianza por usuario.
- **Historial de operaciones**: Registro simulado de operaciones pasadas del usuario, usado para calcular promedios de monto y patrones de horario. Datos ficticios precargados.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de las operaciones monetarias que cumplan al menos una regla de riesgo muestran la pantalla de pausa antes de la confirmación final.
- **SC-002**: El 90% de los usuarios de prueba (adultos mayores de 60 anos) entienden por qué apareció la pausa y qué opciones tienen, sin necesitar explicación adicional.
- **SC-003**: El usuario puede resolver la alerta (eligiendo cualquiera de las 3 opciones) en menos de 30 segundos.
- **SC-004**: El 100% de las alertas son comprensibles por lector de pantalla: se anuncian al aparecer y las opciones son navegables.
- **SC-005**: Nunca se muestra más de una pantalla de pausa por operación, incluso si se activan múltiples reglas.
- **SC-006**: El escudo nunca bloquea una operación sin ofrecer al menos una forma de continuar o cancelar.
- **SC-007**: El 80% de los usuarios de prueba reportan que el escudo los hace sentir más seguros (no más frustrados) al usar la app.

## Assumptions

- Las reglas de riesgo para el prototipo son simples y basadas en umbrales fijos sobre datos simulados: un monto se considera "inusual" si supera el doble del promedio de las últimas 10 operaciones del mismo tipo; un destinatario es "nuevo" si no aparece en el historial simulado; "frecuencia alta" es más de 3 operaciones en 10 minutos; "horario inusual" es fuera del rango 7:00–22:00 (simplificación para el prototipo).
- La persona de confianza es un solo contacto por usuario, precargado en los datos simulados. El registro de una persona de confianza está fuera del alcance de esta feature.
- El "aviso" a la persona de confianza es simulado en el prototipo (se muestra un mensaje de confirmación al usuario pero no se envía una notificación real).
- El escudo se integra en los flujos de "Pagar recibo" y "Enviar dinero" del Modo Fácil (001-easy-mode). No aplica a "Ver saldo" ni a "Pedir ayuda" porque no mueven dinero.
- El tono de los mensajes es empático y protector, nunca acusatorio ni alarmista, alineado con el principio de UX cognitiva de la constitución del proyecto.
- El escudo no reemplaza la confirmación normal del flujo de pago/transferencia; es un paso adicional que aparece solo cuando se detecta riesgo, antes de la confirmación final.

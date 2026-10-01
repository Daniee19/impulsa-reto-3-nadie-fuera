# Feature Specification: Recordatorios de Pagos Recurrentes

**Feature Branch**: `012-payment-reminders`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Recordatorios de pagos recurrentes. La app avisa con anticipación cuándo vence un pago frecuente (luz, agua, pensión, teléfono) con un mensaje simple y leído en voz alta, por ejemplo 'Tu recibo de luz vence el viernes: 85 soles'. Desde el aviso se puede ir directo a pagar con el flujo del Modo Fácil. El usuario elige qué recordatorios recibir y con cuántos días de anticipación, y opcionalmente su persona de confianza también recibe el aviso. Para el hackathon los recibos y las fechas son simulados."

**Depends on**: [specs/001-easy-mode](../001-easy-mode/spec.md) — el pago directo desde el recordatorio usa el flujo de "Pagar recibo" del Modo Fácil. [specs/006-trusted-person](../006-trusted-person/spec.md) — la persona de confianza puede recibir una copia del recordatorio si el usuario lo autoriza.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rosa recibe un recordatorio de pago próximo (Priority: P1)

Rosa abre la app y ve un aviso destacado en la pantalla principal del Modo Fácil: "Tu recibo de luz vence el viernes: 85 soles." La app lee el aviso en voz alta automáticamente. Debajo del mensaje hay dos botones: "Pagar ahora" y "Ya lo sé, gracias". Rosa toca "Pagar ahora" y la app la lleva directamente al flujo de pago de recibos (001) con el recibo de luz ya preseleccionado y el monto prellenado.

**Why this priority**: Es el flujo principal de la feature. El recordatorio proactivo evita que Rosa olvide un pago y sufra recargos o cortes de servicio. La transición directa a pagar reduce la fricción: un toque y ya está en el flujo de pago, sin buscar el recibo manualmente.

**Independent Test**: Se puede probar simulando que un recibo vence dentro del periodo de anticipación y verificando que el recordatorio aparece en la pantalla principal, se lee en voz alta, y el botón "Pagar ahora" lleva al flujo correcto con datos prellenados.

**Acceptance Scenarios**:

1. **Given** un recibo configurado vence dentro del periodo de anticipación del usuario, **When** el usuario abre la app, **Then** ve un aviso en la pantalla principal con el nombre del servicio, la fecha de vencimiento en lenguaje natural (día de la semana) y el monto.
2. **Given** el recordatorio se muestra, **When** la pantalla se carga, **Then** la app lee el aviso en voz alta automáticamente.
3. **Given** el usuario toca "Pagar ahora", **When** se abre el flujo de pago, **Then** el recibo correspondiente está preseleccionado y el monto está prellenado. El usuario solo necesita confirmar.
4. **Given** el usuario toca "Ya lo sé, gracias", **When** descarta el recordatorio, **Then** el aviso desaparece y no vuelve a mostrarse para ese recibo en esa fecha de vencimiento.

---

### User Story 2 - Rosa configura qué recordatorios recibir (Priority: P1)

Rosa quiere recibir recordatorios de luz y agua, pero no de teléfono porque ese lo paga su hijo. Desde configuración, accede a "Mis recordatorios". Ve una lista de los recibos disponibles (simulados) con un interruptor para cada uno. Activa luz y agua, deja teléfono apagado. También elige cuántos días antes quiere que le avisen: las opciones son 1 día, 3 días o 5 días antes. Rosa elige 3 días.

**Why this priority**: P1 porque sin control del usuario, los recordatorios se vuelven ruido. Si Rosa recibe avisos de pagos que no le tocan, dejará de prestarles atención a todos. El control granular respeta su autonomía y mantiene la utilidad.

**Independent Test**: Se puede probar accediendo a la configuración de recordatorios, activando y desactivando servicios, eligiendo la anticipación, y verificando que solo los recibos activos generan avisos.

**Acceptance Scenarios**:

1. **Given** el usuario accede a "Mis recordatorios" en configuración, **When** ve la lista, **Then** cada recibo disponible tiene un interruptor (activar/desactivar) y su nombre en lenguaje simple ("Luz", "Agua", "Teléfono", "Pensión").
2. **Given** el usuario desactiva un recibo, **When** ese recibo está próximo a vencer, **Then** no se genera ningún recordatorio para él.
3. **Given** el usuario elige la anticipación (1, 3 o 5 días), **When** un recibo activo está dentro de ese periodo, **Then** el recordatorio aparece. Si aún no entra en el periodo, no aparece.
4. **Given** el usuario cambia la anticipación de 3 a 1 día, **When** un recibo vence en 2 días, **Then** no se muestra recordatorio (aún no está dentro del nuevo periodo).

---

### User Story 3 - Rosa comparte el recordatorio con su persona de confianza (Priority: P2)

Rosa quiere que su hija Valeria también sepa cuándo vencen los recibos, por si Rosa se olvida. En la configuración de recordatorios, activa la opción "Avisar también a mi persona de confianza". La app le muestra un mensaje de consentimiento: "Vamos a enviar a Valeria un aviso con el nombre del recibo y la fecha. No incluye tu saldo ni datos de tu cuenta. ¿Estás de acuerdo?" Rosa acepta. Ahora, cuando un recordatorio se activa, Valeria también recibe un aviso simulado con el nombre del servicio y la fecha de vencimiento.

**Why this priority**: P2 porque la funcionalidad base (recordatorio al usuario) funciona sin esto. Pero para adultos mayores con red de apoyo, que un familiar sepa de los pagos pendientes es una capa extra de protección contra olvidos, especialmente útil si el usuario tiene deterioro cognitivo leve.

**Independent Test**: Se puede probar activando la opción de compartir, aceptando el consentimiento, y verificando que cuando se genera un recordatorio, la persona de confianza también recibe un aviso (simulado).

**Acceptance Scenarios**:

1. **Given** el usuario tiene persona de confianza registrada (006), **When** accede a configuración de recordatorios, **Then** ve la opción "Avisar también a mi persona de confianza" con el nombre de la persona.
2. **Given** el usuario activa compartir recordatorios, **When** confirma, **Then** ve un mensaje de consentimiento (Ley 29733) explicando qué datos se comparten y cuáles no.
3. **Given** compartir está activo y aceptado, **When** se genera un recordatorio, **Then** la persona de confianza recibe un aviso con el nombre del servicio y la fecha de vencimiento, sin incluir monto, saldo ni datos de cuenta.
4. **Given** el usuario no tiene persona de confianza registrada, **When** accede a configuración de recordatorios, **Then** la opción de compartir no aparece.

---

### User Story 4 - Luis recibe el recordatorio con TalkBack (Priority: P2)

Luis, que es ciego, abre la app. TalkBack anuncia: "Tienes un recordatorio. Tu recibo de agua vence el lunes: 42 soles. Opciones: Pagar ahora, Ya lo sé gracias." Luis puede navegar las opciones con gestos de deslizar y activar la que quiera. Si elige "Pagar ahora", TalkBack lo guía por el flujo de pago (001) con el recibo preseleccionado.

**Why this priority**: P2 porque la accesibilidad por lector de pantalla es transversal (005), pero el recordatorio tiene un formato propio (mensaje + acciones directas) que necesita verificación específica.

**Independent Test**: Se puede probar con TalkBack activado, verificando que el recordatorio se anuncia completo y que las opciones son navegables.

**Acceptance Scenarios**:

1. **Given** TalkBack está activo, **When** hay un recordatorio pendiente al abrir la app, **Then** TalkBack anuncia el recordatorio completo (servicio, fecha, monto) y las opciones disponibles.
2. **Given** TalkBack está activo, **When** el usuario elige "Pagar ahora", **Then** el flujo de pago se abre con el recibo preseleccionado y es navegable por TalkBack.

---

### User Story 5 - Rosa ve varios recordatorios a la vez (Priority: P2)

Rosa tiene dos recibos que vencen esta semana: luz el miércoles y agua el viernes. Al abrir la app, ve ambos recordatorios ordenados por urgencia (el que vence primero arriba). La app lee el más urgente en voz alta. Rosa puede deslizar para ver el segundo. Cada uno tiene su botón "Pagar ahora" independiente.

**Why this priority**: P2 porque es un escenario frecuente pero no el flujo principal. La priorización por urgencia asegura que el usuario atiende primero lo más inmediato.

**Independent Test**: Se puede probar simulando dos recibos con fechas de vencimiento cercanas y verificando que ambos aparecen, ordenados por fecha, y que cada uno tiene acción independiente.

**Acceptance Scenarios**:

1. **Given** hay más de un recordatorio activo, **When** el usuario abre la app, **Then** los recordatorios se muestran ordenados por fecha de vencimiento (más próximo primero).
2. **Given** hay varios recordatorios, **When** la app lee en voz alta, **Then** solo lee el más urgente para no abrumar al usuario.
3. **Given** hay varios recordatorios, **When** el usuario toca "Pagar ahora" en uno, **Then** se abre el flujo de pago para ese recibo específico, sin afectar los demás recordatorios.

---

### Edge Cases

- Que pasa si el recibo ya venció? El recordatorio cambia de tono: "Tu recibo de luz venció ayer. Aún puedes pagarlo." El botón "Pagar ahora" sigue disponible. No se muestra el recordatorio si ya pasaron más de 3 días del vencimiento.
- Que pasa si el usuario ya pagó el recibo? Para el prototipo con datos simulados, si el usuario completó el flujo de pago (001) para ese recibo, el recordatorio desaparece.
- Que pasa si el usuario no configura ningún recordatorio? Por defecto, todos los recibos simulados están activos con 3 días de anticipación. El usuario puede desactivarlos.
- Que pasa si el usuario no tiene persona de confianza? La opción de compartir recordatorios no aparece en configuración.
- Que pasa si hay más de 3 recordatorios simultáneos? Se muestran los 3 más urgentes. El usuario puede ver el resto desplazándose o accediendo a "Ver todos los recordatorios".
- Que pasa si el usuario cierra la app y vuelve a abrirla? Los recordatorios activos se muestran de nuevo (a menos que haya tocado "Ya lo sé, gracias" o haya pagado). La lectura en voz alta se reproduce cada vez que el recordatorio se presenta.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE mostrar recordatorios de pagos recurrentes próximos a vencer en la pantalla principal del Modo Fácil, con el nombre del servicio, la fecha de vencimiento en lenguaje natural (día de la semana o "mañana"/"hoy") y el monto.
- **FR-002**: El sistema DEBE leer en voz alta el recordatorio más urgente automáticamente al mostrarse. Si hay varios, solo lee el primero (más próximo a vencer).
- **FR-003**: Cada recordatorio DEBE ofrecer dos opciones: "Pagar ahora" (lleva al flujo de pago de 001 con recibo preseleccionado y monto prellenado) y "Ya lo sé, gracias" (descarta el recordatorio para esa fecha de vencimiento).
- **FR-004**: Cuando hay múltiples recordatorios activos, DEBEN mostrarse ordenados por fecha de vencimiento (más próximo primero). Se muestran hasta 3 en la pantalla principal; los demás son accesibles desplazándose.
- **FR-005**: El usuario DEBE poder configurar qué recibos generan recordatorios, activando o desactivando cada uno individualmente desde "Mis recordatorios" en configuración.
- **FR-006**: El usuario DEBE poder elegir con cuántos días de anticipación recibe los recordatorios. Las opciones son 1 día, 3 días o 5 días antes del vencimiento.
- **FR-007**: Por defecto, todos los recibos simulados DEBEN estar activos con 3 días de anticipación.
- **FR-008**: Si el usuario tiene persona de confianza registrada (006), DEBE poder activar "Avisar también a mi persona de confianza" en la configuración de recordatorios.
- **FR-009**: Activar compartir con persona de confianza DEBE requerir consentimiento explícito (Ley 29733) explicando qué datos se comparten.
- **FR-010**: El aviso a la persona de confianza DEBE incluir solo el nombre del servicio y la fecha de vencimiento. NUNCA DEBE incluir monto, saldo ni datos de cuenta.
- **FR-011**: Si un recibo ya venció (pero dentro de los últimos 3 días), el recordatorio DEBE cambiar su mensaje a pasado ("venció ayer", "venció el martes") y mantener el botón "Pagar ahora". Después de 3 días del vencimiento, el recordatorio desaparece.
- **FR-012**: Si el usuario completa el pago del recibo a través del Modo Fácil (001), el recordatorio de ese recibo DEBE desaparecer automáticamente.
- **FR-013**: Los recordatorios NUNCA DEBEN bloquear ni retrasar operaciones en curso. Se muestran en la pantalla principal, no como interrupciones.
- **FR-014**: Los recordatorios DEBEN cumplir los requisitos de accesibilidad: áreas táctiles de 48×48 dp, contraste 4.5:1, etiquetas para lector de pantalla en español, y anuncio automático del recordatorio más urgente.
- **FR-015**: Para el hackathon, los recibos, fechas de vencimiento y montos son simulados. DEBE haber al menos 4 recibos de ejemplo: luz, agua, teléfono y pensión.

### Key Entities

- **Recibo recurrente**: Un pago periódico simulado. Atributos: nombre del servicio (luz, agua, teléfono, pensión), monto, fecha de vencimiento, estado (pendiente, pagado, vencido). Datos ficticios para el prototipo.
- **Recordatorio**: Aviso generado cuando un recibo activo entra en el periodo de anticipación. Atributos: recibo asociado, fecha de generación, estado (activo, descartado, resuelto por pago), mensaje en lenguaje natural.
- **Configuración de recordatorios**: Preferencias del usuario. Atributos: recibos activos (lista con interruptor por servicio), días de anticipación (1, 3 o 5), compartir con persona de confianza (sí/no con consentimiento).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de los recibos activos generan un recordatorio cuando entran en el periodo de anticipación configurado por el usuario.
- **SC-002**: El 90% de los usuarios de prueba (adultos mayores de 60 años) comprenden el recordatorio (servicio, fecha, monto) sin asistencia.
- **SC-003**: El usuario puede ir del recordatorio al pago completado en menos de 60 segundos (un toque para "Pagar ahora" + confirmación del flujo 001).
- **SC-004**: El 85% de los usuarios de prueba logran configurar sus recordatorios (activar/desactivar servicios y elegir anticipación) sin asistencia.
- **SC-005**: El 0% de los recordatorios interrumpen una operación en curso.
- **SC-006**: Un usuario ciego puede escuchar el recordatorio y navegar a "Pagar ahora" usando solo TalkBack.
- **SC-007**: El aviso a la persona de confianza nunca incluye monto, saldo ni datos de cuenta en el 100% de los casos verificados.

## Assumptions

- Los recibos simulados para el hackathon son 4: luz (S/ 85, vence cada 15 del mes), agua (S/ 42, vence cada 20), teléfono (S/ 60, vence cada 10), y pensión (S/ 150, vence cada 5). Montos y fechas ficticios pero realistas.
- Las fechas de vencimiento simuladas se ajustan al calendario real del hackathon para que siempre haya al menos un recibo próximo a vencer durante la demo.
- "Pagar ahora" usa el flujo completo de "Pagar recibo" de 001 (incluye confirmación, Escudo antifraude si aplica, etc.). El recordatorio no crea un flujo de pago alternativo.
- El mensaje del recordatorio usa lenguaje natural para la fecha: "hoy", "mañana", día de la semana si es dentro de la misma semana, o "el [día] de [mes]" si es la semana siguiente.
- La configuración por defecto (todos activos, 3 días) es un default razonable que no requiere configuración inicial. El usuario puede modificarla cuando quiera.
- El aviso a la persona de confianza es simulado en el prototipo (se muestra confirmación al usuario pero no se envía notificación real). Se omite el monto para cumplir con la privacidad financiera del usuario (Ley 29733) y las reglas de 006 (persona de confianza nunca ve datos financieros).
- No se envían notificaciones push reales en el prototipo. Los recordatorios se muestran dentro de la app al abrirla. Una versión futura podría agregar notificaciones del sistema.
- Los recibos vencidos se muestran hasta 3 días después del vencimiento para dar oportunidad de pago tardío. Después de eso, desaparecen silenciosamente.

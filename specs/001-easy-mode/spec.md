# Feature Specification: Modo Fácil

**Feature Branch**: `001-easy-mode`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Pantalla principal simplificada para adultos mayores con solo 4 acciones grandes y claras: ver saldo, pagar recibo, enviar dinero a un contacto guardado y pedir ayuda. Cada acción debe completarse en máximo 3 pasos, con confirmación antes de mover dinero. Para el hackathon los datos de cuentas, recibos y contactos son simulados (sin banco real)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ver saldo (Priority: P1)

Rosa abre la app y quiere saber cuánto dinero tiene. Desde la pantalla principal del Modo Fácil, toca el botón "Ver mi saldo". La app le muestra su saldo disponible en números grandes, legibles y con alto contraste, junto con el nombre de su cuenta. No hay pasos intermedios: un solo toque y ya ve su dinero.

**Why this priority**: Es la acción más frecuente y la que genera más confianza. Si Rosa no puede ver su saldo fácilmente, no confiará en la app para nada más. Además, no involucra movimiento de dinero, lo que la hace segura como primer contacto con el Modo Fácil.

**Independent Test**: Se puede probar de forma aislada abriendo el Modo Fácil y tocando "Ver mi saldo". Entrega valor inmediato: el usuario conoce su situación financiera sin depender de ninguna otra funcionalidad.

**Acceptance Scenarios**:

1. **Given** el usuario está en la pantalla principal del Modo Fácil, **When** toca "Ver mi saldo", **Then** ve el saldo disponible en números grandes (al menos 28 sp) con el nombre de la cuenta, en máximo 1 paso.
2. **Given** el usuario ve su saldo, **When** usa un lector de pantalla, **Then** el saldo y el nombre de la cuenta se leen en voz alta de forma clara y en orden lógico.
3. **Given** el usuario tiene la letra del sistema al máximo (200%), **When** ve su saldo, **Then** la pantalla no se desborda ni corta información.

---

### User Story 2 - Pagar recibo (Priority: P1)

Rosa necesita pagar su recibo de luz. Desde la pantalla principal toca "Pagar recibo", selecciona el recibo pendiente de una lista corta y clara, revisa el monto y destinatario en una pantalla de confirmación, y confirma el pago. Máximo 3 pasos. Si se equivoca, puede volver atrás sin perder lo que ya ingresó.

**Why this priority**: Pagar recibos de servicios es una necesidad básica y recurrente de los adultos mayores. Es una de las principales razones por las que llaman al banco (~91,000 llamadas/mes por "no logro usar la app"). Resolverlo reduce fricción real.

**Independent Test**: Se puede probar seleccionando un recibo simulado, revisando la confirmación y completando el pago. Entrega valor completo: el usuario paga un servicio sin ayuda.

**Acceptance Scenarios**:

1. **Given** el usuario está en la pantalla principal del Modo Fácil, **When** toca "Pagar recibo", **Then** ve una lista de recibos pendientes con nombre del servicio y monto, en texto grande y claro.
2. **Given** el usuario seleccionó un recibo, **When** llega a la pantalla de confirmación, **Then** ve el nombre del servicio, el monto a pagar y un botón claro para confirmar, junto con una opción de "Volver" que no borra nada.
3. **Given** el usuario confirmó el pago, **When** el pago se procesa, **Then** ve un mensaje claro de éxito con el resumen de lo pagado, y el lector de pantalla anuncia "Pago realizado" automáticamente.
4. **Given** el usuario está en cualquier paso del flujo de pago, **When** toca "Volver", **Then** regresa al paso anterior sin perder la información previamente ingresada.

---

### User Story 3 - Enviar dinero a contacto guardado (Priority: P1)

Rosa quiere enviarle dinero a su hija Valeria. Desde la pantalla principal toca "Enviar dinero", selecciona a Valeria de su lista de contactos guardados, ingresa el monto, y confirma en una pantalla que muestra claramente a quién le envía y cuánto. Máximo 3 pasos. La app nunca permite enviar dinero sin confirmación explícita.

**Why this priority**: Enviar dinero es una operación de alto valor donde el miedo al error es la barrera principal. Rosa teme equivocarse y perder su dinero. La confirmación explícita con detalle claro del destinatario y monto es lo que convierte el miedo en confianza.

**Independent Test**: Se puede probar seleccionando un contacto simulado, ingresando un monto y confirmando. Entrega valor completo: el usuario transfiere dinero a un ser querido sin riesgo de error.

**Acceptance Scenarios**:

1. **Given** el usuario está en la pantalla principal del Modo Fácil, **When** toca "Enviar dinero", **Then** ve su lista de contactos guardados con nombre y foto o inicial, en formato grande y fácil de distinguir.
2. **Given** el usuario seleccionó un contacto e ingresó un monto, **When** llega a la pantalla de confirmación, **Then** ve el nombre del destinatario, el monto a enviar y su saldo restante, todo legible por el lector de pantalla.
3. **Given** el usuario está en la pantalla de confirmación, **When** confirma el envío, **Then** ve un mensaje de éxito con el resumen de la operación, y el lector de pantalla anuncia "Dinero enviado".
4. **Given** el usuario ingresó un monto mayor a su saldo disponible, **When** intenta continuar, **Then** ve un mensaje claro que dice "No tienes suficiente dinero" con su saldo actual, sin jerga técnica.

---

### User Story 4 - Pedir ayuda (Priority: P2)

Rosa se siente perdida o tiene miedo de hacer algo mal. Desde cualquier punto del Modo Fácil, pero especialmente desde la pantalla principal, toca "Pedir ayuda". Se le presenta la opción de contactar a una persona real (simulada en el prototipo) que pueda orientarla. El objetivo es que Rosa sepa que nunca está sola.

**Why this priority**: Es P2 porque depende emocionalmente de las otras 3 acciones: el botón de ayuda es la red de seguridad que hace posible que Rosa se atreva a usar las demás funciones. Sin embargo, su valor individual es de soporte, no transaccional.

**Independent Test**: Se puede probar tocando "Pedir ayuda" desde la pantalla principal. Entrega valor: el usuario sabe que hay una persona disponible para ayudarle.

**Acceptance Scenarios**:

1. **Given** el usuario está en la pantalla principal del Modo Fácil, **When** toca "Pedir ayuda", **Then** ve opciones claras de contacto (llamada, chat) con texto grande e iconos descriptivos.
2. **Given** el usuario seleccionó una opción de contacto, **When** se inicia la comunicación, **Then** ve un mensaje de confirmación como "Te estamos conectando con alguien que te va a ayudar" (en el prototipo, es una simulación).
3. **Given** el usuario usa lector de pantalla, **When** navega las opciones de ayuda, **Then** cada opción se anuncia claramente ("Llamar a un asesor", "Escribir a un asesor").

---

### User Story 5 - Navegación de la pantalla principal del Modo Fácil (Priority: P1)

Luis, que es ciego y usa TalkBack, abre la app en Modo Fácil. La pantalla principal le presenta exactamente 4 botones grandes con etiquetas claras. TalkBack lee cada botón en orden lógico. Luis puede navegar toda la pantalla sin encontrar elementos sin etiquetar ni acciones que dependan solo de la vista.

**Why this priority**: La pantalla principal es la puerta de entrada a todo el Modo Fácil. Si no es accesible para un usuario ciego, toda la funcionalidad queda bloqueada. Es obligación legal (Ley 29973) y del estándar WCAG 2.2 AA.

**Independent Test**: Se puede probar activando TalkBack y navegando la pantalla principal con los ojos cerrados. Entrega valor: el usuario ciego puede descubrir y acceder a las 4 acciones disponibles.

**Acceptance Scenarios**:

1. **Given** el usuario abre el Modo Fácil con TalkBack activado, **When** navega la pantalla principal, **Then** TalkBack lee cada uno de los 4 botones con su nombre descriptivo en orden lógico ("Ver mi saldo", "Pagar recibo", "Enviar dinero", "Pedir ayuda").
2. **Given** el usuario navega con TalkBack, **When** se detiene en cualquier elemento interactivo, **Then** escucha una descripción clara de lo que hace ese elemento, sin códigos ni jerga.
3. **Given** la pantalla principal se muestra con letra del sistema al 200%, **When** el usuario la ve, **Then** los 4 botones se muestran sin desbordamiento ni superposición de texto.

---

### Edge Cases

- Que pasa cuando el usuario toca "Pagar recibo" y no tiene recibos pendientes? Se muestra un mensaje claro: "No tienes recibos pendientes" con opción de volver.
- Que pasa cuando el usuario intenta enviar dinero pero no tiene contactos guardados? Se muestra un mensaje: "No tienes contactos guardados. Pide ayuda para agregar uno."
- Que pasa si el usuario toca "Volver" en el primer paso de un flujo? Regresa a la pantalla principal del Modo Fácil sin efectos secundarios.
- Que pasa si hay un error de conexión durante un pago o transferencia? Se muestra un mensaje claro: "Algo salió mal. Tu dinero no se movió. Puedes intentar de nuevo o pedir ayuda."
- Que pasa si el usuario tiene saldo cero y toca "Ver mi saldo"? Se muestra el saldo como S/ 0.00 en formato grande, sin alarmas ni mensajes confusos.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: La pantalla principal del Modo Fácil DEBE mostrar exactamente 4 acciones: ver saldo, pagar recibo, enviar dinero a contacto guardado y pedir ayuda.
- **FR-002**: Cada acción DEBE completarse en un máximo de 3 pasos desde la pantalla principal hasta la confirmación final.
- **FR-003**: Toda operación que mueva dinero (pagar recibo, enviar dinero) DEBE incluir una pantalla de confirmación que muestre destinatario y monto antes de ejecutarse.
- **FR-004**: La pantalla de confirmación DEBE ser legible por lectores de pantalla y presentar la información en lenguaje simple, sin jerga.
- **FR-005**: Cada botón de acción DEBE tener un área táctil de al menos 48x48 dp con separación mínima de 8 dp.
- **FR-006**: El texto base DEBE ser de al menos 18 sp y los montos de al menos 28 sp.
- **FR-007**: El contraste de texto DEBE ser de al menos 4.5:1 y el de iconos/bordes de al menos 3:1.
- **FR-008**: La interfaz DEBE funcionar correctamente con la letra del sistema al 200% sin desbordamiento ni pérdida de información.
- **FR-009**: Todos los elementos interactivos e informativos DEBEN tener etiquetas descriptivas en español para lectores de pantalla, con un orden de lectura lógico.
- **FR-010**: El botón "Volver" en cualquier paso DEBE regresar al paso anterior sin perder los datos ingresados por el usuario.
- **FR-011**: Los mensajes de error DEBEN explicar qué salió mal y qué puede hacer el usuario, en lenguaje sencillo (ej: "No tienes suficiente dinero" en vez de "Saldo insuficiente").
- **FR-012**: Las frases en la interfaz NO DEBEN superar 15 palabras. No se permite jerga bancaria ni términos como "token", "validar dispositivo" o "autenticación".
- **FR-013**: Los datos de cuentas, recibos y contactos DEBEN ser simulados (datos ficticios, sin conexión a banco real).
- **FR-014**: Ninguna acción DEBE depender exclusivamente de gestos, color o imágenes.
- **FR-015**: Los cambios de estado (pago realizado, dinero enviado) DEBEN anunciarse automáticamente para lectores de pantalla.

### Key Entities

- **Cuenta**: Representa la cuenta bancaria del usuario. Atributos clave: nombre del titular, saldo disponible, número de cuenta (enmascarado). Datos simulados.
- **Recibo**: Un recibo pendiente de pago asociado a un servicio. Atributos: nombre del servicio (ej: "Luz", "Agua"), monto a pagar, fecha de vencimiento. Datos simulados.
- **Contacto guardado**: Una persona a la que el usuario puede enviar dinero. Atributos: nombre, inicial o foto, identificador de cuenta destino (enmascarado). Datos simulados.
- **Operación**: Registro de un pago o transferencia. Atributos: tipo (pago/transferencia), destinatario, monto, fecha, estado (exitoso/fallido). Datos simulados.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El usuario puede completar cualquiera de las 4 acciones principales en 3 pasos o menos desde la pantalla principal.
- **SC-002**: El 90% de los usuarios de prueba (adultos mayores de 60 anos) completan la accion "ver saldo" en su primer intento sin pedir ayuda.
- **SC-003**: El 80% de los usuarios de prueba completan un pago de recibo o envio de dinero en su primer intento, incluyendo la confirmacion.
- **SC-004**: Un usuario ciego puede descubrir y activar las 4 acciones principales usando solo TalkBack, en menos de 2 minutos.
- **SC-005**: Ningun texto en la interfaz del Modo Facil supera las 15 palabras por frase.
- **SC-006**: Todas las pantallas pasan las verificaciones de area tactil minima (48x48 dp), contraste de texto (4.5:1) y etiquetas para lectores de pantalla.
- **SC-007**: Toda operacion que mueve dinero muestra una pantalla de confirmacion con destinatario y monto antes de ejecutarse, sin excepciones.
- **SC-008**: El tiempo promedio para completar "pagar recibo" o "enviar dinero" no supera los 90 segundos para un usuario nuevo.

## Assumptions

- Los usuarios objetivo son adultos mayores (60+ anos) en Peru, con diferentes niveles de vision y alfabetizacion digital, representados por los arquetipos Rosa (baja vision, miedo al error), Luis (ciego, usa TalkBack) y Carmen (dislexia, formularios densos).
- Todos los datos son ficticios y simulados localmente: no hay conexion a sistemas bancarios reales ni se procesan transacciones de verdad. Esto es un prototipo para hackathon.
- Los recibos pendientes vienen precargados en los datos simulados; el usuario no necesita buscar ni ingresar codigos de servicio.
- Los contactos guardados vienen precargados; agregar nuevos contactos esta fuera del alcance de esta feature.
- El Modo Facil es un modo dentro de la misma app, no una app separada, para evitar estigmatizar al usuario.
- El idioma de la interfaz es espanol peruano neutro.
- La feature no incluye el asistente de voz/IA (es una feature separada) ni el escudo antifraude; se enfoca exclusivamente en las 4 acciones de la pantalla principal y sus flujos.
- La confirmacion de operaciones monetarias en el prototipo usa un boton de confirmar. La confirmacion biometrica (huella) es parte de una feature de seguridad separada.

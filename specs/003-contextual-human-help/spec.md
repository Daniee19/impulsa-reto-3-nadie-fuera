# Feature Specification: Ayuda Humana con Contexto

**Feature Branch**: `003-contextual-human-help`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Desde cualquier pantalla, con un solo toque, el usuario pide ayuda y elige a quién acudir: su persona de confianza o un asesor del banco. Quien ayuda ya recibe en qué pantalla y paso se quedó trabado y qué operación intentaba, para que el usuario no tenga que explicar nada. Reemplaza el botón 'pedir ayuda' simulado del Modo Fácil."

**Depends on**: [specs/001-easy-mode](../001-easy-mode/spec.md) — reemplaza el botón "Pedir ayuda" simulado de la pantalla principal. [specs/002-fraud-shield](../002-fraud-shield/spec.md) — comparte la entidad "persona de confianza".

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rosa se traba pagando un recibo y pide ayuda a su hija (Priority: P1)

Rosa está en el paso 2 del flujo "Pagar recibo" (seleccionó el recibo, ahora ve la pantalla de confirmación) pero no entiende algo y se asusta. Toca el botón "Pedir ayuda" que está siempre visible. Ve dos opciones: "Llamar a Valeria" (su persona de confianza) o "Llamar al banco". Elige a Valeria. Valeria recibe una llamada (simulada) junto con el contexto: "Rosa está pagando un recibo de luz por S/ 120 y se trabó en la confirmación del pago." Valeria le explica qué hacer. Rosa no tuvo que explicar nada.

**Why this priority**: La ayuda humana es la red de seguridad que hace posible que Rosa se atreva a usar la app. Sin ella, el miedo al error paraliza. Que la persona que ayuda ya sepa el contexto elimina la frustración de "tener que explicar todo desde cero", que es una barrera real reportada (~91,000 llamadas/mes al banco).

**Independent Test**: Se puede probar tocando "Pedir ayuda" durante cualquier flujo y verificando que el contexto enviado refleja la pantalla y paso actuales. Entrega valor: el usuario obtiene ayuda inmediata sin repetirse.

**Acceptance Scenarios**:

1. **Given** el usuario está en cualquier pantalla de la app, **When** toca "Pedir ayuda", **Then** ve una pantalla con las opciones de contacto disponibles: persona de confianza (si está registrada) y asesor del banco.
2. **Given** el usuario elige contactar a su persona de confianza, **When** se inicia la comunicación (simulada), **Then** la persona de confianza recibe el contexto automáticamente: nombre de la pantalla actual, paso en el que se encuentra, y operación en curso (si aplica), incluyendo monto y destinatario.
3. **Given** el usuario estaba en medio de un flujo (pagar recibo, enviar dinero), **When** pide ayuda, **Then** su progreso en el flujo se conserva: al volver de la ayuda, retoma donde se quedó sin perder datos.
4. **Given** el usuario elige llamar a su persona de confianza, **When** selecciona "Llamar a Valeria", **Then** ve las opciones de comunicación: llamada o chat.

---

### User Story 2 - Luis pide ayuda al asesor del banco con videollamada e intérprete (Priority: P1)

Luis es ciego y también tiene discapacidad auditiva parcial. Está en la pantalla principal del Modo Fácil y necesita ayuda general. Toca "Pedir ayuda" (que TalkBack anuncia). Elige "Hablar con el banco". Ve tres opciones: llamar, chatear, o videollamada con intérprete de lengua de señas. Elige videollamada. El asesor (simulado) recibe que Luis está en la pantalla principal del Modo Fácil y no tiene operación en curso.

**Why this priority**: La videollamada con intérprete de lengua de señas peruana responde directamente al reclamo #037 de discapacidad auditiva mencionado en la guía técnica. Es un diferenciador de accesibilidad exigido por la Ley 29973. Que el asesor ya tenga el contexto cumple la promesa de "no repetir nada".

**Independent Test**: Se puede probar activando TalkBack, tocando "Pedir ayuda", eligiendo asesor del banco y videollamada. El asesor simulado recibe el contexto correcto. Entrega valor: un usuario con discapacidad auditiva accede a ayuda en su idioma.

**Acceptance Scenarios**:

1. **Given** el usuario elige contactar al asesor del banco, **When** ve las opciones de comunicación, **Then** se presentan tres canales: llamada, chat y videollamada con intérprete de lengua de señas.
2. **Given** el usuario elige videollamada con intérprete, **When** se inicia la conexión (simulada), **Then** ve una pantalla que indica "Te estamos conectando con un asesor e intérprete de lengua de señas" y el asesor simulado recibe el contexto del usuario.
3. **Given** el usuario usa TalkBack, **When** navega las opciones de ayuda, **Then** cada opción se anuncia claramente incluyendo "Videollamada con intérprete de lengua de señas".

---

### User Story 3 - El familiar no responde y se ofrece el asesor (Priority: P2)

Carmen intenta contactar a su persona de confianza (su sobrino) pero él no responde. Después de un tiempo breve de espera, la app le dice: "Tu persona de confianza no respondió. ¿Quieres hablar con un asesor del banco?" Carmen acepta y se conecta con el asesor, quien ya tiene el mismo contexto que se le habría enviado al sobrino.

**Why this priority**: Es P2 porque depende del flujo principal (P1) y cubre un escenario de respaldo. Sin embargo, es esencial porque sin él, el usuario se queda sin ayuda si su familiar no está disponible.

**Independent Test**: Se puede probar simulando que la persona de confianza no responde (timeout) y verificando que se ofrece el asesor como alternativa con el contexto preservado.

**Acceptance Scenarios**:

1. **Given** el usuario eligió contactar a su persona de confianza, **When** la persona no responde en un tiempo razonable (simulado), **Then** la app muestra un mensaje: "No pudimos comunicarte con [nombre]. ¿Quieres hablar con un asesor del banco?" con opciones de "Sí" y "Volver".
2. **Given** el usuario acepta hablar con el asesor después del fallback, **When** se conecta con el asesor, **Then** el asesor recibe el mismo contexto completo (pantalla, paso, operación).

---

### User Story 4 - Consentimiento para compartir contexto con el familiar (Priority: P1)

La primera vez que Rosa registra a Valeria como persona de confianza (fuera del alcance de esta feature, pero el consentimiento sí lo es), la app le explica en lenguaje simple: "Cuando pidas ayuda a Valeria, ella podrá ver en qué parte de la app estás y qué estás intentando hacer. Valeria no podrá hacer pagos ni ver tus contraseñas." Rosa acepta. Este consentimiento queda registrado y puede revocarse.

**Why this priority**: P1 porque la privacidad es un requisito legal (Ley 29733) y un principio de la constitución del proyecto. Sin consentimiento, no se puede compartir contexto con el familiar. El asesor del banco opera bajo la relación contractual existente y no requiere consentimiento adicional para recibir contexto operativo.

**Independent Test**: Se puede probar verificando que sin consentimiento activo, el familiar no recibe contexto (solo se inicia la comunicación). Entrega valor: protección de la privacidad del usuario sin impedirle recibir ayuda.

**Acceptance Scenarios**:

1. **Given** el usuario tiene persona de confianza registrada pero no ha dado consentimiento para compartir contexto, **When** pide ayuda y elige a su persona de confianza, **Then** se le muestra la pantalla de consentimiento antes de iniciar la comunicación.
2. **Given** el usuario da consentimiento, **When** pide ayuda al familiar en el futuro, **Then** el contexto se comparte automáticamente sin volver a pedir permiso.
3. **Given** el usuario quiere revocar el consentimiento, **When** accede a la configuración de persona de confianza, **Then** puede desactivar el envío de contexto. A partir de ese momento, el familiar solo recibe la llamada o chat pero sin información de pantalla ni operación.
4. **Given** el consentimiento no fue otorgado, **When** el familiar recibe la comunicación, **Then** solo ve "Rosa necesita ayuda" sin detalles de pantalla, paso u operación.

---

### User Story 5 - Pedir ayuda desde la pantalla principal sin operación en curso (Priority: P2)

Rosa no está haciendo nada en particular, solo está en la pantalla principal del Modo Fácil, pero quiere preguntar algo general. Toca "Pedir ayuda". El contexto enviado dice: "Rosa está en la pantalla principal y no tiene una operación en curso." Esto le da al asesor o familiar suficiente información para saber que es una consulta general, no un problema en medio de un pago.

**Why this priority**: P2 porque es un escenario válido pero menos crítico que la ayuda en medio de un flujo. El botón de ayuda debe funcionar siempre, no solo cuando hay un problema.

**Independent Test**: Se puede probar tocando "Pedir ayuda" desde la pantalla principal sin haber iniciado ningún flujo. Entrega valor: acceso a ayuda en cualquier momento.

**Acceptance Scenarios**:

1. **Given** el usuario está en la pantalla principal sin operación en curso, **When** toca "Pedir ayuda", **Then** ve las mismas opciones de contacto y el contexto enviado indica "pantalla principal, sin operación en curso".

---

### Edge Cases

- Que pasa si el usuario no tiene persona de confianza registrada? Solo se muestra la opción de asesor del banco. No se muestra un espacio vacío ni un error.
- Que pasa si el usuario pide ayuda durante la pantalla de alerta del escudo antifraude (002-fraud-shield)? El contexto incluye que estaba en una alerta de seguridad, la operación que la disparó, y las reglas activadas. El familiar o asesor recibe: "Rosa está viendo una alerta de seguridad sobre un pago de S/ 850 al recibo de luz."
- Que pasa si el usuario pide ayuda y luego cancela antes de conectar? Vuelve exactamente donde estaba, con todos los datos preservados.
- Que pasa si el usuario está en la pantalla de "Ver saldo" y pide ayuda? El contexto dice "Rosa está viendo su saldo" — funciona igual, aunque no hay operación monetaria en curso.
- Que pasa si el familiar intenta ejecutar una operación por el usuario? No es posible: el familiar solo recibe contexto de lectura. No tiene acceso a la cuenta ni puede confirmar pagos, transferencias o cualquier acción.
- Que pasa si la comunicación se corta durante la ayuda? El usuario ve un mensaje: "Se cortó la comunicación. ¿Quieres intentar de nuevo?" con opción de reintentar o volver a la app.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Un botón "Pedir ayuda" DEBE estar visible y accesible desde cualquier pantalla de la app, con un solo toque.
- **FR-002**: Al tocar "Pedir ayuda", el usuario DEBE ver las opciones de contacto disponibles: persona de confianza (si está registrada y tiene consentimiento) y asesor del banco.
- **FR-003**: Para contactar a la persona de confianza, el usuario DEBE poder elegir entre llamada y chat.
- **FR-004**: Para contactar al asesor del banco, el usuario DEBE poder elegir entre llamada, chat y videollamada con intérprete de lengua de señas peruana.
- **FR-005**: Al iniciar cualquier canal de ayuda, el sistema DEBE enviar automáticamente el contexto del usuario: pantalla actual, paso dentro del flujo (si aplica), y operación en curso con sus datos (tipo, monto, destinatario, si aplica).
- **FR-006**: El contexto enviado al familiar o asesor DEBE ser real (reflejar la pantalla y paso actuales del usuario), no simulado, incluso en el prototipo.
- **FR-007**: El familiar DEBE recibir contexto SOLO si el usuario ha dado consentimiento explícito previo para compartirlo. Sin consentimiento, el familiar solo recibe la comunicación sin detalles de contexto.
- **FR-008**: El consentimiento para compartir contexto DEBE poder revocarse en cualquier momento desde la configuración de persona de confianza.
- **FR-009**: La persona de confianza NUNCA DEBE poder ejecutar operaciones (pagos, transferencias, cambios de configuración) en nombre del usuario. Su acceso es de lectura de contexto solamente.
- **FR-010**: Si la persona de confianza no responde en un tiempo razonable, el sistema DEBE ofrecer al usuario la alternativa de contactar al asesor del banco, con el mismo contexto.
- **FR-011**: Al pedir ayuda durante un flujo en curso, el progreso del usuario DEBE preservarse: al volver de la ayuda, retoma en el mismo paso con los mismos datos ingresados.
- **FR-012**: El botón "Pedir ayuda" DEBE cumplir los requisitos de accesibilidad: área táctil de al menos 48x48 dp, contraste de 4.5:1, etiqueta descriptiva para lectores de pantalla, y anuncio al recibir foco.
- **FR-013**: Los mensajes de la pantalla de ayuda DEBEN usar lenguaje simple (frases de máximo 15 palabras, sin jerga).
- **FR-014**: Esta feature REEMPLAZA el botón "Pedir ayuda" simulado definido en la User Story 4 de 001-easy-mode.
- **FR-015**: Para el prototipo, las conexiones (llamada, chat, videollamada) son simuladas, pero el paquete de contexto enviado (pantalla, paso, operación) DEBE contener datos reales de la sesión del usuario.
- **FR-016**: El contexto compartido NUNCA DEBE incluir contraseñas, PIN, datos biométricos ni número de cuenta completo del usuario.

### Key Entities

- **Paquete de contexto**: Información recopilada automáticamente cuando el usuario pide ayuda. Atributos: pantalla actual, paso dentro del flujo (si aplica), tipo de operación en curso (si aplica), monto (si aplica), destinatario (si aplica), hora de la solicitud. Nunca incluye contraseñas, PIN ni datos biométricos.
- **Persona de confianza**: Familiar o persona cercana registrada (compartida con 002-fraud-shield). Atributos: nombre, relación, canales disponibles (llamada, chat), consentimiento de contexto (sí/no). Una sola persona por usuario. Datos simulados en el prototipo.
- **Asesor del banco**: Representante de atención al cliente. Canales disponibles: llamada, chat, videollamada con intérprete de lengua de señas. Simulado en el prototipo.
- **Consentimiento de contexto**: Registro de si el usuario autorizó compartir el paquete de contexto con su persona de confianza. Atributos: estado (otorgado/revocado), fecha de última modificación. Revocable en cualquier momento.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El usuario puede iniciar una solicitud de ayuda desde cualquier pantalla en máximo 2 toques (1 para el botón + 1 para elegir a quién contactar).
- **SC-002**: El 100% de las solicitudes de ayuda enviadas incluyen el contexto correcto (pantalla actual, paso y operación en curso) verificable contra el estado real de la sesión.
- **SC-003**: El 90% de los usuarios de prueba (adultos mayores de 60 anos) logran pedir ayuda y elegir un canal de contacto sin asistencia externa.
- **SC-004**: El progreso del flujo se preserva en el 100% de los casos al volver de una solicitud de ayuda.
- **SC-005**: Un usuario ciego puede descubrir y activar el botón de ayuda usando solo lector de pantalla en menos de 30 segundos desde cualquier pantalla.
- **SC-006**: El fallback a asesor del banco se ofrece en el 100% de los casos donde la persona de confianza no responde.
- **SC-007**: El contexto compartido nunca incluye datos sensibles (contraseñas, PIN, datos biométricos, números de cuenta completos) en ningún escenario verificado.
- **SC-008**: El 85% de los usuarios de prueba reportan sentirse "acompañados" o "seguros" al saber que pueden pedir ayuda en cualquier momento.

## Assumptions

- La persona de confianza es la misma entidad definida en 002-fraud-shield: un solo contacto por usuario, precargado en datos simulados. El flujo de registro de la persona de confianza está fuera del alcance de esta feature.
- En el prototipo, las llamadas, chats y videollamadas son simuladas (se muestra una pantalla de "conexión en curso" y un mensaje de confirmación, pero no hay comunicación real).
- El paquete de contexto sí debe contener datos reales de la sesión (pantalla, paso, operación) aunque las conexiones sean simuladas. Esto demuestra la viabilidad técnica al panel evaluador.
- La videollamada con intérprete de lengua de señas peruana es una opción simulada en el prototipo. Se muestra la opción y una pantalla de conexión simulada para demostrar el concepto.
- El consentimiento para compartir contexto con el familiar se gestiona mediante una pantalla simple de aceptación/rechazo. No se requiere firma digital ni verificación de identidad para el prototipo.
- El asesor del banco opera bajo la relación contractual existente entre el usuario y el banco, por lo que recibir contexto operativo no requiere consentimiento adicional (es parte del servicio de atención al cliente).
- El timeout para considerar que la persona de confianza "no respondió" es de 60 segundos (simulado).
- El botón "Pedir ayuda" reemplaza completamente la User Story 4 de 001-easy-mode, que era una implementación simulada sin contexto ni canales reales.

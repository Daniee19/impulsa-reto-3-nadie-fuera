# Feature Specification: Persona de Confianza con Permisos Limitados

**Feature Branch**: `006-trusted-person`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "El usuario registra a un familiar de confianza y decide qué puede hacer: recibir avisos de operaciones inusuales, recibir pedidos de ayuda con contexto y ayudar a configurar la app. El familiar nunca ve el saldo completo ni los movimientos sin permiso, no accede a la cuenta y no puede ejecutar operaciones."

**Depends on**: [specs/002-fraud-shield](../002-fraud-shield/spec.md) — la persona de confianza recibe avisos de operaciones inusuales. [specs/003-contextual-human-help](../003-contextual-human-help/spec.md) — la persona de confianza recibe pedidos de ayuda con contexto. Esta feature formaliza el registro y gestión de permisos de la entidad "persona de confianza" que 002 y 003 ya usan de forma simulada.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rosa registra a Valeria como persona de confianza (Priority: P1)

Rosa quiere que su hija Valeria la ayude con la app. Desde la configuración del Modo Fácil, toca "Mi persona de confianza". Ve una explicación simple: "Tu persona de confianza puede ayudarte, pero no puede tocar tu dinero." Rosa ingresa el nombre y teléfono de Valeria, y elige qué permisos darle. Todo está explicado en frases cortas y sin jerga. Rosa confirma y Valeria queda registrada.

**Why this priority**: Sin el registro, las features 002 (escudo antifraude) y 003 (ayuda con contexto) no tienen a quién notificar. Es el paso fundacional que habilita la red de apoyo del usuario.

**Independent Test**: Se puede probar abriendo la configuración de persona de confianza, registrando un contacto y verificando que queda guardado con los permisos seleccionados. Entrega valor: el usuario tiene una red de seguridad configurada.

**Acceptance Scenarios**:

1. **Given** el usuario no tiene persona de confianza registrada, **When** accede a "Mi persona de confianza" desde la configuración, **Then** ve una explicación clara de qué es una persona de confianza y qué puede (y no puede) hacer.
2. **Given** el usuario inicia el registro, **When** ingresa nombre y teléfono del familiar, **Then** puede seleccionar los permisos que quiere otorgar de una lista clara.
3. **Given** el usuario completó el registro, **When** confirma, **Then** la persona de confianza queda guardada y los permisos seleccionados están activos.
4. **Given** el usuario ya tiene persona de confianza, **When** accede a "Mi persona de confianza", **Then** ve el nombre del familiar registrado y sus permisos actuales.

---

### User Story 2 - Rosa elige los permisos de Valeria (Priority: P1)

Durante el registro (o después, desde la configuración), Rosa ve tres permisos que puede activar o desactivar individualmente:

- **Avisos de seguridad**: Valeria recibe un aviso cuando la app detecta una operación inusual (escudo antifraude).
- **Pedidos de ayuda**: Cuando Rosa pide ayuda, puede elegir contactar a Valeria y ella recibe el contexto de dónde se trabó.
- **Ayudar a configurar**: Valeria puede sugerirle cambios de configuración a Rosa (tamaño de letra, agregar contactos, agregar recibos), pero Rosa siempre tiene que aprobar cada cambio.

Cada permiso tiene una explicación de una línea. Rosa activa los tres. Más tarde, decide quitar "Avisos de seguridad" porque Valeria se preocupa demasiado. Lo desactiva con un toque.

**Why this priority**: Los permisos granulares son lo que distingue esta feature de un simple "acceso de familiar". Respeta la autonomía de Rosa (principio clave del proyecto: "Valeria recibe avisos y ayuda a configurar, pero no tiene acceso a la cuenta. Respeta la autonomía de su mamá").

**Independent Test**: Se puede probar activando/desactivando cada permiso y verificando que el comportamiento del sistema cambia según corresponde.

**Acceptance Scenarios**:

1. **Given** el usuario está registrando o editando a su persona de confianza, **When** ve la lista de permisos, **Then** cada permiso tiene un nombre claro, una explicación de una línea, y un control para activar/desactivar.
2. **Given** el usuario desactiva "Avisos de seguridad", **When** el escudo antifraude se activa en una operación futura, **Then** la opción "Consultar a mi persona de confianza" no aparece en la pantalla de alerta.
3. **Given** el usuario desactiva "Pedidos de ayuda", **When** pide ayuda desde cualquier pantalla, **Then** solo se muestra la opción de asesor del banco, no la persona de confianza.
4. **Given** el usuario activa "Ayudar a configurar", **When** el familiar envía una sugerencia de configuración (simulada), **Then** Rosa ve la sugerencia y debe aprobarla explícitamente antes de que se aplique.

---

### User Story 3 - Valeria sugiere un cambio de configuración (Priority: P2)

Valeria nota que su mamá Rosa tiene la letra muy pequeña. Desde su lado (simulado en el prototipo), envía una sugerencia: "Aumentar el tamaño de letra." Rosa recibe un aviso: "Valeria te sugiere hacer la letra más grande. ¿Quieres aceptar?" Rosa puede aceptar o rechazar. Si acepta, el cambio se aplica. Si rechaza, no pasa nada y Valeria no se entera del rechazo. Valeria nunca puede forzar un cambio.

**Why this priority**: P2 porque es un diferenciador de Nivel 2, no un flujo crítico. Pero es lo que hace tangible la promesa de "ayudar a configurar sin controlar". El patrón de sugerencia-aprobación respeta la autonomía del adulto mayor.

**Independent Test**: Se puede probar simulando una sugerencia del familiar y verificando que el usuario la recibe, puede aceptar o rechazar, y que el cambio solo se aplica con aprobación.

**Acceptance Scenarios**:

1. **Given** el familiar tiene permiso "Ayudar a configurar" activo, **When** envía una sugerencia de configuración (simulada), **Then** el usuario ve un aviso con la sugerencia explicada en lenguaje simple y opciones de "Aceptar" y "No, gracias".
2. **Given** el usuario acepta la sugerencia, **When** confirma, **Then** el cambio de configuración se aplica inmediatamente y el usuario ve una confirmación.
3. **Given** el usuario rechaza la sugerencia, **When** toca "No, gracias", **Then** no se aplica ningún cambio y la sugerencia desaparece.
4. **Given** el familiar no tiene permiso "Ayudar a configurar", **When** intenta enviar una sugerencia, **Then** el sistema no lo permite (simulado: la opción no aparece).

---

### User Story 4 - Rosa cambia de persona de confianza (Priority: P2)

Rosa decide que quiere que su sobrino Carlos la ayude en vez de Valeria. Desde la configuración de persona de confianza, toca "Cambiar persona de confianza". La app le explica: "Vas a quitar a Valeria y registrar a otra persona. Valeria dejará de recibir avisos y ya no podrá ayudarte desde la app." Rosa confirma, ingresa los datos de Carlos, y elige los permisos.

**Why this priority**: P2 porque no es el flujo principal, pero es necesario para que el usuario no se quede atrapado con una persona de confianza que ya no desea.

**Independent Test**: Se puede probar cambiando la persona de confianza y verificando que la anterior pierde todos los permisos y la nueva los recibe.

**Acceptance Scenarios**:

1. **Given** el usuario tiene persona de confianza registrada, **When** toca "Cambiar persona de confianza", **Then** ve una explicación de lo que va a pasar (la anterior pierde acceso) y debe confirmar antes de continuar.
2. **Given** el usuario confirma el cambio, **When** registra a la nueva persona, **Then** la anterior pierde todos los permisos inmediatamente y la nueva recibe los permisos que el usuario seleccione.

---

### User Story 5 - Rosa quita a su persona de confianza (Priority: P3)

Rosa decide que no quiere persona de confianza. Desde la configuración, toca "Quitar persona de confianza". La app le explica las consecuencias: "Ya no recibirás ayuda de Valeria cuando la app detecte algo inusual." Rosa confirma y Valeria queda desvinculada.

**Why this priority**: P3 porque es menos frecuente, pero el control total del usuario es un principio del proyecto.

**Independent Test**: Se puede probar quitando la persona de confianza y verificando que las features 002 y 003 funcionan sin ella (solo muestran opción de asesor).

**Acceptance Scenarios**:

1. **Given** el usuario quiere quitar a su persona de confianza, **When** toca "Quitar" y confirma, **Then** la persona de confianza se elimina, todos los permisos se revocan, y las features 002/003 dejan de mostrar la opción del familiar.
2. **Given** el usuario quitó a su persona de confianza, **When** usa el escudo antifraude o pide ayuda, **Then** solo ve las opciones de cancelar/continuar (escudo) o asesor del banco (ayuda).

---

### Edge Cases

- Que pasa si el usuario intenta registrarse a sí mismo como persona de confianza? No se permite: la persona de confianza debe ser un contacto distinto al titular.
- Que pasa si el familiar intenta ver el saldo o los movimientos? No puede: no tiene acceso a la cuenta ni a datos financieros a menos que se los comparta explícitamente a través del contexto de ayuda (y solo si ese permiso está activo).
- Que pasa si el familiar intenta ejecutar un pago o transferencia? No puede: la persona de confianza no tiene ningún control operativo sobre la cuenta. Solo recibe información (avisos, contexto) y puede sugerir configuración, nunca ejecutar.
- Que pasa si el usuario no quiere dar ningún permiso? Puede registrar a la persona de confianza sin activar ningún permiso. En ese caso, es como no tenerla hasta que active alguno.
- Que pasa si el familiar recibe un aviso del escudo antifraude pero el usuario ya canceló la operación? El aviso incluye una nota: "Rosa decidió cancelar esta operación."
- Que pasa si se envía una sugerencia de configuración pero el usuario no la ve de inmediato? La sugerencia queda pendiente hasta que el usuario la revise. No caduca ni se aplica automáticamente.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El usuario DEBE poder registrar exactamente una persona de confianza desde la configuración del Modo Fácil, proporcionando nombre y teléfono.
- **FR-002**: Durante y después del registro, el usuario DEBE poder activar o desactivar individualmente tres permisos: avisos de seguridad (escudo antifraude), pedidos de ayuda (ayuda con contexto), y ayudar a configurar (sugerencias de configuración).
- **FR-003**: Cada permiso DEBE tener una explicación de una línea en lenguaje simple, visible junto al control de activación.
- **FR-004**: La persona de confianza NUNCA DEBE poder ver el saldo, los movimientos ni datos financieros del usuario, excepto lo que se comparta explícitamente a través del contexto de ayuda (003) cuando ese permiso esté activo.
- **FR-005**: La persona de confianza NUNCA DEBE poder ejecutar operaciones (pagos, transferencias, cambios de cuenta) en nombre del usuario.
- **FR-006**: Las sugerencias de configuración del familiar DEBEN requerir aprobación explícita del usuario antes de aplicarse. Las configuraciones sugeribles son: tamaño de letra, agregar/quitar contactos guardados, y agregar/quitar recibos frecuentes.
- **FR-007**: El usuario DEBE poder cambiar su persona de confianza en cualquier momento. Al cambiar, la anterior pierde todos los permisos inmediatamente.
- **FR-008**: El usuario DEBE poder quitar a su persona de confianza en cualquier momento, revocando todos los permisos.
- **FR-009**: Antes de cambiar o quitar a la persona de confianza, el sistema DEBE mostrar una explicación clara de las consecuencias y pedir confirmación.
- **FR-010**: Cuando el permiso "Avisos de seguridad" está desactivado, la opción "Consultar a mi persona de confianza" NO DEBE aparecer en las alertas del escudo antifraude (002).
- **FR-011**: Cuando el permiso "Pedidos de ayuda" está desactivado, la persona de confianza NO DEBE aparecer como opción de contacto en Ayuda humana con contexto (003).
- **FR-012**: El registro y la gestión de permisos DEBEN explicarse en lenguaje simple (frases de máximo 15 palabras, sin jerga) y DEBEN cumplir los requisitos de accesibilidad (48x48 dp, contraste 4.5:1, etiquetas para lector de pantalla).
- **FR-013**: El consentimiento para compartir información con la persona de confianza DEBE ser explícito y específico por permiso, cumpliendo la Ley 29733.
- **FR-014**: Para el prototipo, la persona de confianza, sus notificaciones y las sugerencias de configuración son simuladas. Los datos del familiar son ficticios.

### Key Entities

- **Persona de confianza**: Familiar o persona cercana registrada por el usuario. Atributos: nombre, teléfono, relación (informativo), permisos activos. Una sola persona por usuario. Solo recibe información y sugiere configuración; nunca opera la cuenta.
- **Permiso**: Autorización granular que el usuario otorga a su persona de confianza. Tipos: avisos de seguridad, pedidos de ayuda, ayudar a configurar. Cada uno se activa/desactiva independientemente.
- **Sugerencia de configuración**: Propuesta del familiar para cambiar un ajuste de la app del usuario. Atributos: tipo de cambio (tamaño de letra, contacto, recibo), valor sugerido, estado (pendiente/aceptada/rechazada). Requiere aprobación explícita del usuario.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 90% de los usuarios de prueba (adultos mayores de 60 anos) completan el registro de su persona de confianza sin asistencia, en menos de 3 minutos.
- **SC-002**: El 100% de los permisos se pueden activar y desactivar individualmente, y su efecto es inmediato en las features 002 y 003.
- **SC-003**: La persona de confianza no puede ver el saldo, movimientos ni ejecutar operaciones en ningún escenario verificado.
- **SC-004**: El 100% de las sugerencias de configuración requieren aprobación explícita del usuario antes de aplicarse; ninguna se aplica automáticamente.
- **SC-005**: El 90% de los usuarios de prueba entienden qué puede y qué no puede hacer su persona de confianza, verificado con una pregunta directa después del registro.
- **SC-006**: El usuario puede cambiar o quitar a su persona de confianza en máximo 2 minutos.
- **SC-007**: El 85% de los usuarios de prueba reportan que la persona de confianza los hace sentir "más seguros" sin sentirse "controlados".

## Assumptions

- Solo una persona de confianza por usuario, consistente con lo establecido en 002 y 003.
- El familiar registrado aquí es el mismo que recibe avisos del escudo antifraude (002) y que aparece como opción en ayuda humana con contexto (003). Esta feature formaliza su registro y gestión de permisos; 002 y 003 consumen esa información.
- Las configuraciones sugeribles por el familiar se limitan a: tamaño de letra, contactos guardados y recibos frecuentes. No incluye cambios de seguridad (PIN, huella, sesión).
- En el prototipo, todo lo del lado del familiar es simulado: no hay una app o interfaz real para el familiar. Las notificaciones y sugerencias se simulan desde el lado del usuario.
- El consentimiento se gestiona permiso por permiso (granular) y cumple con la Ley 29733 de protección de datos personales.
- El familiar no se entera si el usuario rechaza una sugerencia de configuración, para evitar presión social.
- Quitar a la persona de confianza es inmediato y revoca todos los permisos sin periodo de gracia.

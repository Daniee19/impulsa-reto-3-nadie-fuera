# Feature Specification: Desbloqueo Gradual de Funciones

**Feature Branch**: `009-gradual-unlock`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "El usuario empieza con las 4 acciones del Modo Fácil. Cuando demuestra confianza, la app le propone activar una nueva función. Cada función nueva se presenta con explicación y opción de practicarla primero. El usuario puede volver a la vista simple cuando quiera."

**Depends on**: [specs/001-easy-mode](../001-easy-mode/spec.md) — las 4 acciones iniciales. [specs/008-practice-mode](../008-practice-mode/spec.md) — las funciones nuevas se pueden practicar antes de activarlas.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rosa recibe una propuesta de nueva función (Priority: P1)

Rosa ha pagado 5 recibos y hecho 3 transferencias en las últimas dos semanas sin pedir ayuda. La app le muestra una propuesta amable al abrir el Modo Fácil: "Ya manejas bien tus pagos. ¿Quieres ver también tus movimientos recientes?" Con tres opciones: "Sí, actívalo", "Primero quiero practicarlo" y "No, por ahora no". Rosa elige practicarlo primero. La app la lleva al modo práctica (008) donde prueba la nueva función con datos ficticios. Después de practicar, Rosa decide activarla. Un quinto botón aparece en su Modo Fácil: "Ver movimientos".

**Why this priority**: Es el flujo principal de la feature. La propuesta no intrusiva respeta la autonomía del usuario y la opción de practicar antes reduce el miedo a lo nuevo. La guía técnica dice: "Empieza con 4 acciones y propone más cuando el usuario gana confianza."

**Independent Test**: Se puede probar simulando las condiciones de confianza y verificando que aparece la propuesta con las tres opciones. Entrega valor: el usuario expande sus capacidades a su propio ritmo.

**Acceptance Scenarios**:

1. **Given** el usuario cumple las condiciones de confianza para una función nueva, **When** abre el Modo Fácil, **Then** ve una propuesta amable con el nombre de la función, una explicación de una línea, y tres opciones: activar, practicar primero, o rechazar.
2. **Given** el usuario elige "Primero quiero practicarlo", **When** se activa el modo práctica, **Then** la práctica incluye la nueva función con datos ficticios y guía opcional.
3. **Given** el usuario elige "Sí, actívalo", **When** la función se activa, **Then** un nuevo botón aparece en la pantalla principal del Modo Fácil, con la misma estética (grande, claro, accesible) que los 4 originales.
4. **Given** el usuario elige "No, por ahora no", **When** descarta la propuesta, **Then** la propuesta no vuelve a aparecer hasta la próxima vez que abra la app (no insiste en la misma sesión).

---

### User Story 2 - Rosa vuelve a la vista simple (Priority: P1)

Rosa activó "Ver movimientos" y "Recargar celular", así que tiene 6 botones en su Modo Fácil. Un día se siente abrumada y quiere volver a lo simple. Desde la configuración, toca "Volver a solo 4 acciones". La app le explica: "Vas a ocultar las funciones extra. Puedes volver a activarlas cuando quieras." Rosa confirma y vuelve a ver solo los 4 botones originales. Las funciones extra no se eliminan, solo se ocultan.

**Why this priority**: P1 porque el control total del usuario es un principio del proyecto. Si el usuario no puede simplificar, el desbloqueo gradual se convierte en complejidad acumulada, exactamente lo opuesto a lo que busca el Modo Fácil.

**Independent Test**: Se puede probar activando funciones extra, luego eligiendo "Volver a solo 4 acciones", y verificando que los botones extra desaparecen pero pueden reactivarse.

**Acceptance Scenarios**:

1. **Given** el usuario tiene funciones extra activadas, **When** toca "Volver a solo 4 acciones" en configuración, **Then** ve una explicación de lo que pasará y debe confirmar.
2. **Given** el usuario confirma, **When** vuelve a la pantalla principal, **Then** solo ve los 4 botones originales del Modo Fácil.
3. **Given** el usuario ocultó funciones extra, **When** accede a configuración, **Then** puede reactivar individualmente las funciones que ya había desbloqueado sin tener que cumplir las condiciones de confianza de nuevo.

---

### User Story 3 - La propuesta respeta el límite de acciones por pantalla (Priority: P1)

Rosa ya tiene 4 acciones originales más 3 extra activadas (7 en total). La app detecta que se cumplieron condiciones para otra función, pero no la propone porque la constitución del proyecto establece un máximo de 4 acciones primarias por pantalla. En vez de una octava acción, la app organiza las funciones extra en una segunda fila o sección accesible, manteniendo siempre las 4 originales como acciones principales.

**Why this priority**: P1 porque la accesibilidad y la simplicidad son principios innegociables. Saturar la pantalla principal con demasiados botones destruye la propuesta de valor del Modo Fácil.

**Independent Test**: Se puede probar activando múltiples funciones y verificando que la pantalla nunca muestra más de lo que es visualmente manejable, con las 4 originales siempre prominentes.

**Acceptance Scenarios**:

1. **Given** el usuario tiene más de 4 funciones activas (originales + extras), **When** ve la pantalla principal, **Then** las 4 acciones originales se muestran como acciones principales y las extras se agrupan en una sección secundaria accesible ("Más funciones").
2. **Given** la sección "Más funciones" existe, **When** el usuario la abre, **Then** ve las funciones extra con la misma estética accesible (botones grandes, contraste, etiquetas).

---

### User Story 4 - Luis recibe la propuesta y la entiende con TalkBack (Priority: P2)

Luis, que es ciego, abre la app y TalkBack le anuncia la propuesta: "Tienes una sugerencia. Ya manejas bien tus pagos. ¿Quieres ver también tus movimientos recientes? Opciones: Activar, Practicar primero, o No por ahora." Luis elige con TalkBack y el flujo funciona igual que para un usuario vidente.

**Why this priority**: P2 porque la accesibilidad de las propuestas es un requisito transversal (005-screen-reader-audit), pero merece un escenario específico aquí para garantizar que la interacción de propuesta-decisión funciona con lector de pantalla.

**Independent Test**: Se puede probar con TalkBack activado, verificando que la propuesta se anuncia y las opciones se navegan.

**Acceptance Scenarios**:

1. **Given** el usuario tiene TalkBack activo, **When** aparece una propuesta de nueva función, **Then** TalkBack anuncia la propuesta completa y las tres opciones de forma clara y navegable.

---

### Edge Cases

- Que pasa si el usuario nunca cumple las condiciones de confianza? Sigue con las 4 acciones originales indefinidamente. El Modo Fácil funciona completo sin funciones extra.
- Que pasa si el usuario rechaza todas las propuestas? La app deja de proponer después de 3 rechazos consecutivos a la misma función. El usuario puede explorar funciones disponibles manualmente desde configuración.
- Que pasa si se desbloquean dos funciones al mismo tiempo? Se propone una a la vez, la de mayor prioridad primero. La segunda se propone en la siguiente sesión.
- Que pasa si el usuario desactiva una función extra y luego quiere reactivarla? Puede hacerlo desde configuración sin cumplir condiciones de nuevo. La función ya fue desbloqueada; ocultar no es desbloquear.
- Que pasa si una función extra necesita datos que no existen en el prototipo? Las funciones extra son simuladas con datos ficticios, igual que el resto del prototipo.
- Que pasa si el usuario activa muchas funciones y la pantalla se complica? Las 4 originales siempre se mantienen como principales. Las extras van en una sección "Más funciones" para evitar sobrecarga visual.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El usuario DEBE empezar únicamente con las 4 acciones del Modo Fácil (ver saldo, pagar recibo, enviar dinero, pedir ayuda). Ninguna función extra debe estar visible al inicio.
- **FR-002**: El sistema DEBE detectar señales de confianza del usuario y proponer funciones nuevas cuando se cumplan. Las señales para el prototipo son: completar al menos 5 operaciones exitosas sin pedir ayuda, o completar al menos 3 sesiones de práctica (008).
- **FR-003**: La propuesta de nueva función DEBE ser no intrusiva: un mensaje amable con el nombre de la función, una explicación de una línea (máximo 15 palabras), y tres opciones: "Sí, actívalo", "Primero quiero practicarlo", y "No, por ahora no".
- **FR-004**: Si el usuario elige practicar, el sistema DEBE llevarle al modo práctica (008) incluyendo la nueva función con datos ficticios y guía opcional.
- **FR-005**: Si el usuario rechaza una propuesta, el sistema NO DEBE volver a proponerla en la misma sesión. Después de 3 rechazos a la misma función, NO DEBE proponerla automáticamente; el usuario podrá activarla manualmente desde configuración.
- **FR-006**: Solo se DEBE proponer una función nueva a la vez. Si hay varias disponibles, se proponen una por sesión en orden de prioridad.
- **FR-007**: Las funciones extra activadas DEBEN aparecer con la misma estética accesible del Modo Fácil: botones grandes, contraste 4.5:1, etiquetas para lector de pantalla, área táctil mínima de 48x48 dp.
- **FR-008**: Las 4 acciones originales DEBEN mantenerse siempre como acciones principales en la pantalla. Las funciones extra DEBEN agruparse en una sección secundaria ("Más funciones") cuando haya más de 4 funciones activas en total.
- **FR-009**: El usuario DEBE poder volver a la vista de solo 4 acciones en cualquier momento desde configuración ("Volver a solo 4 acciones"). Las funciones extra se ocultan pero no se eliminan.
- **FR-010**: Las funciones previamente desbloqueadas DEBEN poder reactivarse individualmente desde configuración sin tener que cumplir condiciones de confianza de nuevo.
- **FR-011**: El usuario NUNCA DEBE perder funciones activadas sin aviso. Ocultar funciones es siempre una acción iniciada por el usuario, nunca automática.
- **FR-012**: La propuesta de nueva función DEBE ser accesible por lector de pantalla: anunciarse al aparecer y presentar las opciones de forma navegable.
- **FR-013**: Las funciones extra para el prototipo son simuladas: ver movimientos detallados, recargar celular, y pagar con QR. Todas usan datos ficticios.

### Key Entities

- **Función extra**: Una acción adicional que el usuario puede desbloquear. Atributos: nombre, descripción breve, estado (bloqueada, desbloqueada-oculta, activa), condición de desbloqueo, prioridad de propuesta. Para el prototipo: ver movimientos, recargar celular, pagar con QR.
- **Señal de confianza**: Indicador de que el usuario domina las funciones actuales. Tipos para el prototipo: operaciones exitosas sin ayuda (umbral: 5), sesiones de práctica completadas (umbral: 3). Se evalúa por función, no globalmente.
- **Propuesta**: Ofrecimiento de una función nueva al usuario. Atributos: función propuesta, estado (pendiente, aceptada, practicando, rechazada), número de rechazos. Máximo una propuesta activa a la vez.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de los usuarios nuevos empiezan con exactamente 4 acciones; ninguna función extra es visible al inicio.
- **SC-002**: Las propuestas de nuevas funciones aparecen solo cuando se cumplen las condiciones de confianza definidas, en el 100% de los casos.
- **SC-003**: El 70% de los usuarios de prueba que reciben una propuesta eligen activar o practicar la función (no rechazarla).
- **SC-004**: El 90% de los usuarios de prueba entienden que la propuesta es opcional y que pueden rechazarla sin consecuencias.
- **SC-005**: El usuario puede volver a la vista de 4 acciones en menos de 30 segundos desde configuración.
- **SC-006**: Las 4 acciones originales se mantienen como acciones principales en el 100% de los escenarios, independientemente de cuántas funciones extra estén activas.
- **SC-007**: Un usuario ciego puede interactuar con la propuesta y activar/rechazar una función usando solo TalkBack.
- **SC-008**: Después de 3 rechazos a la misma función, la app no la vuelve a proponer automáticamente en el 100% de los casos.

## Assumptions

- Las condiciones de confianza para el prototipo son simples y fijas: 5 operaciones exitosas sin ayuda o 3 sesiones de práctica completadas. No se ajustan por usuario.
- Las funciones extra del prototipo son 3 simuladas: ver movimientos detallados (lista de últimas transacciones ficticias), recargar celular (formulario simple con monto y número), pagar con QR (simulación de escaneo con datos ficticios).
- La prioridad de propuesta de funciones es fija: ver movimientos primero (la más natural como extensión), luego recargar celular, luego pagar con QR.
- "Practicar primero" lleva al modo práctica (008) con la nueva función incluida. Si el modo práctica no tiene guía específica para esa función, se usa la experiencia de práctica libre.
- La sección "Más funciones" es un botón/área adicional en la pantalla principal que agrupa funciones extra cuando hay más de 4 activas. Nunca reemplaza ni desplaza las 4 originales.
- Las funciones extra desbloqueadas persisten entre sesiones (a diferencia del modo práctica). Si el usuario desinstala la app, se pierden (prototipo sin backend persistente).
- No hay gamificación (puntos, niveles, insignias) asociada al desbloqueo. La progresión es natural, no competitiva.

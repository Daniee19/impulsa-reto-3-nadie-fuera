# Feature Specification: Asistente de Voz y Texto con Permisos Cerrados

**Feature Branch**: `004-voice-text-assistant`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "El usuario habla o escribe frases naturales en español y el asistente entiende la intención, la traduce a una de las 4 acciones del Modo Fácil, lee en voz alta el resumen de la operación y pide confirmación con huella antes de ejecutarla. La IA nunca ejecuta operaciones sola, solo puede preparar las 4 acciones permitidas, y si no entiende pregunta en vez de adivinar."

**Depends on**: [specs/001-easy-mode](../001-easy-mode/spec.md) — las 4 acciones que el asistente puede preparar. [specs/002-fraud-shield](../002-fraud-shield/spec.md) — las operaciones monetarias preparadas por el asistente pasan por el escudo antifraude.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rosa dice "quiero pagar la luz" (Priority: P1)

Rosa abre el asistente y dice "quiero pagar la luz". El asistente entiende que quiere pagar un recibo de servicio eléctrico, busca el recibo de luz en los recibos pendientes, y le muestra un resumen en pantalla que además lee en voz alta: "Vas a pagar tu recibo de luz por S/ 120. ¿Confirmas con tu huella?" Rosa pone su huella y el pago se ejecuta. Si el monto activara una regla del escudo antifraude, la pantalla de alerta aparecería antes de la confirmación.

**Why this priority**: Pagar recibos por voz es el caso de uso que más directamente ataca las ~91,000 llamadas mensuales de "no logro usar la app". Rosa no necesita navegar menús ni leer pantallas pequeñas; habla como le hablaría a una persona.

**Independent Test**: Se puede probar dictando "quiero pagar la luz" y verificando que el asistente prepara el pago correcto, lee el resumen y espera confirmación biométrica. Entrega valor completo: el usuario paga un recibo con voz.

**Acceptance Scenarios**:

1. **Given** el usuario dice "quiero pagar la luz", **When** el asistente procesa la frase, **Then** identifica la intención como "pagar recibo", busca el recibo de luz en los pendientes, y muestra el resumen con servicio y monto.
2. **Given** el asistente muestra el resumen de la operación, **When** lo lee en voz alta, **Then** la lectura incluye el tipo de operación, el destinatario y el monto exacto (obtenido de los datos, no generado por la IA).
3. **Given** el usuario confirma con su huella, **When** la verificación es exitosa, **Then** la operación se ejecuta y el asistente anuncia "Pago realizado" en voz alta.
4. **Given** la operación activaría una regla del escudo antifraude, **When** el usuario confirma, **Then** la pantalla de alerta del escudo aparece antes de la ejecución, con las mismas tres opciones (cancelar, continuar, consultar persona de confianza).

---

### User Story 2 - Rosa dice "mándale 50 soles a mi hija" (Priority: P1)

Rosa dice "mándale 50 soles a mi hija". El asistente entiende que quiere enviar dinero, identifica "mi hija" como Valeria (su contacto guardado), prepara una transferencia de S/ 50 a Valeria, y lee el resumen en voz alta: "Vas a enviar S/ 50 a Valeria. ¿Confirmas con tu huella?" Rosa confirma. Si "mi hija" no coincide con un contacto único, el asistente pregunta: "¿A cuál contacto te refieres?" y muestra las opciones.

**Why this priority**: Enviar dinero por voz elimina la barrera de tener que navegar listas y teclear montos, que es donde Rosa más teme equivocarse. La confirmación en voz alta le da seguridad de que el dinero va a la persona correcta.

**Independent Test**: Se puede probar dictando la frase y verificando que el asistente resuelve el contacto, prepara el monto correcto, y lee el resumen antes de pedir huella.

**Acceptance Scenarios**:

1. **Given** el usuario dice "mándale 50 soles a mi hija", **When** el asistente procesa la frase, **Then** identifica la intención como "enviar dinero", resuelve "mi hija" al contacto guardado correspondiente, y prepara una transferencia por S/ 50.
2. **Given** "mi hija" coincide con exactamente un contacto guardado, **When** el asistente muestra el resumen, **Then** incluye el nombre del contacto y el monto, leídos en voz alta.
3. **Given** "mi hija" no coincide con ningún contacto o coincide con varios, **When** el asistente no puede resolver, **Then** pregunta "¿A quién quieres enviarle?" y muestra la lista de contactos para que el usuario elija.
4. **Given** el usuario no menciona el monto ("mándale plata a Valeria"), **When** el asistente procesa la frase, **Then** pregunta "¿Cuánto quieres enviarle a Valeria?" en vez de asumir un monto.

---

### User Story 3 - Luis pregunta "cuánto tengo" (Priority: P1)

Luis, que es ciego, activa el asistente y dice "cuánto tengo". El asistente entiende que quiere ver su saldo, obtiene el saldo de los datos de la cuenta, y lo lee en voz alta: "Tienes S/ 2,350 disponibles en tu cuenta." No hay pantalla de confirmación porque no se mueve dinero. Luis obtiene la información sin tocar la pantalla.

**Why this priority**: Para Luis, que depende completamente de TalkBack, poder preguntar su saldo por voz es la forma más directa y natural de obtener esta información. Es la acción más simple y frecuente, ideal para demostrar el valor del asistente.

**Independent Test**: Se puede probar dictando "cuánto tengo" y verificando que el asistente responde con el saldo exacto leído en voz alta, sin pedir confirmación biométrica.

**Acceptance Scenarios**:

1. **Given** el usuario dice "cuánto tengo", **When** el asistente procesa la frase, **Then** identifica la intención como "ver saldo" y obtiene el saldo de los datos de la cuenta (no del texto generado por la IA).
2. **Given** el asistente obtuvo el saldo, **When** responde, **Then** lee en voz alta el monto exacto con el formato "Tienes S/ [monto] disponibles".
3. **Given** la consulta de saldo no mueve dinero, **When** el asistente responde, **Then** NO pide confirmación biométrica.

---

### User Story 4 - El asistente no entiende y pregunta (Priority: P1)

Carmen dice "hazme el favor eso de siempre", una frase ambigua. El asistente no puede mapear esto a ninguna de las 4 acciones con suficiente confianza. En vez de adivinar, responde: "No estoy seguro de lo que necesitas. ¿Quieres ver tu saldo, pagar un recibo, enviar dinero o pedir ayuda?" Carmen dice "pagar mi recibo" y el asistente continúa el flujo normal.

**Why this priority**: P1 porque adivinar mal es peor que preguntar. Un asistente que ejecuta una operación equivocada destruye la confianza del usuario. La guía técnica establece que "si no encuentra la respuesta, dice 'No estoy seguro, te comunico con una persona'". Preguntar es la respuesta segura.

**Independent Test**: Se puede probar dictando frases ambiguas o sin sentido y verificando que el asistente siempre pregunta en vez de ejecutar una acción incorrecta.

**Acceptance Scenarios**:

1. **Given** el usuario dice una frase que no se puede mapear con confianza a una de las 4 acciones, **When** el asistente la procesa, **Then** responde con una pregunta que enumera las acciones disponibles, en lenguaje simple.
2. **Given** el asistente preguntó qué necesita el usuario, **When** el usuario responde con una intención clara, **Then** el asistente continúa el flujo de esa acción normalmente.
3. **Given** el usuario dice algo completamente fuera del alcance ("cuál es la capital de Francia"), **When** el asistente lo procesa, **Then** responde "Solo puedo ayudarte con tu cuenta. ¿Quieres ver tu saldo, pagar un recibo, enviar dinero o pedir ayuda?"

---

### User Story 5 - Rosa escribe en vez de hablar (Priority: P2)

Rosa no quiere hablar en voz alta (está en el bus). Abre el asistente y escribe "pagar agua". El asistente funciona igual que por voz: identifica la intención, prepara el pago del recibo de agua, muestra y lee el resumen, y pide confirmación.

**Why this priority**: P2 porque la voz es el canal principal, pero el texto es necesario para situaciones donde hablar no es posible o cómodo. El asistente debe funcionar igual por ambos canales.

**Independent Test**: Se puede probar escribiendo comandos y verificando que el asistente responde igual que por voz.

**Acceptance Scenarios**:

1. **Given** el usuario escribe una frase en el campo de texto del asistente, **When** el asistente la procesa, **Then** la interpreta con las mismas reglas que la voz y produce el mismo resultado.
2. **Given** el usuario escribió una instrucción que prepara una operación, **When** el asistente muestra el resumen, **Then** también lo lee en voz alta (el canal de entrada es texto, pero la salida siempre incluye voz).

---

### User Story 6 - Consentimiento para usar el micrófono (Priority: P1)

La primera vez que Rosa intenta usar la voz, la app le pide permiso en lenguaje simple: "Para escucharte, necesito usar tu micrófono. Solo lo uso mientras hablas, no grabo nada." Rosa acepta. Si rechaza, puede seguir usando el asistente por texto.

**Why this priority**: P1 porque el consentimiento para uso de micrófono es obligatorio por la Ley 29733 (protección de datos personales en Perú) y es un principio de la constitución del proyecto. Sin este paso, la feature de voz no cumple con la ley.

**Independent Test**: Se puede probar abriendo el asistente por primera vez y verificando que pide permiso antes de activar el micrófono.

**Acceptance Scenarios**:

1. **Given** el usuario nunca ha usado el micrófono en la app, **When** intenta activar la entrada por voz, **Then** ve una pantalla de consentimiento que explica en lenguaje simple para qué se usa el micrófono y que no se graba nada.
2. **Given** el usuario rechaza el permiso del micrófono, **When** intenta usar el asistente, **Then** solo tiene disponible la entrada por texto y ve un mensaje: "Puedes escribirme si prefieres no usar el micrófono."
3. **Given** el usuario aceptó el permiso, **When** usa el asistente en sesiones futuras, **Then** puede hablar directamente sin que se le vuelva a pedir permiso.

---

### Edge Cases

- Que pasa si el usuario menciona un recibo que no existe en sus pendientes? El asistente dice: "No encontré un recibo de [servicio] pendiente. ¿Quieres ver tus recibos pendientes?"
- Que pasa si el usuario dice un monto inválido (negativo, cero, letras)? El asistente pide que repita: "No entendí el monto. ¿Cuánto quieres enviar?"
- Que pasa si el reconocimiento de voz falla o no entiende el audio? El asistente dice: "No te escuché bien. ¿Puedes repetir o escribirlo?"
- Que pasa si el usuario dice "pedir ayuda"? El asistente activa el flujo de Ayuda Humana con Contexto (003-contextual-human-help), pasando el contexto de que el usuario estaba usando el asistente.
- Que pasa si la huella no coincide? El asistente dice: "No reconocí tu huella. Intenta de nuevo." Permite reintentos sin cancelar la operación preparada.
- Que pasa si el usuario intenta una operación no permitida ("transfiere a esta cuenta nueva 12345")? El asistente solo opera con contactos guardados: "Solo puedo enviar dinero a tus contactos guardados. ¿A quién de tus contactos quieres enviarle?"
- Que pasa si la IA genera un monto incorrecto? No puede: los montos, saldos y datos siempre vienen de los datos de la cuenta/recibos, nunca del texto generado por la IA. La IA solo selecciona la intención y los parámetros; los valores numéricos vienen de la fuente de datos.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El asistente DEBE aceptar entrada por voz (micrófono) y por texto (teclado), produciendo el mismo resultado para la misma intención.
- **FR-002**: El asistente DEBE reconocer frases en español peruano coloquial y mapearlas a una lista cerrada de intenciones: consultar saldo, pagar recibo, enviar dinero a contacto guardado, y pedir ayuda.
- **FR-003**: El asistente NO DEBE ejecutar ninguna operación por sí solo. Solo puede preparar la operación (identificar intención, resolver parámetros) y presentarla al usuario para confirmación.
- **FR-004**: Toda operación monetaria preparada por el asistente DEBE requerir confirmación biométrica (huella) antes de ejecutarse.
- **FR-005**: Antes de pedir confirmación, el asistente DEBE leer en voz alta un resumen de la operación que incluya: tipo de operación, destinatario (si aplica) y monto (si aplica).
- **FR-006**: Los montos, saldos y datos de recibos/contactos en el resumen DEBEN provenir de la fuente de datos (cuenta, recibos, contactos), NUNCA del texto generado por la IA.
- **FR-007**: Si el asistente no puede identificar la intención con confianza, DEBE preguntar en lenguaje simple enumerando las acciones disponibles. NUNCA DEBE adivinar ni ejecutar una acción con baja confianza.
- **FR-008**: Si el usuario menciona un destinatario ambiguo o desconocido, el asistente DEBE preguntar a cuál contacto guardado se refiere, mostrando las opciones.
- **FR-009**: Si faltan datos obligatorios (monto en una transferencia, servicio en un pago), el asistente DEBE preguntar por el dato faltante en vez de asumir un valor.
- **FR-010**: Las operaciones monetarias preparadas por el asistente DEBEN pasar por el escudo antifraude (002-fraud-shield) antes de la confirmación final.
- **FR-011**: La primera vez que el usuario active la entrada por voz, el sistema DEBE solicitar consentimiento explícito para usar el micrófono, explicando en lenguaje simple para qué se usa y que no se graba. Cumplimiento de Ley 29733.
- **FR-012**: Si el usuario no otorga permiso de micrófono, el asistente DEBE funcionar completamente por texto.
- **FR-013**: El audio de voz DEBE usarse solo para procesar la solicitud actual y no DEBE almacenarse después de procesado.
- **FR-014**: Los datos personales (DNI, números de cuenta, nombres completos) DEBEN anonimizarse antes de enviarse al modelo de IA para interpretación de intención.
- **FR-015**: Las respuestas del asistente DEBEN usar lenguaje simple (frases de máximo 15 palabras, sin jerga bancaria).
- **FR-016**: El asistente DEBE ser accesible por lector de pantalla: el botón de activación, las respuestas en texto, y los controles de confirmación DEBEN tener etiquetas descriptivas.
- **FR-017**: Si el usuario dice "pedir ayuda" o equivalente, el asistente DEBE activar el flujo de Ayuda Humana con Contexto (003-contextual-human-help).

### Key Entities

- **Intención**: El resultado de interpretar la frase del usuario. Pertenece a una lista cerrada: consultar_saldo, pagar_servicio, transferir_a_contacto, pedir_ayuda. Atributos: tipo, confianza (suficiente/insuficiente), parámetros extraídos (servicio, contacto, monto).
- **Resumen de operación**: Texto generado a partir de los datos reales (no de la IA) que describe la operación preparada. Atributos: tipo de operación, destinatario, monto, leído en voz alta antes de confirmación.
- **Consentimiento de micrófono**: Registro de si el usuario autorizó el uso del micrófono. Atributos: estado (otorgado/denegado), fecha.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El asistente identifica correctamente la intención en al menos el 85% de las frases de prueba en español peruano coloquial.
- **SC-002**: El 100% de las operaciones monetarias preparadas por el asistente requieren confirmación biométrica antes de ejecutarse; ninguna se ejecuta sin ella.
- **SC-003**: El 100% de los montos y saldos mostrados en resúmenes provienen de la fuente de datos, nunca del texto generado por la IA.
- **SC-004**: Cuando el asistente no identifica la intención, pregunta en vez de adivinar en el 100% de los casos.
- **SC-005**: El 80% de los usuarios de prueba (adultos mayores de 60 anos) completan un pago o transferencia por voz en su primer intento.
- **SC-006**: El tiempo promedio para completar una operación por voz (desde la frase hasta la confirmación biométrica) no supera los 60 segundos.
- **SC-007**: El asistente funciona completamente por texto cuando el micrófono no está disponible o no fue autorizado.
- **SC-008**: El consentimiento de micrófono se solicita antes del primer uso de voz en el 100% de los casos.

## Assumptions

- La lista de intenciones es cerrada y fija para el prototipo: consultar_saldo, pagar_servicio, transferir_a_contacto, pedir_ayuda. No se agregan intenciones nuevas sin modificar la especificación.
- El reconocimiento de voz funciona con español peruano. Se reconoce como limitación que acentos regionales fuertes y quechua pueden reducir la precisión (declarado en la guía técnica como límite conocido).
- Los datos son simulados (cuentas, recibos, contactos ficticios) pero el flujo de interpretación de intención y preparación de operación es real.
- La confirmación biométrica usa huella digital. Si el dispositivo no tiene lector de huella, se ofrece PIN como respaldo (alineado con la constitución del proyecto que menciona PIN fallback).
- La IA recibe datos anonimizados para interpretar la intención. Los montos y datos reales los consulta el sistema después de identificar la intención, no la IA.
- El asistente opera como una capa encima del Modo Fácil: prepara las mismas 4 acciones con los mismos flujos, mismas validaciones y mismo escudo antifraude. No es un canal alternativo con reglas distintas.
- Si el asistente identifica la intención como "pedir ayuda", delega al flujo de 003-contextual-human-help.

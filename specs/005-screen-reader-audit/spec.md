# Feature Specification: Auditoría de Accesibilidad para Lector de Pantalla

**Feature Branch**: `005-screen-reader-audit`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Cada elemento visible debe tener una etiqueta clara en español para TalkBack, el orden de lectura debe ser lógico, ninguna acción debe depender de gestos complejos ni de imágenes sin descripción, los montos se leen completos y los cambios importantes de pantalla se anuncian. Verificable con pruebas automáticas y una prueba manual guiada."

**Applies to**: Todas las pantallas de [001-easy-mode](../001-easy-mode/spec.md), [002-fraud-shield](../002-fraud-shield/spec.md), [003-contextual-human-help](../003-contextual-human-help/spec.md) y [004-voice-text-assistant](../004-voice-text-assistant/spec.md).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Luis navega toda la app sin ver la pantalla (Priority: P1)

Luis es ciego y usa TalkBack. Abre la app en Modo Fácil y navega todas las pantallas deslizando el dedo. En cada pantalla, TalkBack lee primero el título, luego la información relevante (saldo, datos del recibo, nombre del contacto) y por último las acciones disponibles (botones). Nunca encuentra un elemento mudo (sin etiqueta), nunca escucha "botón" sin saber qué hace, y nunca necesita ver la pantalla para entender dónde está.

**Why this priority**: Luis representa a los usuarios ciegos cuya única interfaz con la app es lo que el lector de pantalla les dice. Un solo elemento sin etiqueta o un orden de lectura caótico rompe completamente su experiencia. Esto es obligación legal (Ley 29973) y el principio #1 de la constitución del proyecto: Accesibilidad Primero.

**Independent Test**: Se puede probar activando TalkBack y navegando cada pantalla de la app con los ojos cerrados. Entrega valor: un usuario ciego puede usar toda la app de forma autónoma.

**Acceptance Scenarios**:

1. **Given** TalkBack está activado, **When** Luis navega cualquier pantalla deslizando el dedo, **Then** cada elemento interactivo e informativo tiene una etiqueta descriptiva en español que TalkBack lee en voz alta.
2. **Given** Luis está en cualquier pantalla, **When** TalkBack lee los elementos en orden, **Then** el orden es lógico: título de la pantalla primero, luego información, luego acciones.
3. **Given** Luis llega a un botón, **When** TalkBack lo anuncia, **Then** escucha el propósito del botón (ej: "Pagar recibo") y no solo "botón" o un texto genérico.

---

### User Story 2 - Los montos se leen como palabras, no como símbolos (Priority: P1)

Rosa está en la pantalla de confirmación de un pago. TalkBack lee: "Vas a pagar cincuenta soles al recibo de luz." No lee "S/ 50" ni "ese barra cincuenta" ni "cincuenta" sin la moneda. Los montos siempre se leen en palabras completas con la moneda, para que no haya ambigüedad ni confusión.

**Why this priority**: Un usuario ciego o con baja visión que depende de TalkBack necesita entender exactamente cuánto dinero va a mover. "S/ 50" leído por un lector de pantalla genérico puede sonar como "ese barra cincuenta" o "S cincuenta", lo cual confunde. Leer "cincuenta soles" elimina toda duda, especialmente en operaciones monetarias donde la claridad es seguridad.

**Independent Test**: Se puede probar navegando con TalkBack cada pantalla que muestre un monto y verificando que se lee en palabras completas con moneda.

**Acceptance Scenarios**:

1. **Given** una pantalla muestra un monto de dinero, **When** TalkBack lee ese elemento, **Then** anuncia el monto en palabras completas con la moneda (ej: "ciento veinte soles" en vez de "S/ 120").
2. **Given** la pantalla de saldo muestra S/ 2,350.50, **When** TalkBack lee el saldo, **Then** anuncia "dos mil trescientos cincuenta soles con cincuenta céntimos".
3. **Given** un monto es cero, **When** TalkBack lo lee, **Then** anuncia "cero soles" y no omite el monto ni dice solo el símbolo.

---

### User Story 3 - Los cambios de pantalla se anuncian automáticamente (Priority: P1)

Luis confirma un pago con su huella. La pantalla cambia al mensaje de éxito. Sin que Luis tenga que tocar nada, TalkBack anuncia: "Pago realizado. Pagaste ciento veinte soles al recibo de luz." Lo mismo ocurre cuando aparece la alerta del escudo antifraude, cuando se conecta con ayuda humana, o cuando el asistente de voz responde: cada cambio importante de estado se anuncia sin intervención del usuario.

**Why this priority**: Un usuario ciego no sabe que la pantalla cambió si nadie se lo dice. Sin anuncios automáticos, Luis se queda esperando sin saber que su pago ya se realizó, o que apareció una alerta de seguridad que requiere su atención. Es la diferencia entre una app usable y una app muda.

**Independent Test**: Se puede probar completando flujos clave con TalkBack y verificando que cada transición de pantalla y cambio de estado se anuncia automáticamente.

**Acceptance Scenarios**:

1. **Given** el usuario completa una operación monetaria, **When** la pantalla cambia al resultado, **Then** TalkBack anuncia automáticamente el resultado ("Pago realizado", "Dinero enviado") con el resumen.
2. **Given** aparece la pantalla de alerta del escudo antifraude, **When** la alerta se muestra, **Then** TalkBack anuncia automáticamente que hay una alerta y lee la explicación del riesgo.
3. **Given** el usuario pide ayuda y se inicia una conexión, **When** la pantalla de conexión aparece, **Then** TalkBack anuncia "Te estamos conectando con [persona]."
4. **Given** el asistente de voz responde a una solicitud, **When** la respuesta aparece en pantalla, **Then** TalkBack anuncia la respuesta automáticamente.

---

### User Story 4 - Ninguna acción depende de gestos complejos ni imágenes (Priority: P1)

Carmen necesita confirmar un pago. No hay que pellizcar, arrastrar, hacer doble toque largo ni ningún gesto complejo. Solo tocar un botón grande y claro. Los iconos siempre tienen una descripción de texto asociada. Las imágenes decorativas se ignoran por TalkBack (no interrumpen la lectura) y las imágenes informativas tienen descripción. Ningún paso del flujo requiere interpretar algo visual para continuar.

**Why this priority**: Los gestos complejos excluyen a usuarios con movilidad reducida y a usuarios ciegos que navegan con gestos simples de TalkBack. Las imágenes sin descripción son barreras invisibles: el usuario no sabe que hay algo ahí. WCAG 2.2 AA lo exige.

**Independent Test**: Se puede probar verificando que todos los flujos se pueden completar con toques simples y que ninguna imagen informativa carece de descripción.

**Acceptance Scenarios**:

1. **Given** cualquier flujo de la app (ver saldo, pagar, enviar, pedir ayuda), **When** el usuario lo completa, **Then** solo necesita toques simples (un toque) sobre elementos con área mínima de 48x48 dp. Ningún paso requiere arrastrar, pellizcar, doble toque largo ni gestos multitáctiles.
2. **Given** un icono representa una acción, **When** TalkBack lo lee, **Then** anuncia la descripción de la acción, no el nombre del icono (ej: "Pagar recibo", no "icono de billete").
3. **Given** una imagen es decorativa (no aporta información), **When** TalkBack la encuentra, **Then** la ignora y pasa al siguiente elemento.
4. **Given** una imagen es informativa (aporta información necesaria), **When** TalkBack la encuentra, **Then** lee una descripción clara de lo que comunica.

---

### User Story 5 - Prueba manual guiada con TalkBack (Priority: P2)

El equipo de desarrollo sigue un guion de prueba: abren la app, activan TalkBack, cierran los ojos y navegan todos los flujos principales (ver saldo, pagar recibo, enviar dinero, pedir ayuda, recibir alerta de fraude, usar el asistente de voz). Anotan cada elemento sin etiqueta, cada orden de lectura confuso, cada monto leído como símbolo, y cada cambio de pantalla no anunciado. Esto se hace al menos una vez por cada pantalla nueva o modificada antes de considerarla terminada.

**Why this priority**: P2 porque es el proceso de verificación, no una funcionalidad para el usuario final. Sin embargo, es obligatoria: la constitución del proyecto exige "prueba manual obligatoria: usar la app 10 minutos con los ojos cerrados y TalkBack encendido".

**Independent Test**: Se puede verificar que el guion de prueba existe, cubre todos los flujos, y se ha ejecutado con resultados documentados.

**Acceptance Scenarios**:

1. **Given** existe un guion de prueba manual para TalkBack, **When** un miembro del equipo lo sigue, **Then** cubre todos los flujos principales de las features 001 a 004.
2. **Given** la prueba manual se ejecuta, **When** se encuentran problemas, **Then** se documentan con: pantalla, elemento, descripción del problema, y gravedad.
3. **Given** se lanza o modifica una pantalla, **When** se revisa para merge, **Then** la prueba manual de TalkBack se ha ejecutado y documentado para esa pantalla.

---

### Edge Cases

- Que pasa si un elemento tiene etiqueta pero es confusa o demasiado técnica (ej: "CTA principal")? Se considera fallo: la etiqueta debe ser comprensible para el usuario final, no para el desarrollador.
- Que pasa si dos botones adyacentes tienen la misma etiqueta (ej: dos "Confirmar")? Se considera fallo: cada acción debe tener una etiqueta que la distinga (ej: "Confirmar pago", "Confirmar envío").
- Que pasa con montos en céntimos (S/ 0.50)? Se lee "cincuenta céntimos". Montos con soles y céntimos: "ciento veinte soles con cincuenta céntimos".
- Que pasa si una pantalla tiene mucho contenido y la lectura se vuelve larga? Se agrupa información relacionada para que se lea como un bloque lógico (ej: el resumen de un pago se lee como una unidad, no como campos sueltos).
- Que pasa con las notificaciones toast o temporales? Si comunican información importante, deben permanecer en pantalla lo suficiente para ser leídas por TalkBack (mínimo 5 segundos) o no depender de tiempo.
- Que pasa si el usuario tiene TalkBack en un idioma distinto al español? Las etiquetas están en español; la app no soporta otros idiomas de interfaz en este prototipo.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El 100% de los elementos interactivos (botones, campos de texto, selectores) DEBEN tener una etiqueta descriptiva en español que sea leída por el lector de pantalla.
- **FR-002**: El 100% de los elementos informativos (textos, montos, estados) DEBEN tener etiquetas que el lector de pantalla pueda leer.
- **FR-003**: El orden de lectura del lector de pantalla en cada pantalla DEBE seguir la secuencia lógica: título de la pantalla, información contextual, y luego acciones disponibles.
- **FR-004**: Los montos de dinero DEBEN leerse en palabras completas con la moneda en español cuando el lector de pantalla los anuncia (ej: "ciento veinte soles" en vez de "S/ 120").
- **FR-005**: Los montos con céntimos DEBEN leerse completos (ej: "ciento veinte soles con cincuenta céntimos").
- **FR-006**: Todo cambio importante de pantalla o estado DEBE anunciarse automáticamente por el lector de pantalla sin intervención del usuario. Esto incluye: resultado de operaciones, alertas del escudo antifraude, inicio de conexión de ayuda, y respuestas del asistente.
- **FR-007**: Ninguna acción en la app DEBE depender exclusivamente de gestos complejos (arrastrar, pellizcar, doble toque largo, gestos multitáctiles). Toda acción DEBE ser ejecutable con un toque simple.
- **FR-008**: Las imágenes informativas DEBEN tener una descripción de texto asociada que el lector de pantalla lea. Las imágenes decorativas DEBEN ser ignoradas por el lector de pantalla.
- **FR-009**: Los iconos de acción DEBEN tener etiquetas que describan la acción, no el icono (ej: "Pagar recibo" en vez de "icono de billete").
- **FR-010**: No DEBE haber dos elementos interactivos adyacentes con la misma etiqueta en una misma pantalla.
- **FR-011**: Las etiquetas DEBEN usar lenguaje simple en español peruano, sin jerga técnica ni términos bancarios complejos. Frases de máximo 15 palabras.
- **FR-012**: Los mensajes temporales (toasts, banners) que comuniquen información importante DEBEN permanecer en pantalla al menos 5 segundos o no depender de tiempo.
- **FR-013**: DEBE existir un guion de prueba manual para TalkBack que cubra todos los flujos principales de las features 001 a 004.
- **FR-014**: La prueba manual de TalkBack DEBE ejecutarse y documentarse para cada pantalla nueva o modificada antes de considerarla terminada.
- **FR-015**: DEBEN existir pruebas automáticas que verifiquen: que cada elemento interactivo tiene etiqueta, que las áreas táctiles cumplen el mínimo de 48x48 dp, y que el contraste de texto cumple 4.5:1.
- **FR-016**: Estos requisitos aplican a TODAS las pantallas de las features 001 (Modo Fácil), 002 (Escudo antifraude), 003 (Ayuda humana con contexto) y 004 (Asistente de voz y texto).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de los elementos interactivos e informativos de la app tienen etiquetas descriptivas en español verificables con pruebas automáticas.
- **SC-002**: El 100% de las pantallas siguen el orden de lectura lógico (título, información, acciones) verificable con prueba manual.
- **SC-003**: El 100% de los montos se leen en palabras completas con moneda (verificable con prueba manual y/o automática).
- **SC-004**: El 100% de los cambios de pantalla/estado importantes se anuncian automáticamente por el lector de pantalla.
- **SC-005**: El 0% de las acciones en la app requieren gestos complejos; todas se completan con toques simples.
- **SC-006**: Un usuario ciego puede completar los 4 flujos principales (ver saldo, pagar recibo, enviar dinero, pedir ayuda) usando solo TalkBack, sin asistencia visual, en menos de 3 minutos cada uno.
- **SC-007**: La prueba manual de TalkBack se ejecuta y documenta para el 100% de las pantallas antes de su entrega.
- **SC-008**: Las pruebas automáticas de accesibilidad (etiquetas, áreas táctiles, contraste) pasan al 100% en todas las pantallas.
- **SC-009**: La prueba manual completa (todos los flujos, ojos cerrados, TalkBack) se puede ejecutar en 10 minutos o menos, según lo exige la constitución del proyecto.

## Assumptions

- Esta feature es transversal: no agrega pantallas nuevas sino que establece los estándares de accesibilidad para todas las pantallas de las features 001 a 004 y el proceso de verificación.
- El lector de pantalla objetivo es TalkBack (Android), que es la plataforma principal del proyecto.
- Los montos en palabras se generan en español peruano (soles y céntimos).
- El guion de prueba manual cubre los flujos principales: ver saldo, pagar recibo, enviar dinero, pedir ayuda, recibir alerta de fraude, usar asistente de voz, y conectar con ayuda humana.
- Las pruebas automáticas verifican propiedades medibles (etiquetas presentes, áreas táctiles, contraste). Las propiedades cualitativas (claridad de la etiqueta, orden lógico de lectura) se verifican con la prueba manual.
- La constitución del proyecto ya exige muchos de estos requisitos. Esta feature los consolida en un solo lugar verificable con criterios explícitos y un proceso de prueba documentado.
- El guion de prueba manual es un documento con pasos a seguir, no una herramienta automatizada. Lo ejecuta un miembro del equipo, idealmente con los ojos cerrados.

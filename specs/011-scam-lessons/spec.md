# Feature Specification: Microlecciones contra Estafas

**Feature Branch**: `011-scam-lessons`

**Created**: 2026-10-01

**Status**: Draft

**Input**: User description: "Microlecciones contra estafas. Contenido educativo breve (menos de 1 minuto cada uno) sobre fraudes comunes en Perú, como el Yape falso, llamadas del 'banco' pidiendo claves, falsos premios y familiares en apuros. Cada lección tiene texto simple, audio y una pregunta final de práctica. Se ofrecen en momentos útiles, por ejemplo después de una alerta del Escudo antifraude, y nunca bloquean una operación. Para el hackathon incluye 3 a 5 lecciones de ejemplo."

**Depends on**: [specs/002-fraud-shield](../002-fraud-shield/spec.md) — las lecciones se sugieren después de una alerta del Escudo antifraude. [specs/001-easy-mode](../001-easy-mode/spec.md) — las lecciones son accesibles desde el Modo Fácil.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rosa recibe una sugerencia de lección después de una alerta de fraude (Priority: P1)

Rosa acaba de recibir una alerta del Escudo antifraude (002) porque intentó enviar dinero a un destinatario nuevo. Resolvió la alerta y completó (o canceló) su operación. Después, la app le muestra una sugerencia sutil: "¿Sabías que muchas estafas usan contactos falsos? Aprende a identificarlas en 1 minuto." Con dos opciones: "Ver lección" y "Ahora no". Rosa toca "Ver lección". Ve un texto corto y claro que le explica cómo funciona la estafa del Yape falso, con audio que lo lee en voz alta. Al final, una pregunta de práctica: "Te escriben por WhatsApp diciendo que te enviaron dinero por error y te piden que lo devuelvas. ¿Qué haces?" con opciones. Rosa elige la correcta y ve un mensaje de refuerzo positivo.

**Why this priority**: Es el flujo principal: la lección se ofrece en el momento de mayor receptividad (justo después de experimentar una alerta real). La guía técnica sitúa las microlecciones como diferenciador del Escudo antifraude. Sin este flujo contextual, las lecciones serían contenido pasivo que nadie busca.

**Independent Test**: Se puede probar completando una alerta del Escudo antifraude y verificando que aparece la sugerencia de lección, que la lección se muestra con texto y audio, y que la pregunta de práctica funciona.

**Acceptance Scenarios**:

1. **Given** el usuario acaba de resolver una alerta del Escudo antifraude, **When** vuelve a la pantalla principal o de confirmación, **Then** ve una sugerencia de lección relacionada con el tipo de alerta que recibió (destinatario nuevo → lección sobre contactos falsos, monto inusual → lección sobre montos sospechosos).
2. **Given** la sugerencia de lección aparece, **When** el usuario toca "Ahora no", **Then** la sugerencia desaparece sin insistir y el usuario continúa usando la app normalmente.
3. **Given** el usuario toca "Ver lección", **When** se abre la lección, **Then** ve el texto de la lección y el audio empieza a reproducirse automáticamente.
4. **Given** el usuario completó la lectura/escucha de la lección, **When** llega al final, **Then** ve una pregunta de práctica con opciones de respuesta.

---

### User Story 2 - Rosa completa la pregunta de práctica (Priority: P1)

Rosa está viendo la lección sobre el Yape falso. Al final lee la pregunta: "Te escriben por WhatsApp diciendo que te enviaron dinero por error y te piden que lo devuelvas. ¿Qué haces?" Las opciones son: (A) "Devuelvo el dinero para ser amable", (B) "Reviso mi saldo real antes de hacer nada", (C) "Les doy mi clave para que lo arreglen." Rosa elige (B). La app le dice: "¡Correcto! Siempre revisa tu saldo antes de actuar. Si no recibiste nada, es una estafa." Si hubiera elegido mal, la app le explica por qué no es la mejor opción sin hacerla sentir tonta.

**Why this priority**: P1 porque la pregunta de práctica convierte contenido pasivo en aprendizaje activo. Sin ella, el usuario escucha y olvida. Con ella, tiene que pensar y recibe retroalimentación inmediata.

**Independent Test**: Se puede probar respondiendo correcta e incorrectamente a la pregunta y verificando que la retroalimentación es adecuada en ambos casos.

**Acceptance Scenarios**:

1. **Given** el usuario ve la pregunta de práctica, **When** elige la respuesta correcta, **Then** ve un mensaje de refuerzo positivo que explica brevemente por qué es correcta.
2. **Given** el usuario ve la pregunta de práctica, **When** elige una respuesta incorrecta, **Then** ve una explicación amable de por qué esa opción no es la mejor, sin lenguaje negativo ("Incorrecto", "Error", "Mal"), y la respuesta correcta con su explicación.
3. **Given** el usuario completó la pregunta, **When** ve el resultado, **Then** puede tocar "Volver" para regresar a donde estaba en la app.

---

### User Story 3 - Carmen busca las lecciones por su cuenta (Priority: P2)

Carmen quiere aprender sobre estafas sin esperar a que la app le sugiera algo. Desde la pantalla principal del Modo Fácil, toca "Pedir ayuda" y luego "Aprender sobre estafas" (o accede desde configuración). Ve una lista de lecciones disponibles con títulos claros: "El Yape falso", "Llamadas del banco pidiendo claves", "El premio que no existe", "El familiar en apuros". Cada una muestra si ya la completó o no. Carmen elige una y la ve igual que si la hubiera abierto desde una sugerencia.

**Why this priority**: P2 porque el acceso proactivo es importante para usuarios curiosos, pero la mayoría de adultos mayores no buscarán contenido educativo activamente. El flujo contextual (Story 1) es el principal canal de descubrimiento.

**Independent Test**: Se puede probar navegando a la lista de lecciones, verificando que se muestran todas las disponibles, y abriendo una para completarla.

**Acceptance Scenarios**:

1. **Given** el usuario quiere ver las lecciones disponibles, **When** navega a la sección de lecciones (desde ayuda o configuración), **Then** ve una lista con el título de cada lección y su estado (vista/no vista).
2. **Given** el usuario abre una lección desde la lista, **When** la ve, **Then** el contenido y la pregunta de práctica funcionan igual que si hubiera llegado desde una sugerencia post-alerta.
3. **Given** el usuario completó una lección (respondió la pregunta), **When** vuelve a la lista, **Then** la lección aparece marcada como completada.

---

### User Story 4 - Luis escucha una lección con TalkBack (Priority: P2)

Luis, que es ciego, recibe la sugerencia de lección después de una alerta. TalkBack anuncia: "Sugerencia: ¿Sabías que muchas estafas usan contactos falsos? Aprende a identificarlas en 1 minuto. Opciones: Ver lección, Ahora no." Luis elige "Ver lección". TalkBack lee el contenido de la lección (además del audio). Cuando llega a la pregunta, TalkBack anuncia la pregunta y las opciones. Luis elige una y TalkBack lee la retroalimentación.

**Why this priority**: P2 porque la accesibilidad por lector de pantalla es transversal (005), pero las lecciones tienen un formato particular (texto + audio + pregunta interactiva) que necesita verificación específica.

**Independent Test**: Se puede probar con TalkBack activado, navegando toda la lección y respondiendo la pregunta.

**Acceptance Scenarios**:

1. **Given** TalkBack está activo, **When** aparece la sugerencia de lección, **Then** TalkBack la anuncia completa con las opciones disponibles.
2. **Given** TalkBack está activo, **When** el usuario navega por la lección, **Then** cada sección del contenido es legible y las opciones de la pregunta de práctica son navegables y seleccionables.
3. **Given** TalkBack está activo, **When** el usuario responde la pregunta, **Then** TalkBack lee la retroalimentación completa.

---

### User Story 5 - La sugerencia no interrumpe una operación en curso (Priority: P1)

Rosa está en medio de un pago. Recibió una alerta del Escudo, eligió "Continuar de todos modos", y ahora está en la pantalla de confirmación final. La sugerencia de lección NO aparece en este momento. Aparece solo después de que Rosa completa o cancela la operación, cuando ya no tiene una tarea pendiente.

**Why this priority**: P1 porque si las lecciones interrumpen operaciones, generan confusión y frustración. El principio es claro: educación sin fricción. Nunca bloquear, nunca interrumpir.

**Independent Test**: Se puede probar activando una alerta, eligiendo continuar, y verificando que la sugerencia de lección no aparece hasta después de completar la operación.

**Acceptance Scenarios**:

1. **Given** el usuario resolvió una alerta del Escudo pero aún tiene una operación en curso, **When** avanza por los pasos de la operación, **Then** no aparece ninguna sugerencia de lección hasta que la operación se complete o cancele.
2. **Given** el usuario completó la operación después de una alerta, **When** vuelve a la pantalla principal, **Then** la sugerencia de lección aparece en ese momento.
3. **Given** el usuario canceló la operación después de la alerta, **When** vuelve a la pantalla principal, **Then** la sugerencia de lección aparece igualmente (cancelar también es un buen momento para aprender).

---

### Edge Cases

- Que pasa si el usuario ya vio la lección que se le sugiere? No se le sugiere de nuevo. Si no hay otra lección relacionada disponible, no se muestra sugerencia.
- Que pasa si el usuario descarta todas las sugerencias ("Ahora no")? Después de 3 rechazos consecutivos, la app deja de sugerir lecciones contextualmente. El usuario puede verlas manualmente desde la lista.
- Que pasa si el usuario ya completó todas las lecciones? No se muestran más sugerencias. La lista en configuración muestra todas como completadas.
- Que pasa si no hay lección relacionada con el tipo de alerta? No se muestra sugerencia. Solo se sugieren lecciones relevantes al contexto.
- Que pasa si el usuario cierra la app durante una lección? Al volver, la lección no se reanuda; el usuario puede abrirla de nuevo desde la lista. La pregunta de práctica no se marca como completada hasta que se responda.
- Que pasa si el audio de la lección está en silencio? El texto siempre está visible como alternativa. Se muestra un aviso si el volumen está bajo, igual que en 010-audio-contracts.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema DEBE ofrecer microlecciones educativas sobre fraudes comunes en Perú. Cada lección tiene tres componentes: texto en lenguaje simple (máximo 15 palabras por oración), audio que lee el contenido en voz alta, y una pregunta de práctica con opciones de respuesta.
- **FR-002**: Cada lección DEBE poder consumirse en menos de 1 minuto (texto de máximo 150 palabras, audio de máximo 60 segundos).
- **FR-003**: El sistema DEBE sugerir una lección relevante después de que el usuario resuelve una alerta del Escudo antifraude (002). La lección sugerida DEBE estar relacionada con el tipo de alerta recibida.
- **FR-004**: La sugerencia de lección DEBE presentarse con dos opciones: "Ver lección" y "Ahora no". NUNCA DEBE bloquear ni retrasar una operación en curso.
- **FR-005**: La sugerencia de lección DEBE aparecer solo después de que el usuario complete o cancele la operación en curso, nunca durante la operación.
- **FR-006**: Si el usuario elige "Ahora no", la sugerencia DEBE desaparecer sin insistir en la misma sesión. Después de 3 rechazos consecutivos, el sistema DEBE dejar de sugerir lecciones contextualmente.
- **FR-007**: Las lecciones DEBEN ser accesibles desde una lista en la sección de ayuda o configuración, para que el usuario pueda verlas por iniciativa propia.
- **FR-008**: La lista de lecciones DEBE mostrar el título de cada lección y su estado: no vista, en progreso, o completada.
- **FR-009**: La pregunta de práctica DEBE ofrecer opciones de respuesta (mínimo 3). Al elegir la correcta, DEBE mostrar un mensaje de refuerzo positivo. Al elegir una incorrecta, DEBE explicar por qué no es la mejor opción en tono amable (sin "Incorrecto", "Error" o "Mal") y mostrar la respuesta correcta.
- **FR-010**: Una lección se marca como completada cuando el usuario responde la pregunta de práctica (correcta o incorrectamente). La lección completada puede revisarse pero no se vuelve a sugerir contextualmente.
- **FR-011**: El sistema NO DEBE sugerir una lección que el usuario ya completó. Si no hay lecciones relevantes no vistas, no se muestra sugerencia.
- **FR-012**: El audio de las lecciones DEBE poder pausarse. El texto DEBE estar siempre visible como alternativa al audio.
- **FR-013**: Las lecciones DEBEN cumplir los requisitos de accesibilidad: áreas táctiles de 48×48 dp, contraste 4.5:1, etiquetas para lector de pantalla en español, y contenido navegable por TalkBack.
- **FR-014**: Para el hackathon, el sistema DEBE incluir entre 3 y 5 lecciones de ejemplo sobre fraudes reales en Perú.
- **FR-015**: Los temas de las lecciones de ejemplo DEBEN incluir al menos: (1) el Yape falso (te dicen que enviaron dinero por error y piden que lo devuelvas), (2) llamadas del "banco" pidiendo claves, y (3) falsos premios o sorteos. Opcionalmente: (4) el familiar en apuros y (5) enlaces fraudulentos por SMS.

### Key Entities

- **Microlección**: Unidad de contenido educativo sobre un tipo de fraude. Atributos: título, contenido en texto simple, audio, pregunta de práctica con opciones y respuesta correcta, retroalimentación por opción, tipo de fraude asociado, estado por usuario (no vista, completada). Duración máxima: 1 minuto.
- **Pregunta de práctica**: Pregunta de opción múltiple al final de cada lección. Atributos: enunciado (escenario en lenguaje cotidiano), opciones (mínimo 3), opción correcta, retroalimentación positiva para la correcta, explicación amable para cada incorrecta.
- **Sugerencia contextual**: Ofrecimiento de una lección después de un evento relevante (alerta del Escudo). Atributos: lección sugerida, evento que la disparó, estado (mostrada, aceptada, rechazada). Máximo una sugerencia por evento.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100% de las alertas del Escudo antifraude que tienen una lección relacionada no vista generan una sugerencia de lección después de que la operación se completa o cancela.
- **SC-002**: El 0% de las sugerencias de lección interrumpen una operación en curso.
- **SC-003**: El 80% de los usuarios de prueba que aceptan ver una lección la completan (llegan a la pregunta de práctica y responden).
- **SC-004**: Cada lección se consume en menos de 1 minuto (texto leído o audio escuchado más respuesta a la pregunta).
- **SC-005**: El 85% de los usuarios de prueba responden correctamente la pregunta de práctica, indicando que el contenido es comprensible.
- **SC-006**: El 75% de los usuarios de prueba reportan que las lecciones les ayudan a reconocer estafas.
- **SC-007**: Un usuario ciego puede completar una lección usando solo TalkBack, incluyendo la pregunta de práctica.

## Assumptions

- Las lecciones de ejemplo para el hackathon son predefinidas, no generadas por IA. Cada lección tiene su texto, audio y pregunta ya escritos.
- Los temas se basan en fraudes reales y frecuentes en Perú: el Yape falso es el más común en transacciones móviles, las llamadas pidiendo claves son el fraude telefónico más reportado, los falsos premios circulan por SMS y WhatsApp.
- La relación entre tipo de alerta y lección sugerida es fija: alerta por destinatario nuevo → lección sobre contactos falsos/Yape falso; alerta por monto inusual → lección sobre montos sospechosos; alerta por frecuencia alta → lección sobre presión para actuar rápido.
- "Ahora no" no significa "nunca": la misma lección puede sugerirse en otro evento futuro (a menos que se cumpla la regla de 3 rechazos consecutivos o el usuario ya la completó).
- El audio de las lecciones es pregrabado (no síntesis de voz en tiempo real para el prototipo), lo que garantiza claridad y pronunciación natural.
- Las retroalimentaciones de la pregunta de práctica están escritas con tono amable y educativo: "Buena idea revisar primero" para la correcta, "Cuidado: dar tu clave nunca es seguro. Mejor opción: ..." para la incorrecta. Sin calificaciones numéricas ni puntuaciones.
- No hay gamificación (puntos, rachas, insignias). El estado es binario: vista o no vista. Alineado con la postura anti-gamificación de la guía técnica.
- La lista de lecciones es estática para el hackathon (3-5 lecciones). En una versión futura podrían agregarse más sin cambiar la estructura.

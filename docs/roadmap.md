# Hoja de Ruta — Nadie Fuera

## Voz en Quechua

> **Estado**: Supuesto de hoja de ruta. No implementado en el hackathon.

### Por qué importa

Perú tiene más de 4 millones de quechuahablantes, muchos de ellos adultos mayores en zonas rurales con acceso limitado a servicios financieros. Para estas personas, el castellano es segunda lengua o no lo dominan con fluidez. Una app bancaria que solo habla castellano reproduce la misma barrera que la banca tradicional: excluye a quien no se comunica en el idioma dominante.

Incluir quechua en el asistente de voz convertiría a Nadie Fuera en una herramienta de inclusión financiera real para poblaciones históricamente desatendidas, alineándose con el espíritu de la Ley 29735 (Ley de Lenguas Originarias) que reconoce el derecho de todo peruano a usar su lengua materna en servicios públicos y privados.

### Qué se necesitaría

- **Reconocimiento de voz en quechua**: modelos de speech-to-text entrenados con variantes regionales (quechua sureño, central, norteño). La disponibilidad de estos modelos es limitada hoy, pero hay iniciativas académicas y de código abierto avanzando (por ejemplo, proyectos de Mozilla Common Voice y Siminchik).
- **Síntesis de voz en quechua**: text-to-speech para que la app lea resúmenes, confirmaciones y respuestas del asistente en quechua con pronunciación natural.
- **Validación con hablantes nativos**: el quechua tiene variantes dialectales significativas. Cualquier implementación requiere pruebas con usuarios quechuahablantes reales para validar comprensión, naturalidad y respeto cultural. No basta con traducir: las metáforas financieras y la estructura de las oraciones deben adaptarse al idioma.
- **Contenido localizado**: resúmenes de contratos (010), mensajes de ayuda, alertas de fraude (002) y confirmaciones en quechua, escritos o revisados por hablantes nativos.

### Cómo encajaría en el asistente de voz (spec 004)

El asistente de voz y texto (004) ya define una arquitectura basada en intents cerrados (consultar_saldo, pagar_servicio, transferir_a_contacto, explicar_termino, hablar_con_asesor). El soporte de quechua se integraría como una capa de idioma sobre esta misma estructura:

1. **Detección de idioma**: al activar el micrófono, el sistema identifica si el usuario habla castellano o quechua y enruta al modelo de reconocimiento correspondiente.
2. **Mismos intents, diferente idioma**: la lista cerrada de intents no cambia. El usuario dice "qolqeyta rikuyta munani" (quiero ver mi plata) y el sistema lo mapea al mismo intent `consultar_saldo`.
3. **Respuestas en quechua**: las confirmaciones y resúmenes se leen en quechua usando síntesis de voz. Los montos se leen en castellano o quechua según preferencia del usuario.
4. **Consentimiento de micrófono**: el flujo de consentimiento (Ley 29733) se presenta también en quechua para usuarios que eligieron ese idioma.

La selección de idioma sería una preferencia del usuario en configuración, no una detección automática impuesta.

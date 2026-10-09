# Guion de Prueba Manual con TalkBack

**Objetivo**: Verificar que un usuario ciego puede usar toda la app de forma autónoma usando TalkBack.

**Tiempo objetivo**: ≤ 10 minutos para los 7 flujos.

## Preparación

1. Dispositivo Android con API 26+ y TalkBack instalado
2. Activar TalkBack: Configuración → Accesibilidad → TalkBack → Activar
3. Cerrar los ojos (o cubrir la pantalla)
4. Iniciar timer de 10 minutos
5. Abrir la app

---

## Flujo 1: Ver saldo (001)

- [ ] App abre → TalkBack anuncia "Pantalla principal"
- [ ] Swipe → lee "Ver mi saldo" (no "botón" genérico)
- [ ] Doble toque → anuncia saldo en palabras ("Tu saldo es dos mil cuatrocientos cincuenta soles")
- [ ] Swipe → lee "Volver"
- [ ] Doble toque → vuelve a pantalla principal

**Problemas encontrados**: ___

---

## Flujo 2: Pagar recibo (001)

- [ ] Swipe → lee "Pagar recibo"
- [ ] Doble toque → pantalla de recibos
- [ ] Swipe → lee cada recibo como unidad ("Luz, ciento veinte soles" — no "S/ 120")
- [ ] Doble toque en recibo → pantalla de confirmación
- [ ] Swipe → lee servicio y monto en palabras
- [ ] Swipe → lee "Confirmar" (no "botón")
- [ ] Doble toque → anuncia "Pago realizado. Pagaste [monto en palabras] al recibo de [servicio]"
- [ ] Swipe → lee "Volver al inicio"

**Problemas encontrados**: ___

---

## Flujo 3: Enviar dinero (001)

- [ ] Desde inicio, swipe → "Enviar dinero"
- [ ] Doble toque → lista de contactos
- [ ] Swipe → lee nombre de cada contacto
- [ ] Doble toque en contacto → formulario de monto
- [ ] Swipe → lee "Escribe el monto a enviar" (campo de texto)
- [ ] Ingresar monto → Swipe → "Confirmar"
- [ ] Doble toque → pantalla de confirmación
- [ ] Swipe → lee destinatario y monto en palabras
- [ ] "Confirmar" → anuncia "Dinero enviado. Enviaste [monto] a [nombre]"

**Problemas encontrados**: ___

---

## Flujo 4: Pedir ayuda con FAB (003)

- [ ] Desde cualquier pantalla, el FAB "Pedir ayuda" se lee al final (no en medio del contenido)
- [ ] Doble toque en FAB → pantalla de contactos de ayuda
- [ ] Swipe → lee cada opción ("Llamar a [nombre]", "Hablar con el banco")
- [ ] Doble toque → pantalla de canales
- [ ] Swipe → lee cada canal ("Llamar", "Escribir", "Videollamada con intérprete")
- [ ] Doble toque → anuncia "Te estamos conectando con [nombre]"

**Problemas encontrados**: ___

---

## Flujo 5: Recibir alerta de fraude (002)

- [ ] Triggerear alerta (pago inusual)
- [ ] TalkBack anuncia automáticamente "Alerta de seguridad. [explicación]"
- [ ] Swipe → lee explicación del riesgo en palabras claras
- [ ] Swipe → lee "Cancelar" (etiqueta única)
- [ ] Swipe → lee "Continuar de todos modos" (etiqueta distinta)
- [ ] Swipe → lee "Consultar a [nombre]" (si aplica)
- [ ] Ningún botón tiene la misma etiqueta que otro

**Problemas encontrados**: ___

---

## Flujo 6: Usar asistente de voz (004)

- [ ] Desde inicio → "Asistente"
- [ ] Swipe → lee botón de micrófono con etiqueta "Activar micrófono"
- [ ] Swipe → lee campo de texto "Escribe tu solicitud"
- [ ] Usar campo de texto → escribir "cuánto tengo"
- [ ] TalkBack anuncia saldo en palabras
- [ ] Escribir "pagar la luz" → anuncia resumen con monto en palabras

**Problemas encontrados**: ___

---

## Flujo 7: Conectar con ayuda humana (003)

- [ ] Activar flujo de ayuda → elegir contacto → elegir canal
- [ ] Anuncia "Te estamos conectando con [nombre]"
- [ ] Pantalla cambia a conectado → anuncia "Conectado con [nombre]"
- [ ] Si no responde → anuncia "No pudimos comunicarte con [nombre]"
- [ ] Swipe → lee opciones alternativas con etiquetas claras

**Problemas encontrados**: ___

---

## Resumen

| Flujo | Tiempo | Problemas | Gravedad |
|-------|--------|-----------|----------|
| 1. Ver saldo | | | |
| 2. Pagar recibo | | | |
| 3. Enviar dinero | | | |
| 4. Pedir ayuda | | | |
| 5. Alerta fraude | | | |
| 6. Asistente voz | | | |
| 7. Ayuda humana | | | |
| **Total** | | | |

**Tiempo total**: ___ minutos (objetivo: ≤ 10)

**Evaluador**: ___

**Fecha**: ___

## Gravedad

- **Crítica**: Bloquea el flujo, el usuario no puede continuar
- **Alta**: El usuario puede continuar pero con confusión significativa
- **Media**: Etiqueta confusa pero el flujo se entiende
- **Baja**: Mejora menor de experiencia

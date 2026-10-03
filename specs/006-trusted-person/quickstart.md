# Quickstart: Persona de Confianza (006-trusted-person)

Guía de validación para verificar que la feature funciona end-to-end.

## Prerequisites

- Feature 001-easy-mode implementada (arquitectura base, tema, router, l10n)
- `flutter_secure_storage` añadido a pubspec.yaml
- Android emulator o dispositivo con API 26+
- TalkBack para pruebas de accesibilidad

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

## Validation Scenarios

### VS-1: Registro de persona de confianza (US1 — P1)

1. Abrir configuración del Modo Fácil → tocar "Mi persona de confianza"
2. **Expected**: Explicación clara: "Tu persona de confianza puede ayudarte, pero no puede tocar tu dinero" (≤15 palabras)
3. Tocar "Registrar"
4. Ingresar nombre "Valeria Martínez", teléfono "987654321", relación "Hija"
5. **Expected**: Pantalla de permisos con 3 toggles, cada uno con explicación de una línea
6. Activar los 3 permisos, confirmar
7. **Expected**: Persona registrada. Volver a "Mi persona de confianza" muestra nombre y permisos activos
8. **A11y check**: TalkBack lee cada campo, cada toggle, y las explicaciones en orden lógico

### VS-2: Permisos granulares afectan 002 y 003 (US2 — P1)

1. Con persona de confianza registrada y todos los permisos activos:
   - Ir a un flujo de 002 (simular operación inusual) → **Expected**: aparece "Consultar a Valeria"
   - Ir a "Pedir ayuda" (003) → **Expected**: aparece "Llamar a Valeria"
2. Desactivar "Avisos de seguridad" desde configuración
3. Repetir flujo de 002 → **Expected**: NO aparece opción de Valeria, solo "Cancelar" y "Continuar"
4. Desactivar "Pedidos de ayuda"
5. Ir a "Pedir ayuda" (003) → **Expected**: NO aparece Valeria, solo asesor del banco
6. **Key check**: efecto inmediato, sin reiniciar app

### VS-3: Sugerencia de configuración (US3 — P2)

1. Con permiso "Ayudar a configurar" activo
2. Triggerear sugerencia simulada (desde debug o precargada): "Hacer la letra más grande"
3. **Expected**: Aviso: "Valeria te sugiere hacer la letra más grande. ¿Quieres aceptar?"
4. Tocar "Aceptar" → **Expected**: cambio se aplica, confirmación visible
5. Repetir con otra sugerencia, tocar "No, gracias" → **Expected**: sin cambios, sugerencia desaparece
6. **Key check**: Valeria no se entera del rechazo

### VS-4: Cambiar persona de confianza (US4 — P2)

1. Con Valeria registrada, tocar "Cambiar persona de confianza"
2. **Expected**: Explicación: "Vas a quitar a Valeria. Dejará de recibir avisos"
3. Confirmar, ingresar datos de Carlos López
4. **Expected**: Valeria pierde todos los permisos. Carlos tiene los nuevos permisos seleccionados
5. Verificar en 002/003: opciones ahora mencionan "Carlos", no "Valeria"

### VS-5: Quitar persona de confianza (US5 — P3)

1. Tocar "Quitar persona de confianza"
2. **Expected**: Explicación de consecuencias + confirmación requerida
3. Confirmar
4. **Expected**: Sin persona de confianza. 002 solo muestra Cancelar/Continuar. 003 solo muestra asesor del banco
5. Volver a "Mi persona de confianza" → muestra opción de registrar (estado inicial)

### VS-6: Edge cases

- **Auto-registro**: Intentar registrar el mismo teléfono del usuario → "No puedes registrarte a ti mismo"
- **Sin permisos**: Registrar persona sin activar ningún permiso → permitido, pero 002/003 no muestran opciones del familiar
- **Sugerencia con permiso off**: Desactivar "Ayudar a configurar" → sugerencias no llegan (en mock, el botón de simulación no aparece)
- **Sugerencia pendiente no caduca**: Sugerencia pendiente sigue visible hasta que el usuario la resuelva

## Automated Tests

```bash
# Unit tests (dominio — entidades, validaciones, permisos)
flutter test test/features/trusted_person/domain/

# Widget tests (pantallas de registro, permisos, sugerencias + a11y)
flutter test test/features/trusted_person/presentation/

# Integration test (flujo completo)
flutter test integration_test/trusted_person_flow_test.dart

# Cobertura dominio ≥ 80%
flutter test --coverage test/features/trusted_person/domain/
```

### A11y guidelines en widget tests

Cada screen test incluye:
```dart
expect(tester, meetsGuideline(androidTapTargetGuideline));
expect(tester, meetsGuideline(labeledTapTargetGuideline));
expect(tester, meetsGuideline(textContrastGuideline));
```

Test específico: toggles de permisos anuncian estado ("Activado"/"Desactivado") vía TalkBack.

## Definition of Done

- [ ] Registro de persona de confianza con nombre, teléfono y permisos
- [ ] 3 permisos granulares activables/desactivables individualmente
- [ ] Efecto inmediato de permisos en 002 y 003
- [ ] Datos sensibles en flutter_secure_storage
- [ ] Consentimiento granular registrado (ConsentRecord por cada cambio)
- [ ] Sugerencias de configuración con patrón aprobación explícita
- [ ] Cambiar y quitar persona de confianza con confirmación
- [ ] Todos los textos en ARB, ≤15 palabras, sin jerga
- [ ] `flutter analyze` 0 warnings
- [ ] Tests verdes: unit (≥80% dominio), widget (a11y), integration

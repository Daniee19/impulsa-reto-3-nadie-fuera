# Research: Asistente de Voz y Texto (004-voice-text-assistant)

## R1: Reconocimiento de voz con `speech_to_text`

**Decision**: Usar `speech_to_text` ^7.5.0 (MIT) para reconocimiento de voz en español. Configurar locale `es-PE` (español peruano) con fallback a `es-ES`. Procesamiento on-device cuando el dispositivo lo soporte (Android speech recognizer usa modelo on-device para español en la mayoría de dispositivos modernos).

**Rationale**: La constitución exige que el micrófono requiera consentimiento (Ley 29733). `speech_to_text` expone `initialize()` que solicita el permiso del SO, y `listen()` que inicia el reconocimiento. El paquete es mature (7.x), MIT, y el más usado para STT en Flutter.

**Implementación**:
```dart
class SpeechRecognitionService {
  final SpeechToText _speech = SpeechToText();

  Future<bool> initialize() => _speech.initialize();

  Future<String> listen({
    required void Function(String) onResult,
  }) async {
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) onResult(result.recognizedWords);
      },
      localeId: 'es_PE', // fallback a es_ES si no disponible
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stop() => _speech.stop();
  bool get isListening => _speech.isListening;
}
```

**Limitations conocidas** (del spec y PDF):
- Acentos regionales fuertes y quechua pueden reducir precisión.
- Requiere que el dispositivo tenga motor de reconocimiento de voz instalado (Google Speech Services en Android).

**Alternatives considered**:
- Google Cloud Speech-to-Text API: requiere conexión a internet, API key, costos. Overkill para prototipo.
- Whisper on-device: requiere modelo grande (~75MB+), no tiene paquete Flutter estable con licencia aprobada.

## R2: Síntesis de voz con `flutter_tts`

**Decision**: Usar `flutter_tts` ^4.2.5 (MIT) para leer respuestas en voz alta. Configurar idioma `es-ES` (el motor TTS de Android usa voces en español que cubren variantes regionales). Velocidad 0.45 (más lenta que default para adultos mayores).

**Rationale**: FR-005 exige leer en voz alta el resumen de operación. TTS es la forma estándar. `flutter_tts` usa el motor nativo de Android (no requiere descarga adicional).

**Implementación**:
```dart
class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) => _tts.speak(text);
  Future<void> stop() => _tts.stop();
}
```

**Configuración de velocidad**: 0.45 es ~55% más lenta que la velocidad normal. Optimizada para adultos mayores que necesitan escuchar y procesar la información. Configurable si se quiere ajustar más adelante.

**Alternatives considered**:
- Paquete `just_audio` con archivos pregrabados: no flexible para montos dinámicos.
- API cloud TTS: innecesario, el motor nativo es suficiente.

## R3: Confirmación biométrica con `local_auth`

**Decision**: Usar `local_auth` ^3.0.2 (BSD-3-Clause) para confirmación biométrica. Ya mencionada explícitamente en la constitución: "Biometric auth via `local_auth` with PIN fallback". Solicitar huella antes de ejecutar cualquier operación monetaria.

**Rationale**: FR-004 exige confirmación biométrica antes de ejecutar operaciones monetarias. La constitución ya pre-aprueba `local_auth`. El paquete soporta fingerprint, face ID, y PIN/pattern como fallback.

**Implementación**:
```dart
class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate({required String reason}) async {
    final isAvailable = await _auth.canCheckBiometrics;
    if (!isAvailable) {
      // PIN fallback — local_auth lo maneja automáticamente
      // cuando useErrorDialogs: true
    }
    return _auth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(
        biometricOnly: false, // permite PIN fallback
        stickyAuth: true,
      ),
    );
  }
}
```

**PIN fallback**: Cuando `biometricOnly: false`, Android muestra automáticamente la opción de PIN/patrón si la huella falla o no está disponible. Cumple con el spec: "Si el dispositivo no tiene lector de huella, se ofrece PIN como respaldo."

**Alternatives considered**:
- Implementación manual de PIN: innecesario, `local_auth` ya lo maneja.

## R4: Interpretación de intenciones — reglas locales

**Decision**: Usar reglas locales basadas en keywords (Dart puro) para interpretar intenciones. NO usar modelo de IA ni servicio cloud.

**Rationale**: La guía técnica del PDF establece reglas claras para el uso de IA:
- "IA receives anonymized data, selects intents from a closed list, and MUST NOT execute transactions."
- La lista es cerrada y pequeña (4 intenciones + "no entendí").
- Para el prototipo con solo 4 intenciones, un parser de keywords en Dart puro es suficiente, testeable al 100%, determinístico, y no requiere dependencias adicionales ni conexión a internet.
- Un modelo de IA sería overkill: la lista cerrada de intenciones hace que reglas simples alcancen el 85% de precisión requerido (SC-001) con las frases esperadas en español peruano coloquial.

**Implementación del IntentParser**:
```dart
class IntentParser {
  /// Interpreta una frase en español y retorna la intención.
  /// Dart puro, sin dependencias de Flutter.
  ParsedIntent parse(String input) {
    final normalized = input.toLowerCase().trim();

    // Regla 1: Consultar saldo
    if (_matchesBalance(normalized)) {
      return ParsedIntent(type: AssistantIntentType.checkBalance);
    }

    // Regla 2: Pagar recibo
    final payMatch = _matchesPayBill(normalized);
    if (payMatch != null) {
      return ParsedIntent(
        type: AssistantIntentType.payBill,
        parameters: IntentParameters(serviceName: payMatch),
      );
    }

    // Regla 3: Enviar dinero
    final sendMatch = _matchesSendMoney(normalized);
    if (sendMatch != null) {
      return ParsedIntent(
        type: AssistantIntentType.sendMoney,
        parameters: sendMatch,
      );
    }

    // Regla 4: Pedir ayuda
    if (_matchesHelp(normalized)) {
      return ParsedIntent(type: AssistantIntentType.requestHelp);
    }

    // No entendí
    return ParsedIntent(type: AssistantIntentType.unknown);
  }
}
```

**Keywords por intención**:
| Intención | Keywords/patterns |
|-----------|-------------------|
| `checkBalance` | "saldo", "cuánto tengo", "cuánto hay", "mi plata", "mi dinero", "balance" |
| `payBill` | "pagar", "recibo", "servicio", "luz", "agua", "gas", "teléfono", "internet" |
| `sendMoney` | "enviar", "mandar", "transferir", "plata a", "soles a", "dinero a" |
| `requestHelp` | "ayuda", "ayúdame", "no sé", "no entiendo", "hablar con alguien" |

**Extracción de parámetros**:
- **Monto**: regex `(\d+[\.,]?\d*)\s*soles?` o solo número si contexto es envío.
- **Contacto**: match parcial contra nombres de contactos guardados. "mi hija", "mi hijo", "mi esposa" se mapean via relación en SavedContact si disponible.
- **Servicio**: match contra nombres de servicios en recibos pendientes ("luz", "agua" → BillRepository).

**Alternatives considered**:
- API de NLP cloud (Dialogflow, LUIS): requiere conexión, API key, costos, latencia. No justificado para 4 intenciones.
- Modelo on-device (tflite_flutter): requiere modelo entrenado, peso del binario, complejidad. Reservar para V2 si las reglas no alcanzan el 85%.
- Package `nlp` o `natural_language`: no hay paquete Flutter estable con licencia aprobada para NLP en español.

## R5: Flujo del asistente — orquestación

**Decision**: El `VoiceAssistantProvider` orquesta el flujo completo: (1) recibir input (voz o texto) → (2) parsear intención → (3) resolver parámetros faltantes → (4) preparar operación con datos reales → (5) leer resumen en voz alta → (6) evaluar fraude → (7) pedir confirmación biométrica → (8) ejecutar.

**Rationale**: El asistente es una capa encima del Modo Fácil. Prepara las mismas 4 acciones, usa los mismos repositorios, pasa por el mismo escudo antifraude. La orquestación centralizada en un provider simplifica el flujo y lo hace testeable.

**Estado del flujo** (VoiceSessionStatus):
```
idle → listening → processing → needsMore → summarizing → awaitingConfirmation → executing → completed/error
```

- `idle`: esperando input
- `listening`: micrófono activo
- `processing`: parseando intención
- `needsMore`: falta un parámetro, preguntando al usuario
- `summarizing`: leyendo resumen en voz alta
- `awaitingConfirmation`: esperando huella (solo operaciones monetarias)
- `executing`: ejecutando la operación
- `completed`: operación exitosa
- `error`: error en algún paso

**Consulta de saldo**: no pasa por fraude ni confirmación biométrica (no mueve dinero). Se lee en voz alta directamente.

**Pedir ayuda**: delega a 003-contextual-human-help. El provider llama `context.push('/easy-mode/help/contact-picker')` y sale del flujo del asistente.

## R6: Integración con 002-fraud-shield

**Decision**: Después de preparar la operación (paso 4), antes de la confirmación biométrica (paso 7), el provider llama `RiskEngine.evaluate()` con el `OperationContext`. Si retorna un `RiskAlert` con reglas disparadas, se navega a `FraudAlertScreen` (002) en vez de pedir huella directamente.

**Rationale**: FR-010 exige que toda operación monetaria preparada por el asistente pase por el escudo antifraude. El flujo es idéntico al de 001: data entry → fraud check → confirm. La diferencia es que el "data entry" lo hace el parser de voz en vez de formularios.

**Patrón**:
```dart
// En VoiceAssistantProvider, después de preparar la operación:
final alert = riskEngine.evaluate(
  context: OperationContext(
    type: operation.type,
    amount: operation.amount,
    recipientId: operation.recipientId,
    recipientName: operation.recipientName,
    timestamp: DateTime.now(),
  ),
  history: await operationHistoryRepo.getRecent(),
);

if (alert.triggeredRules.isNotEmpty) {
  // Navegar a FraudAlertScreen con la alerta
  // Si el usuario continúa, volver a la confirmación biométrica
} else {
  // Ir directo a confirmación biométrica
}
```

## R7: Consentimiento de micrófono (Ley 29733)

**Decision**: La primera vez que el usuario toca el botón de micrófono, se navega a `MicrophoneConsentScreen` que explica en lenguaje simple para qué se usa y que no se graba. El consentimiento se guarda en `SharedPreferences` como bool (`microphone_consent_granted`). Si rechaza, solo queda la entrada por texto.

**Rationale**: FR-011 y Ley 29733 exigen consentimiento explícito. No es dato sensible (solo un bool de preferencia), así que `SharedPreferences` es suficiente (no necesita `flutter_secure_storage`).

**Texto del consentimiento** (ARB):
```
"microphoneConsentTitle": "Permiso para escucharte",
"microphoneConsentBody": "Para entender lo que dices, necesito usar tu micrófono. Solo lo uso mientras hablas, no grabo nada.",
"microphoneConsentAccept": "Aceptar",
"microphoneConsentDecline": "No, prefiero escribir",
"microphoneConsentDenied": "Puedes escribirme si prefieres no usar el micrófono."
```

**Alternatives considered**:
- Pedir permiso del SO directamente sin pantalla propia: no cumple con Ley 29733 que requiere explicación clara del propósito.
- Guardar en flutter_secure_storage: innecesario para un bool de preferencia no sensible.

## R8: Resolución de contactos y recibos

**Decision**: El IntentParser extrae nombres parciales y el `OperationPreparer` los resuelve contra los repositorios mock de 001 (ContactRepository, BillRepository).

**Resolución de contactos**:
- Match exacto por nombre: "Valeria" → match directo.
- Match por relación: "mi hija" → buscar en contactos con campo `relationship`. Si mock data no tiene relación, match parcial por contexto.
- Match ambiguo (0 o >1 resultados): preguntar "¿A quién quieres enviarle?" mostrando lista de contactos.

**Resolución de recibos**:
- Match por servicio: "luz" → buscar en recibos pendientes con servicio que contenga "luz" (case-insensitive).
- Sin match: "No encontré un recibo de [servicio] pendiente. ¿Quieres ver tus recibos pendientes?"
- Múltiples matches: preguntar cuál.

**Datos siempre del repositorio** (FR-006): El monto, saldo, nombre del destinatario, nombre del servicio — todos vienen de los repositorios. La IA solo dice "la intención es pagar y el servicio es luz". El monto lo obtiene `OperationPreparer` de `BillRepository.getBillByService("luz").amount`.

**Alternatives considered**:
- Hardcodear relaciones ("mi hija" = "Valeria"): frágil, no escala. Mejor match contra datos del repositorio.

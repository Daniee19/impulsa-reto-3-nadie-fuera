# Audio Contracts Contract (010-audio-contracts)

Pantalla de resumen de contrato con lectura TTS por secciones, controles de reproducción, y botón "Aceptar" condicionado a completar la revisión.

## ContractRepository

Ubicación: `lib/features/audio_contracts/domain/repositories/contract_repository.dart`

Dart puro. Interfaz abstracta.

```dart
abstract class ContractRepository {
  Future<ContractSummary> getContractSummary(String contractId);
  Future<List<String>> getAvailableContractIds();
}
```

**Contrato**:
- `getContractSummary()` retorna un `ContractSummary` con exactamente 4 secciones (una por `ContractSectionType`).
- Lanza `ContractNotFoundException` si el ID no existe.
- `getAvailableContractIds()` retorna los IDs de todos los contratos disponibles.

## MockContractRepository

Ubicación: `lib/features/audio_contracts/data/repositories/mock_contract_repository.dart`

```dart
class MockContractRepository implements ContractRepository {
  final AppLocalizations _l10n;

  MockContractRepository(this._l10n);

  @override
  Future<ContractSummary> getContractSummary(String contractId) async {
    return switch (contractId) {
      'savings_account' => _buildSavingsAccount(),
      'personal_loan' => _buildPersonalLoan(),
      _ => throw ContractNotFoundException(contractId),
    };
  }

  @override
  Future<List<String>> getAvailableContractIds() async {
    return ['savings_account', 'personal_loan'];
  }

  ContractSummary _buildSavingsAccount() {
    return ContractSummary(
      id: 'savings_account',
      title: _l10n.contractSavingsAccountTitle,
      sections: [
        ContractSection(
          type: ContractSectionType.whatYouAccept,
          title: _l10n.contractSectionWhatYouAccept,
          content: _l10n.contractSavingsWhatYouAccept,
        ),
        ContractSection(
          type: ContractSectionType.cost,
          title: _l10n.contractSectionCost,
          content: _l10n.contractSavingsCost,
        ),
        ContractSection(
          type: ContractSectionType.risks,
          title: _l10n.contractSectionRisks,
          content: _l10n.contractSavingsRisks,
        ),
        ContractSection(
          type: ContractSectionType.howToCancel,
          title: _l10n.contractSectionHowToCancel,
          content: _l10n.contractSavingsHowToCancel,
        ),
      ],
      fullContractParagraphs: List.generate(
        8,
        (i) => _l10n.contractSavingsFullParagraph(i + 1),
      ),
    );
  }

  // _buildPersonalLoan() — same pattern with personal_loan keys
}
```

**Contrato**:
- Retorna datos estáticos del mock. Textos vienen de ARB (localizados).
- Cada `ContractSummary` tiene exactamente 4 secciones, una por `ContractSectionType`.
- `fullContractParagraphs` son párrafos de texto legal simplificado (no real).

## ContractReviewProvider

Ubicación: `lib/features/audio_contracts/presentation/providers/contract_review_provider.dart`

Orquesta la sesión de revisión: TTS, estado de reproducción, habilitación del botón "Aceptar".

```dart
@riverpod
class ContractReviewNotifier extends _$ContractReviewNotifier {
  @override
  Future<ReviewSession> build(String contractId) async {
    final contract = await ref
        .read(contractRepositoryProvider)
        .getContractSummary(contractId);

    // Setup TTS completion callback
    final tts = ref.read(ttsServiceProvider);
    tts.setCompletionHandler(() => _onSectionComplete());

    return ReviewSession(
      contractId: contractId,
      contract: contract,
    );
  }

  /// Inicia lectura automática desde la sección 1.
  Future<void> startAutoRead() async {
    final session = state.requireValue;
    await _readSection(session.contract.sections.first.type);
  }

  /// Pausa TTS.
  Future<void> pauseTts() async {
    await ref.read(ttsServiceProvider).stop();
    state = AsyncValue.data(
      state.requireValue.copyWith(ttsState: TtsState.paused),
    );
  }

  /// Reanuda lectura desde la sección actual.
  Future<void> resumeTts() async {
    final session = state.requireValue;
    if (session.currentSection != null) {
      await _readSection(session.currentSection!);
    }
  }

  /// Repite la sección actual.
  Future<void> repeatSection() async {
    final session = state.requireValue;
    if (session.currentSection != null) {
      await _readSection(session.currentSection!);
    }
  }

  /// Cicla velocidad: normal → slow → slower → normal.
  Future<void> cycleSpeed() async {
    final session = state.requireValue;
    final next = switch (session.speed) {
      PlaybackSpeed.normal => PlaybackSpeed.slow,
      PlaybackSpeed.slow => PlaybackSpeed.slower,
      PlaybackSpeed.slower => PlaybackSpeed.normal,
    };
    await ref.read(ttsServiceProvider).setSpeechRate(next.rate);
    state = AsyncValue.data(session.copyWith(speed: next));
  }

  /// Marca scroll como completado.
  void markScrolledToEnd() {
    state = AsyncValue.data(
      state.requireValue.copyWith(scrolledToEnd: true),
    );
  }

  /// Acepta el contrato. Solo si reviewCompleted == true.
  Future<ContractAcceptance> accept() async {
    final session = state.requireValue;
    assert(session.reviewCompleted);

    return ContractAcceptance(
      contractId: session.contractId,
      acceptedAt: DateTime.now(),
      reviewMethod: session.sectionsHeard.length ==
              ContractSectionType.values.length
          ? ReviewMethod.audio
          : ReviewMethod.visual,
    );
  }

  Future<void> _readSection(ContractSectionType type) async {
    final session = state.requireValue;
    final section = session.contract.sections
        .firstWhere((s) => s.type == type);

    state = AsyncValue.data(session.copyWith(
      currentSection: type,
      ttsState: TtsState.playing,
    ));

    await ref.read(ttsServiceProvider).speak(
      '${section.title}. ${section.content}',
    );
  }

  void _onSectionComplete() {
    final session = state.requireValue;
    if (session.currentSection == null) return;

    final heard = {...session.sectionsHeard, session.currentSection!};
    final types = ContractSectionType.values;
    final currentIndex = types.indexOf(session.currentSection!);

    if (currentIndex < types.length - 1) {
      // Siguiente sección después de una pausa
      final next = types[currentIndex + 1];
      state = AsyncValue.data(session.copyWith(
        sectionsHeard: heard,
        ttsState: TtsState.idle,
      ));
      Future.delayed(
        const Duration(milliseconds: 800),
        () => _readSection(next),
      );
    } else {
      // Todas las secciones leídas
      state = AsyncValue.data(session.copyWith(
        sectionsHeard: heard,
        currentSection: null,
        ttsState: TtsState.completed,
      ));
    }
  }
}
```

**Contrato**:
- `startAutoRead()` se llama una vez al inicializar la pantalla (en `initState` o `ref.listen`).
- `pauseTts()` detiene la lectura y cambia estado a `paused`. `resumeTts()` reanuda desde la sección actual.
- `repeatSection()` re-lee la sección actual desde el inicio.
- `cycleSpeed()` cicla entre 3 velocidades y aplica al TTS inmediatamente.
- `markScrolledToEnd()` habilita `reviewCompleted` por vía visual.
- `accept()` solo puede llamarse si `reviewCompleted == true`. Retorna `ContractAcceptance` como registro.
- Las secciones se leen en orden del enum (`whatYouAccept` → `cost` → `risks` → `howToCancel`).
- Pausa de 800ms entre secciones para que el usuario procese.

## TtsPlaybackControls Widget

Ubicación: `lib/features/audio_contracts/presentation/widgets/tts_playback_controls.dart`

```dart
class TtsPlaybackControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(contractReviewNotifierProvider(contractId));
    final notifier = ref.read(contractReviewNotifierProvider(contractId).notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pausar / Reanudar
        Semantics(
          label: session.ttsState == TtsState.playing
              ? 'Pausar lectura'
              : 'Continuar lectura',
          child: IconButton(
            icon: Icon(session.ttsState == TtsState.playing
                ? Icons.pause_circle_filled
                : Icons.play_circle_filled),
            iconSize: 48,
            onPressed: session.ttsState == TtsState.playing
                ? notifier.pauseTts
                : notifier.resumeTts,
          ),
        ),
        const SizedBox(width: 16),
        // Repetir sección
        Semantics(
          label: 'Repetir esta sección',
          child: IconButton(
            icon: const Icon(Icons.replay),
            iconSize: 48,
            onPressed: session.currentSection != null
                ? notifier.repeatSection
                : null,
          ),
        ),
        const SizedBox(width: 16),
        // Velocidad
        Semantics(
          label: 'Velocidad: ${session.speed.label}',
          child: TextButton(
            onPressed: notifier.cycleSpeed,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
            child: Text(
              session.speed.label,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Contrato**:
- 3 controles, todos ≥ 48×48 dp.
- Cada control tiene `Semantics.label` en español.
- Pausar/Reanudar: toggle según `ttsState`.
- Repetir: deshabilitado si no hay sección activa.
- Velocidad: muestra porcentaje actual, cicla al tocar.

## AcceptButton Widget

Ubicación: `lib/features/audio_contracts/presentation/widgets/accept_button.dart`

```dart
class AcceptButton extends ConsumerWidget {
  final String contractId;
  final VoidCallback onAccepted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(contractReviewNotifierProvider(contractId));
    final enabled = session.valueOrNull?.reviewCompleted ?? false;

    return Semantics(
      label: enabled
          ? 'Aceptar contrato'
          : 'Primero lee o escucha el resumen para poder aceptar',
      child: ElevatedButton(
        onPressed: enabled ? () async {
          final acceptance = await ref
              .read(contractReviewNotifierProvider(contractId).notifier)
              .accept();
          onAccepted();
        } : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontSize: 20),
        ),
        child: const Text('Aceptar'),
      ),
    );
  }
}
```

**Contrato**:
- `onPressed` es `null` cuando `reviewCompleted == false` (botón deshabilitado visual y semánticamente).
- `Semantics.label` explica por qué está deshabilitado.
- Botón full-width, 56dp de alto, texto 20sp.

## Contrato de integración con 004 (TTS)

Dependencia: `ttsServiceProvider` de `lib/features/voice_assistant/presentation/providers/`.

```dart
// Inyección via Riverpod:
final tts = ref.read(ttsServiceProvider);

// Operaciones usadas:
await tts.speak(text);          // Lee texto
await tts.stop();               // Detiene lectura
await tts.setSpeechRate(rate);  // Cambia velocidad (0.5, 0.75, 1.0)
tts.setCompletionHandler(fn);   // Callback al terminar un utterance
```

**Si `TtsService` de 004 no expone `setSpeechRate()` ni `setCompletionHandler()`**: Se agregan al servicio existente. Son wrappers directos de `FlutterTts.setSpeechRate()` y `FlutterTts.setCompletionHandler()`. Cambio mínimo en 004.

## Contrato de integración con 004 (Asistente)

Botón "¿Tienes una pregunta?" navega al asistente con contexto:

```dart
context.push('/assistant', extra: {'source': 'contract', 'contractId': contractId});
```

El asistente de 004 puede leer el `extra` para contextualizar respuestas. Si 004 no soporta `extra`, el botón simplemente navega a `/assistant` sin contexto adicional.

## Rutas de navegación

```
/contracts/:contractId/summary   → ContractSummaryScreen
/contracts/:contractId/full      → FullContractScreen
```

Registradas en `go_router` como sub-rutas:

```dart
GoRoute(
  path: '/contracts/:contractId',
  redirect: (_, state) =>
      '/contracts/${state.pathParameters['contractId']}/summary',
  routes: [
    GoRoute(
      path: 'summary',
      builder: (_, state) => ContractSummaryScreen(
        contractId: state.pathParameters['contractId']!,
      ),
    ),
    GoRoute(
      path: 'full',
      builder: (_, state) => FullContractScreen(
        contractId: state.pathParameters['contractId']!,
      ),
    ),
  ],
),
```

## Invariantes

1. **4 secciones siempre**: Todo `ContractSummary` tiene exactamente 4 `ContractSection`, una por `ContractSectionType`.
2. **Botón bloqueado sin revisión**: `AcceptButton.enabled` solo es `true` cuando `reviewCompleted` (audio completo O scroll al final).
3. **TTS reutilizado**: Se usa el `TtsService` de 004, no se crea uno nuevo.
4. **Orden de lectura fijo**: Enum order (`whatYouAccept` → `cost` → `risks` → `howToCancel`).
5. **Sesión efímera**: `ReviewSession` no se persiste. Al cerrar la pantalla, se pierde el progreso.
6. **Lenguaje simple**: Todos los textos de resumen ≤ 15 palabras/oración, sin jerga financiera.
7. **Accesibilidad**: Controles ≥ 48×48 dp, contraste ≥ 4.5:1, Semantics labels en español, TalkBack anuncia sección activa y estado del botón "Aceptar".

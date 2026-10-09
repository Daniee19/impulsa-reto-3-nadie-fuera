import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/presentation/widgets/accessible_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/contract_summary.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/domain/entities/review_session.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/presentation/providers/contract_review_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/presentation/widgets/accept_button.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/audio_contracts/presentation/widgets/tts_playback_controls.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/tts_provider.dart';

/// Base TTS rate for elderly users.
const _baseTtsRate = 0.45;

/// Shows a contract summary with TTS playback and gated accept.
class ContractSummaryScreen extends ConsumerStatefulWidget {
  /// Creates a contract summary screen.
  const ContractSummaryScreen({required this.contractId, super.key});

  /// The contract to show.
  final String contractId;

  @override
  ConsumerState<ContractSummaryScreen> createState() =>
      _ContractSummaryScreenState();
}

class _ContractSummaryScreenState extends ConsumerState<ContractSummaryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(contractReviewProvider.notifier);
      notifier.startReview(widget.contractId);

      final repo = ref.read(contractRepositoryProvider);
      final contract = repo.getContractSummary(widget.contractId);

      A11yHelpers.screenAnnounce(
        View.of(context),
        '${contract.title}. '
        '${AppLocalizations.of(context)!.contract_sectionOf(1, 4)}',
      );

      _speakSection(contract.sections.first);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 20) {
      ref.read(contractReviewProvider.notifier).markScrolledToEnd();
    }
  }

  void _speakSection(ContractSection section) {
    final tts = ref.read(ttsProvider);
    final notifier = ref.read(contractReviewProvider.notifier);
    final session = ref.read(contractReviewProvider);

    final rate = _baseTtsRate * (session?.speed.rate ?? 1);
    tts.setSpeechRate(rate);

    notifier.setCurrentSection(section.type);
    notifier.setTtsState(TtsState.playing);

    tts.setCompletionHandler(() {
      notifier.markSectionHeard(section.type);
      _advanceToNextSection(section.type);
    });

    tts.speak('${section.title}. ${section.content}');
  }

  void _advanceToNextSection(ContractSectionType completed) {
    final repo = ref.read(contractRepositoryProvider);
    final contract = repo.getContractSummary(widget.contractId);
    final idx = contract.sections.indexWhere((s) => s.type == completed);
    if (idx < contract.sections.length - 1) {
      _speakSection(contract.sections[idx + 1]);
    } else {
      ref.read(contractReviewProvider.notifier).setTtsState(TtsState.completed);
      ref.read(contractReviewProvider.notifier).setCurrentSection(null);
    }
  }

  void _onPause() {
    ref.read(ttsProvider).stop();
    ref.read(contractReviewProvider.notifier).setTtsState(TtsState.paused);
  }

  void _onResume() {
    final session = ref.read(contractReviewProvider);
    if (session?.currentSection == null) return;
    final repo = ref.read(contractRepositoryProvider);
    final contract = repo.getContractSummary(widget.contractId);
    final section = contract.sections.firstWhere(
      (s) => s.type == session!.currentSection,
    );
    _speakSection(section);
  }

  void _onRepeat() {
    final session = ref.read(contractReviewProvider);
    if (session?.currentSection == null) return;
    final repo = ref.read(contractRepositoryProvider);
    final contract = repo.getContractSummary(widget.contractId);
    final section = contract.sections.firstWhere(
      (s) => s.type == session!.currentSection,
    );
    _speakSection(section);
  }

  void _onSpeedChange(PlaybackSpeed speed) {
    ref.read(contractReviewProvider.notifier).setSpeed(speed);
    final session = ref.read(contractReviewProvider);
    if (session?.ttsState == TtsState.playing &&
        session?.currentSection != null) {
      final tts = ref.read(ttsProvider);
      tts.setSpeechRate(_baseTtsRate * speed.rate);
    }
  }

  void _onAccept() {
    ref.read(ttsProvider).stop();
    ref.read(contractReviewProvider.notifier).clear();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.contract_accepted)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(contractReviewProvider);
    if (session == null) return const SizedBox.shrink();

    final repo = ref.read(contractRepositoryProvider);
    final contract = repo.getContractSummary(widget.contractId);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contract_summary_title)),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              contract.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.contract_disclaimer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < contract.sections.length; i++) ...[
              _SectionCard(
                section: contract.sections[i],
                sectionNumber: i + 1,
                total: contract.sections.length,
                isCurrentSection:
                    session.currentSection == contract.sections[i].type,
                isHeard: session.sectionsHeard.contains(
                  contract.sections[i].type,
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
            TtsPlaybackControls(
              onPause: _onPause,
              onResume: _onResume,
              onRepeat: _onRepeat,
              onSpeedChange: _onSpeedChange,
            ),
            const SizedBox(height: 24),
            AcceptButton(onAccept: _onAccept),
            const SizedBox(height: 16),
            AccessibleButton(
              text: l10n.contract_viewFull,
              icon: Icons.description,
              onPressed: () => context.go(
                '/easy-mode/contract/'
                '${widget.contractId}/full',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.sectionNumber,
    required this.total,
    required this.isCurrentSection,
    required this.isHeard,
  });

  final ContractSection section;
  final int sectionNumber;
  final int total;
  final bool isCurrentSection;
  final bool isHeard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Semantics(
      label:
          '${l10n.contract_sectionOf(sectionNumber, total)}. '
          '${section.title}. ${section.content}',
      child: Card(
        color: isCurrentSection ? theme.colorScheme.primaryContainer : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      section.title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (isHeard)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      semanticLabel: 'Escuchado',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(section.content, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

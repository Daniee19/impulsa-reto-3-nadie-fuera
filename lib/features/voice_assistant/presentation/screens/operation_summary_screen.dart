import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/voice_assistant_provider.dart';

enum _ConfirmPhase { idle, scanning, success, failed }

/// Shows the operation summary and animated biometric confirmation.
class OperationSummaryScreen extends ConsumerStatefulWidget {
  /// Creates the operation summary screen.
  const OperationSummaryScreen({super.key});

  @override
  ConsumerState<OperationSummaryScreen> createState() =>
      _OperationSummaryScreenState();
}

class _OperationSummaryScreenState
    extends ConsumerState<OperationSummaryScreen>
    with TickerProviderStateMixin {
  _ConfirmPhase _phase = _ConfirmPhase.idle;

  late final AnimationController _pulseCtrl;
  late final AnimationController _scanCtrl;
  late final AnimationController _successCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final summary = ref.read(voiceAssistantProvider)?.operationSummary;
      if (summary != null) {
        A11yHelpers.screenAnnounce(View.of(context), summary.spokenSummary);
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scanCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    if (_phase != _ConfirmPhase.idle && _phase != _ConfirmPhase.failed) return;

    setState(() => _phase = _ConfirmPhase.scanning);
    unawaited(HapticFeedback.mediumImpact());
    _pulseCtrl.stop();
    unawaited(_scanCtrl.forward(from: 0));

    final l10n = AppLocalizations.of(context)!;
    final ok = await ref
        .read(voiceAssistantProvider.notifier)
        .confirmWithBiometric(l10n.assistant_biometricReason);

    if (!mounted) return;

    if (ok) {
      setState(() => _phase = _ConfirmPhase.success);
      unawaited(HapticFeedback.heavyImpact());
      unawaited(_successCtrl.forward(from: 0));
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (mounted) context.go('/easy-mode');
    } else {
      setState(() => _phase = _ConfirmPhase.failed);
      unawaited(HapticFeedback.vibrate());
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final session = ref.watch(voiceAssistantProvider);
    final summary = session?.operationSummary;

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.assistant_title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Amount card
              Card(
                color: theme.colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        summary.recipientName,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: summary.spokenSummary,
                        excludeSemantics: true,
                        child: Text(
                          'S/ ${summary.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.displayMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Fingerprint area
              _FingerprintButton(
                phase: _phase,
                pulseCtrl: _pulseCtrl,
                scanCtrl: _scanCtrl,
                successCtrl: _successCtrl,
                onTap: _onConfirm,
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  switch (_phase) {
                    _ConfirmPhase.idle => l10n.assistant_confirmButton,
                    _ConfirmPhase.scanning => 'Verificando...',
                    _ConfirmPhase.success => 'Operación confirmada',
                    _ConfirmPhase.failed => 'Intenta de nuevo',
                  },
                  key: ValueKey(_phase),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _phase == _ConfirmPhase.failed
                        ? theme.colorScheme.error
                        : _phase == _ConfirmPhase.success
                            ? const Color(0xFF2E7D32)
                            : theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              // Cancel
              if (_phase != _ConfirmPhase.success)
                TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                  label: Text(l10n.assistant_cancelButton),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FingerprintButton extends StatelessWidget {
  const _FingerprintButton({
    required this.phase,
    required this.pulseCtrl,
    required this.scanCtrl,
    required this.successCtrl,
    required this.onTap,
  });

  final _ConfirmPhase phase;
  final AnimationController pulseCtrl;
  final AnimationController scanCtrl;
  final AnimationController successCtrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 140.0;

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: 'Confirmar con huella',
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple rings (idle pulse + scanning sweep)
              if (phase == _ConfirmPhase.idle ||
                  phase == _ConfirmPhase.failed)
                AnimatedBuilder(
                  animation: pulseCtrl,
                  builder: (_, __) => _PulseRings(
                    progress: pulseCtrl.value,
                    color: phase == _ConfirmPhase.failed
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    size: size,
                  ),
                ),
              if (phase == _ConfirmPhase.scanning)
                AnimatedBuilder(
                  animation: scanCtrl,
                  builder: (_, __) => _ScanRings(
                    progress: scanCtrl.value,
                    color: theme.colorScheme.primary,
                    size: size,
                  ),
                ),
              // Success burst
              if (phase == _ConfirmPhase.success)
                AnimatedBuilder(
                  animation: successCtrl,
                  builder: (_, __) => _SuccessBurst(
                    progress: successCtrl.value,
                    size: size,
                  ),
                ),
              // Center icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: phase == _ConfirmPhase.success
                      ? const Color(0xFF2E7D32)
                      : phase == _ConfirmPhase.failed
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    phase == _ConfirmPhase.success
                        ? Icons.check
                        : Icons.fingerprint,
                    key: ValueKey(phase == _ConfirmPhase.success),
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseRings extends StatelessWidget {
  const _PulseRings({
    required this.progress,
    required this.color,
    required this.size,
  });

  final double progress;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _RingPainter(
        progress: progress,
        color: color,
        ringCount: 2,
      ),
    );
  }
}

class _ScanRings extends StatelessWidget {
  const _ScanRings({
    required this.progress,
    required this.color,
    required this.size,
  });

  final double progress;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ScanPainter(progress: progress, color: color),
    );
  }
}

class _SuccessBurst extends StatelessWidget {
  const _SuccessBurst({required this.progress, required this.size});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BurstPainter(progress: progress),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.ringCount,
  });

  final double progress;
  final Color color;
  final int ringCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var i = 0; i < ringCount; i++) {
      final offset = i * 0.3;
      final t = (progress + offset) % 1.0;
      final radius = 40.0 + t * 25;
      final opacity = (1.0 - t) * 0.35;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _ScanPainter extends CustomPainter {
  _ScanPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var i = 0; i < 3; i++) {
      final t = (progress + i * 0.33) % 1.0;
      final radius = 42.0 + t * 28;
      const sweep = pi * 0.7;
      final startAngle = t * 2 * pi;
      final opacity = (1.0 - t) * 0.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ScanPainter old) => old.progress != progress;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const green = Color(0xFF2E7D32);
    const count = 12;
    for (var i = 0; i < count; i++) {
      final angle = (2 * pi / count) * i;
      final dist = 30 + progress * 35;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final dx = center.dx + cos(angle) * dist;
      final dy = center.dy + sin(angle) * dist;
      canvas.drawCircle(
        Offset(dx, dy),
        3 * (1.0 - progress * 0.5),
        Paint()..color = green.withValues(alpha: opacity * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}

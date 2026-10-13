import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/a11y/a11y_helpers.dart';
import 'package:impulsa_reto_3_nadie_fuera/core/l10n/l10n.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/assistant_intent.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/domain/entities/voice_session.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/microphone_consent_provider.dart';
import 'package:impulsa_reto_3_nadie_fuera/features/voice_assistant/presentation/providers/voice_assistant_provider.dart';

/// Main voice/text assistant screen with chat history.
class VoiceAssistantScreen extends ConsumerStatefulWidget {
  /// Creates the voice assistant screen.
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      A11yHelpers.screenAnnounce(
        View.of(context),
        l10n.assistant_title,
      );
      final notifier = ref.read(voiceAssistantProvider.notifier);
      notifier.setNavigate(
        (route, {extra}) => context.push(route, extra: extra),
      );
      notifier.startSession();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.hasContentDimensions) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSubmitText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    ref
        .read(voiceAssistantProvider.notifier)
        .processInput(text, InputSource.text);
    _textController.clear();
  }

  void _onIntentSelected(AssistantIntentType type) {
    final text = switch (type) {
      AssistantIntentType.checkBalance => 'ver saldo',
      AssistantIntentType.payBill => 'pagar recibo',
      AssistantIntentType.sendMoney => 'enviar dinero',
      AssistantIntentType.requestHelp => 'pedir ayuda',
      AssistantIntentType.unknown => '',
    };
    ref
        .read(voiceAssistantProvider.notifier)
        .processInput(text, InputSource.text);
  }

  void _onMicTap() {
    final hasConsent = ref.read(microphoneConsentProvider);
    if (!hasConsent) {
      context.push('/easy-mode/assistant/consent');
      return;
    }
    final notifier = ref.read(voiceAssistantProvider.notifier);
    final session = ref.read(voiceAssistantProvider);
    if (session?.status == VoiceSessionStatus.listening) {
      notifier.stopListening();
    } else {
      notifier.startListening();
    }
  }

  void _onMicLongPressStart() {
    final hasConsent = ref.read(microphoneConsentProvider);
    if (!hasConsent) {
      context.push('/easy-mode/assistant/consent');
      return;
    }
    HapticFeedback.mediumImpact();
    ref.read(voiceAssistantProvider.notifier).startListening();
  }

  void _onMicLongPressEnd() {
    ref.read(voiceAssistantProvider.notifier).stopListening();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(voiceAssistantProvider);
    final hasConsent = ref.watch(microphoneConsentProvider);
    final theme = Theme.of(context);
    final isListening =
        session?.status == VoiceSessionStatus.listening;
    final messages = session?.messages ?? [];

    if (messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.assistant_title)),
      body: SafeArea(
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: messages.isEmpty
                  ? _buildWelcome(theme, l10n)
                  : _buildChatList(theme, messages, session),
            ),
            // Quick action chips
            if (session?.status == VoiceSessionStatus.idle ||
                session == null)
              _buildQuickActions(l10n, theme),
            // Input bar
            _buildInputBar(
              theme,
              l10n,
              isListening,
              hasConsent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.record_voice_over,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.assistant_greeting,
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Habla o escribe, te escucho',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(
    ThemeData theme,
    List<ChatMessage> messages,
    VoiceSession? session,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      itemCount: messages.length +
          (session?.status == VoiceSessionStatus.processing
              ? 1
              : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: _TypingIndicator(),
          );
        }
        final msg = messages[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _ChatBubble(message: msg),
        );
      },
    );
  }

  Widget _buildQuickActions(
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickChip(
              icon: Icons.account_balance_wallet,
              label: l10n.easyMode_home_checkBalance,
              onTap: () => _onIntentSelected(
                AssistantIntentType.checkBalance,
              ),
            ),
            const SizedBox(width: 8),
            _QuickChip(
              icon: Icons.receipt_long,
              label: l10n.easyMode_home_payBill,
              onTap: () => _onIntentSelected(
                AssistantIntentType.payBill,
              ),
            ),
            const SizedBox(width: 8),
            _QuickChip(
              icon: Icons.send,
              label: l10n.easyMode_home_sendMoney,
              onTap: () => _onIntentSelected(
                AssistantIntentType.sendMoney,
              ),
            ),
            const SizedBox(width: 8),
            _QuickChip(
              icon: Icons.help,
              label: l10n.easyMode_home_getHelp,
              onTap: () => _onIntentSelected(
                AssistantIntentType.requestHelp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(
    ThemeData theme,
    AppLocalizations l10n,
    bool isListening,
    bool hasConsent,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface
                .withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          // Mic button — tap to toggle, long-press to hold-to-talk
          Semantics(
            label: isListening
                ? 'Detener grabación'
                : l10n.assistant_mic_label,
            hint: 'Mantén presionado para hablar',
            button: true,
            child: GestureDetector(
              onTap: _onMicTap,
              onLongPressStart: (_) => _onMicLongPressStart(),
              onLongPressEnd: (_) => _onMicLongPressEnd(),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale =
                      isListening ? _pulseAnimation.value : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening
                        ? Colors.red
                        : theme.colorScheme.primary,
                    boxShadow: isListening
                        ? [
                            BoxShadow(
                              color: Colors.red
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isListening
                        ? Icons.stop
                        : hasConsent
                            ? Icons.mic
                            : Icons.mic_off,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text input
          Expanded(
            child: Semantics(
              label: l10n.assistant_text_label,
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: isListening
                      ? l10n.assistant_listening
                      : l10n.assistant_text_label,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _onSubmitText(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton.filled(
              onPressed: _onSubmitText,
              icon: const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Semantics(
        liveRegion: !isUser,
        label: message.text,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Icon(
                  Icons.smart_toy,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
              ],
              if (isUser &&
                  message.source == InputSource.voice) ...[
                const Icon(
                  Icons.mic,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  message.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isUser
                        ? Colors.white
                        : theme.colorScheme.onSurface,
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

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 24,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Pensando...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: theme.colorScheme.primary.withValues(
        alpha: 0.1,
      ),
      labelStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: theme.colorScheme.primary.withValues(alpha: 0.3),
      ),
    );
  }
}

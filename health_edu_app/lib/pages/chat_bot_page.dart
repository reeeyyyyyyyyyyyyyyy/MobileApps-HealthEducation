import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/uticare_theme.dart';
import '../utils/ai_service.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  final List<String> _suggestions = [
    'Apa itu ISK?',
    'Gejala ISK apa saja?',
    'Cara mencegah ISK?',
    'Kebersihan area genital',
    'Berapa air yang harus diminum?',
  ];

  @override
  void initState() {
    super.initState();
    // Initial greeting
    _messages.add({
      'role': 'assistant',
      'content': 'Hai! Aku Suster Care, asisten kesehatanmu di UtiCare. '
          'Kamu bisa tanya apa saja tentang ISK, kesehatan saluran kemih, '
          'atau kebiasaan sehat pencegahan ISK. Ada yang bisa kubantu?',
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text.trim()});
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await AIService.chatWithAI(
        _messages.map((m) => {'role': m['role']!, 'content': m['content']!}).toList(),
      );

      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Ada kendala koneksi. Coba lagi nanti.',
          });
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openWhatsApp() async {
    // Placeholder - admin can set this number from CMS later
    final uri = Uri.parse('https://wa.me/6281234567890?text=Halo,%20saya%20ingin%20konsultasi%20tentang%20ISK');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: UtiCareTheme.primarySubtle,
                borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: UtiCareTheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suster Care',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 11, color: UtiCareTheme.success, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded, color: UtiCareTheme.success),
            onPressed: _openWhatsApp,
            tooltip: 'Hubungi Tenaga Kesehatan',
          ),
        ],
      ),
      body: Column(
        children: [
          // Suggestion chips (shown when few messages)
          if (_messages.length <= 2)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Topik yang bisa ditanyakan:', style: UtiCareTheme.caption),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _suggestions.map((s) {
                      return ActionChip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        onPressed: () => _sendMessage(s),
                        backgroundColor: UtiCareTheme.primarySubtle,
                        side: BorderSide(color: UtiCareTheme.primary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }

                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: UtiCareTheme.primarySubtle,
                            borderRadius: BorderRadius.circular(UtiCareTheme.radiusSm),
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: UtiCareTheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? UtiCareTheme.primary : UtiCareTheme.surface,
                            borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg).copyWith(
                              bottomRight: isUser ? const Radius.circular(4) : null,
                              bottomLeft: !isUser ? const Radius.circular(4) : null,
                            ),
                            border: isUser ? null : Border.all(color: UtiCareTheme.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            msg['content'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: isUser ? Colors.white : UtiCareTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // WhatsApp CTA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: InkWell(
              onTap: _openWhatsApp,
              borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: UtiCareTheme.successLight,
                  borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                  border: Border.all(color: UtiCareTheme.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_rounded, color: UtiCareTheme.success, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Hubungi Tenaga Kesehatan via WhatsApp',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: UtiCareTheme.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: UtiCareTheme.surface,
              border: Border(top: BorderSide(color: UtiCareTheme.border.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesanmu...',
                      filled: true,
                      fillColor: UtiCareTheme.surfaceAlt,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: UtiCareTheme.primary,
                    borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: UtiCareTheme.primarySubtle,
              borderRadius: BorderRadius.circular(UtiCareTheme.radiusSm),
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: UtiCareTheme.primary, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: UtiCareTheme.surface,
              borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
              border: Border.all(color: UtiCareTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 600 + (i * 200)),
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: UtiCareTheme.primary.withValues(alpha: 0.4 + (value * 0.3)),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

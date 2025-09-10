import 'package:flutter/material.dart';

class AiChatTab extends StatefulWidget {
  const AiChatTab({super.key});

  @override
  State<AiChatTab> createState() => _AiChatTabState();
}

class _AiChatTabState extends State<AiChatTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hello! I'm your AI farming assistant. How can I help you today? You can ask me about crop management, pest control, weather advice, or any other farming questions.",
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  final List<String> _quickQuestions = [
    "When should I water my tomatoes?",
    "How to deal with aphids?",
    "Best fertilizer for corn?",
    "Weather forecast impact",
    "Crop rotation advice",
    "Soil pH management",
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, time: DateTime.now()),
      );
    });

    _messageController.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text: _generateAIResponse(text),
            isUser: false,
            time: DateTime.now(),
          ),
        );
      });
    });
  }

  String _generateAIResponse(String question) {
    // Simple response generator - in real app, this would connect to an AI service
    final responses = {
      'water':
          "For optimal watering, check soil moisture 2-3 inches deep. Water early morning or late evening to reduce evaporation. Most crops need 1-2 inches per week.",
      'tomato':
          "Tomatoes need consistent watering - avoid both drought stress and overwatering. Water at the base to prevent leaf diseases. Mulching helps retain moisture.",
      'fertilizer':
          "Use balanced fertilizers during vegetative growth (N-P-K 10-10-10), then switch to lower nitrogen for flowering/fruiting stages. Always test soil first.",
      'pest':
          "Integrated Pest Management (IPM) is best: use beneficial insects, crop rotation, and targeted treatments only when necessary. Regular monitoring is key.",
      'weather':
          "Check local weather forecasts and adjust activities accordingly. Avoid fertilizing before heavy rains, and protect sensitive plants from extreme weather.",
    };

    final lowerQuestion = question.toLowerCase();
    for (final key in responses.keys) {
      if (lowerQuestion.contains(key)) {
        return responses[key]!;
      }
    }

    return "That's a great question! For the most accurate advice, I'd recommend consulting with local agricultural extension services or soil testing labs. Is there a specific aspect of farming you'd like to explore further?";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // Custom App Bar
        Container(
          padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ai assistant',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'FunnelDisplay',
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                        Text(
                          'get farming insights and advice',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Add chat history
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1FBA55).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF1FBA55).withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.history_outlined,
                        color: const Color(0xFF1FBA55),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Quick Questions
                if (_messages.length <= 1) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'FunnelDisplay',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickQuestions.map((question) {
                          return GestureDetector(
                            onTap: () {
                              _messageController.text = question;
                              _sendMessage();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                question,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],

                // Messages
                Column(
                  children: _messages
                      .map((message) => _buildMessage(message))
                      .toList(),
                ),

                const SizedBox(height: 100), // Bottom padding for input area
              ],
            ),
          ),
        ),

        // Fixed bottom input area
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about farming...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1FBA55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1FBA55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFF1FBA55).withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  topRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                border: Border.all(
                  color: message.isUser
                      ? const Color(0xFF1FBA55).withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.time),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_outline,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

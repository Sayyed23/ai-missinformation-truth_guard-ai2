import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truth_guard_ai/core/network/api_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialMessage;
  final String? initialLanguage;
  const ChatScreen({super.key, this.initialMessage, this.initialLanguage});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages =
      []; // {'role': 'user'|'ai', 'content': '...', 'assessment': '...', 'image_prompt': '...', 'logs': List<String>}
  bool _isLoading = false;
  String? _loadingMessage;
  List<String> _currentLogs = [];
  final ScrollController _scrollController = ScrollController();
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Hindi', 'Marathi'];
  String _selectedAgent = 'TruthGuard';
  final List<String> _agents = ['TruthGuard', 'Deep Search', 'LLM Auditor'];

  @override
  void initState() {
    super.initState();
    if (widget.initialLanguage != null) {
      _selectedLanguage = widget.initialLanguage!;
    }
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _messageController.text = widget.initialMessage!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage();
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isLoading = true;
      _loadingMessage = "Starting...";
      _currentLogs = [];
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final apiService = ref.read(apiServiceProvider);
      final stream = apiService.chat(
        message,
        language: _selectedLanguage,
        agentName: _selectedAgent,
      );

      await for (final event in stream) {
        if (event['type'] == 'log') {
          setState(() {
            _loadingMessage = event['message'];
            _currentLogs.add(event['message']);
          });
        } else if (event['type'] == 'result') {
          final data = event['data'];
          setState(() {
            _messages.add({
              'role': 'ai',
              'content': data['response'],
              'assessment': data['assessment'],
              'image_prompt': data['image_prompt'],
              'logs': List<String>.from(_currentLogs),
            });
            _isLoading = false;
            _loadingMessage = null;
            _currentLogs = [];
          });
        } else if (event['type'] == 'error') {
          setState(() {
            _messages.add({
              'role': 'ai',
              'content': 'Error: ${event['message']}',
            });
            _isLoading = false;
            _loadingMessage = null;
          });
        }
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'ai', 'content': 'Error: $e'});
        _isLoading = false;
        _loadingMessage = null;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getAssessmentColor(String? assessment) {
    switch (assessment) {
      case 'NECESSARY':
        return Colors.redAccent;
      case 'MISSING_CONTEXT':
        return Colors.orangeAccent;
      case 'CORRECT':
        return Colors.green;
      case 'UNCERTAIN':
        return Colors.grey;
      case 'OFF_TOPIC':
        return Colors.purpleAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TruthGuard Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAgent,
                    icon: const Icon(Icons.person, color: Colors.deepPurple),
                    items: _agents.map((String agent) {
                      return DropdownMenuItem<String>(
                        value: agent,
                        child: Text(
                          agent,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAgent = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    icon: const Icon(Icons.language, color: Colors.blueAccent),
                    items: _languages.map((String lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(
                          lang,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final assessment = msg['assessment'];
                final imagePrompt = msg['image_prompt'];

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser && assessment != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getAssessmentColor(assessment),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              assessment,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        if (!isUser &&
                            msg['logs'] != null &&
                            (msg['logs'] as List).isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ExpansionTile(
                              title: const Text(
                                "View Thought Process",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              dense: true,
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: const EdgeInsets.all(8),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.black87,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: (msg['logs'] as List).map<Widget>(
                                      (log) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            "> $log",
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontFamily: 'monospace',
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Text(msg['content'] ?? ''),
                        if (!isUser && imagePrompt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (msg['show_image'] == true)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'https://image.pollinations.ai/prompt/${Uri.encodeComponent(imagePrompt)}',
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              height: 350,
                                              width: double.infinity,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 350,
                                              width: double.infinity,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        msg['show_image'] = true;
                                      });
                                    },
                                    icon: const Icon(Icons.image),
                                    label: const Text('Generate Infographic'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _loadingMessage ?? "Thinking...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          if (_isLoading && _currentLogs.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 100,
              child: ListView.builder(
                reverse: true,
                itemCount: _currentLogs.length,
                itemBuilder: (context, index) {
                  // Show logs in reverse order (newest at bottom visually if not reversed, but we want auto scroll)
                  // Actually reverse: true puts index 0 at bottom.
                  // Let's just show the list normally but auto scroll?
                  // Or just show the last few?
                  // Let's show all, reverse order so newest is at top? No, newest at bottom is standard terminal.
                  // If reverse=true, index 0 is bottom. So we need to reverse the list or access from end.
                  final log = _currentLogs[_currentLogs.length - 1 - index];
                  return Text(
                    "> $log",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask something...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

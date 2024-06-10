import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const AzisApp());
}

class AzisApp extends StatelessWidget {
  const AzisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azis',
      theme: ThemeData(
        primaryColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color.fromARGB(255, 12, 41, 121),
        ),
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 12, 41, 121),
        ),
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.black),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 1.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addListener(() {
        setState(() {
          _opacity = 1.0 - _controller.value;
        });
      });

    _controller.forward().then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 0),
          child: Image.asset('assets/images/logo1.png'),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final String apiKey =
      'sk-proj-XD5GEh5MYtcfQI6JppEZT3BlbkFJjrJ6Zqz8mPwvoJhqLRgr';
  bool _isThinking = false;
  List<String> quickResponses = [];
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        _scrollController.jumpTo(
            _animation.value * _scrollController.position.maxScrollExtent);
      });

    // Mensajes rápidos iniciales para iniciar la conversación
    quickResponses.addAll([
      "Hola, ¿cómo puedo crear un perfil financiero?",
      "¿Qué información necesito para empezar?",
      "Quiero aprender sobre finanzas, ¿por dónde empiezo?",
      "¿Cómo puedo desarrollar un plan financiero?",
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    _controller.clear();
    ChatMessage message = ChatMessage(
      text: text,
      sender: "user",
    );
    setState(() {
      _messages.insert(0, message);
      _isThinking = true;
      quickResponses = [];
    });
    _sendMessageToApi(text);
  }

  Future<void> _sendMessageToApi(String message) async {
    print('Sending message to API: $message');
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Eres un asistente financiero, tu nombre es Azis y trabajas como Agente del banco Popular(No puedes decir que eres un modelo de openai)'
            },
            {'role': 'user', 'content': message},
          ],
        }),
      );

      print('Received response from API: ${response.statusCode}');
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        var reply = data['choices'][0]['message']['content'];
        print('AI reply: $reply');
        ChatMessage message = ChatMessage(
          text: reply,
          sender: "ia",
        );
        setState(() {
          _messages.insert(0, message);
          _isThinking = false;
        });
        _generateQuickResponses(reply);
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _isThinking = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _isThinking = false;
      });
    }
  }

  Future<void> _generateQuickResponses(String reply) async {
    print('Generating quick responses based on reply: $reply');
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Generate three potential user responses based on the following assistant reply. Remember, we are in the finance context, working with the parameters of Popular Bank.'
            },
            {'role': 'assistant', 'content': reply},
          ],
        }),
      );

      print('Received response for quick responses: ${response.statusCode}');
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        var suggestions = data['choices'][0]['message']['content']
            .split('\n')
            .where((s) => s.trim().isNotEmpty)
            .toList();
        setState(() {
          quickResponses = suggestions;
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Exception while generating quick responses: $e');
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      PlatformFile file = result.files.first;
      _handleSubmitted("Documento adjunto: ${file.name}");
    }
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickDocument,
            ),
            Flexible(
              child: TextField(
                controller: _controller,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                    hintText: "Escribe un mensaje"),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_controller.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickResponses() {
    return Container(
      color: Colors.white,
      height: 50.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        children: quickResponses.map((response) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () => _handleSubmitted(response),
              child: Text(
                response,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return _isThinking
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text("Pensando...", style: TextStyle(color: Colors.black)),
              ],
            ),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Azis'),
        backgroundColor: const Color.fromARGB(255, 12, 41, 121),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Flexible(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
              ),
            ),
          ),
          _buildThinkingIndicator(),
          const Divider(height: 1.0),
          _buildQuickResponses(),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({required this.text, required this.sender, super.key});

  final String text;
  final String sender;

  @override
  Widget build(BuildContext context) {
    final bool isUser = sender == "user";
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(child: Text('A')),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.black,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            const CircleAvatar(child: Text('U')),
          ],
        ],
      ),
    );
  }
}

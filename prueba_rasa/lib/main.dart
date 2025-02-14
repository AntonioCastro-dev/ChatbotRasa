import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

// Enumeración para los idiomas soportados
enum Language { spanish, english }

class BotResponse {
  final String text;

  const BotResponse({required this.text});

  factory BotResponse.fromJson(Map<String, dynamic> json) {
    return BotResponse(text: json['text']);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistente Virtual Rasa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  Language _currentLanguage = Language.spanish;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _initializeTextToSpeech();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = Language.values[prefs.getInt('language') ?? 0];
    });
  }

  Future<void> _saveLanguagePreference(Language language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('language', language.index);
  }

  Future<void> _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onError: (error) => _showErrorDialog('Error de inicialización de voz: $error'),
        onStatus: (status) => print(status),
      );
      if (!available) {
        _showErrorDialog('El reconocimiento de voz no está disponible en este dispositivo');
      }
    } catch (e) {
      _showErrorDialog('Error al inicializar el reconocimiento de voz: $e');
    }
  }

  Future<void> _initializeTextToSpeech() async {
    await flutterTts.setLanguage(_currentLanguage == Language.spanish ? 'es-ES' : 'en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    
    flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
              if (result.finalResult) {
                _sendMessage();
                _isListening = false;
              }
            });
          },
          localeId: _currentLanguage == Language.spanish ? 'es-ES' : 'en-US',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await flutterTts.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    await flutterTts.speak(text);
  }

  Future<void> _sendMessage() async {
  if (_controller.text.isEmpty) return;

  final String userMessage = _controller.text;
  setState(() {
    _messages.add(ChatMessage(text: userMessage, isUser: true));
    _controller.clear();
  });

  try {
    final botResponse = await sendMessageToRasa(userMessage);
    setState(() {
      _messages.add(ChatMessage(text: botResponse.text, isUser: false));
    });
    // Reproducir automáticamente la respuesta del bot
    await _speak(botResponse.text);
  } catch (error) {
    final errorMessage = "Error: No se pudo conectar con el servidor Rasa";
    setState(() {
      _messages.add(ChatMessage(
        text: errorMessage,
        isUser: false,
      ));
    });
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentLanguage == Language.spanish 
          ? 'Asistente Virtual' 
          : 'Virtual Assistant'),
        actions: [
          PopupMenuButton<Language>(
            icon: const Icon(Icons.language),
            onSelected: (Language language) {
              setState(() {
                _currentLanguage = language;
                _initializeTextToSpeech();
                _saveLanguagePreference(language);
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Language>>[
              const PopupMenuItem<Language>(
                value: Language.spanish,
                child: Text('Español'),
              ),
              const PopupMenuItem<Language>(
                value: Language.english,
                child: Text('English'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return ChatBubble(
                  message: message,
                  onTap: () => _speak(message.text),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _listen,
                  color: _isListening ? Colors.red : null,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: _currentLanguage == Language.spanish
                          ? 'Escribe un mensaje...'
                          : 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    flutterTts.stop();
    super.dispose();
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: message.isUser
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});
}

Future<BotResponse> sendMessageToRasa(String message) async {
  final response = await http.post(
    Uri.parse('http://192.168.160.1:5005/webhooks/rest/webhook'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'sender': 'user',
      'message': message,
    }),
  );

  if (response.statusCode == 200) {
    List<dynamic> responseData = jsonDecode(response.body);
    if (responseData.isEmpty) {
      throw Exception('No se recibió respuesta del servidor');
    }
    return BotResponse.fromJson(responseData[0]);
  } else {
    throw Exception('Error en la conexión con el servidor: ${response.statusCode}');
  }
}


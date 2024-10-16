import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isConnected = true;

  final String _apiKey = 'AIzaSyA9ejnBH-ZMI0zQFDHk9GTQ3cH5aPHGi0U';

  // Define los colores pastel
  final Color _lightPurple = Color(0xFFE6E6FA);
  final Color _lightPink = Color(0xFFFFC0CB);
  final Color _darkPurple = Color(0xFF8E44AD);

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _loadMessages();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString('chat_messages');
    if (messagesJson != null) {
      setState(() {
        _messages = (jsonDecode(messagesJson) as List)
            .map((item) => Map<String, String>.from(item))
            .toList();
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_messages', jsonEncode(_messages));
  }

  Future<void> _sendMessage() async {
    String message = _controller.text.trim();

    if (message.isNotEmpty) {
      setState(() {
        _messages.add({"role": "user", "parts": message});
        _isLoading = true;
        _controller.clear();
      });

      String botResponse = await _getBotResponse(message);

      setState(() {
        _messages.add({"role": "model", "parts": botResponse});
        _isLoading = false;
      });

      _saveMessages();
    }
  }

  Future<String> _getBotResponse(String userMessage) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_apiKey');

    // Preparar el historial de mensajes en el formato correcto
    List<Map<String, dynamic>> formattedMessages = _messages.map((message) {
      return {
        "role": message["role"],
        "parts": [
          {"text": message["parts"]}
        ]
      };
    }).toList();

    // Añadir el mensaje actual del usuario
    formattedMessages.add({
      "role": "user",
      "parts": [
        {"text": userMessage}
      ]
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": formattedMessages,
        "safetySettings": [
          {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('candidates') && data['candidates'].isNotEmpty) {
          String botMessage =
              data['candidates'][0]['content']['parts'][0]['text']?.trim() ??
                  'No response from bot';
          return botMessage;
        } else {
          return 'No candidates available in response';
        }
      } catch (e) {
        return 'Error parsing response: $e';
      }
    } else {
      return "Error: ${response.statusCode} ${response.body}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _lightPurple,
        elevation: 0,
        toolbarHeight: 120,
        flexibleSpace: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Image.asset(
                      'asset/img/uplogo.jpg',
                      height: 40,
                      width: 40,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'ChatBot',
                      style: TextStyle(
                        color: _darkPurple,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Nancy Guadalupe Jimenez Escobar - 221193',
                        style: TextStyle(
                          color: _darkPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Universidad Politécnica de Chiapas.   9°A',
                        style: TextStyle(
                          color: _darkPurple.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  bool isUserMessage = _messages[index]['role'] == 'user';
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: isUserMessage ? _lightPink : _lightPurple,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        _messages[index]['parts']!,
                        style: TextStyle(
                          color: _darkPurple,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(9.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_darkPurple),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(9.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: _darkPurple),
                    decoration: InputDecoration(
                      hintText: "Envía un mensaje...",
                      hintStyle: TextStyle(color: _darkPurple.withOpacity(0.6)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: _lightPink),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: _darkPurple, width: 2.0),
                      ),
                      filled: true,
                      fillColor: _lightPurple.withOpacity(0.3),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: _darkPurple),
                  onPressed: _isConnected ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

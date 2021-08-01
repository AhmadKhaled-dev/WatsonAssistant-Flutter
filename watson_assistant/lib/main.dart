import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ibm_watson_assistant/ibm_watson_assistant.dart';
import 'dart:io';
void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Voice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {

  stt.SpeechToText _speech= stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
   Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: (){
           _listen();
          assistant(_text);
          },
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: Text(
            _text,
            
            style: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords; 
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}

void assistant (String text) async{

  final auth = IbmWatsonAssistantAuth(
    assistantId: '2f68dd98-0bf9-4f80-978b-0def32d79cd1',
    url: 'https://api.eu-de.assistant.watson.cloud.ibm.com/instances/ed320605-9ccf-4e95-b918-b80698dbaedc',
    apikey: 'dAVIoFt4z2yfWe2zjamBEJimDoAoxoYE_9FQmwwxUh5i',
  );

  final dynamic bot = IbmWatsonAssistant(auth);

  final sessionId = await bot.createSession();
  print(sessionId);


  while(true){
    print("your response:");
    String question = text;
    
    final dynamic botRes = await bot.sendInput(question, sessionId: sessionId);
    //print(botRes.output.generic.first.text);
    print(botRes.responseText);
    question = 'bye';
    if(question=='bye'){
      break;
    }
  }
 
  bot.deleteSession(sessionId);

}

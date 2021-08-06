import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:watson_assistant/api/speech_api.dart';
import 'package:watson_assistant/main.dart';
import 'package:ibm_watson_assistant/ibm_watson_assistant.dart';
import 'package:flutter_tts/flutter_tts.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = 'Press the button and start speaking ::: NOTE SAY !BYE! TO END CONVO';
  bool isListening = false;
  final FlutterTts flutterTts = FlutterTts();
 
  @override
  Widget build(BuildContext context) {  
    return Scaffold(
        appBar: AppBar(
          title: Text(MyApp.title),
          centerTitle: true,
          actions: [

          ],
        ),
        body: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.all(30).copyWith(bottom: 150),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AvatarGlow(
          animate: isListening,
          endRadius: 75,
          glowColor: Theme.of(context).primaryColor,
          child: FloatingActionButton(
            child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 36),
            onPressed: toggleRecording,
          ),
        ),
      );
  }
  Future toggleRecording() async=> SpeechApi.toggleRecording(

        onResult: (text) => setState(() => this.text = text),
        onListening: (isListening) {
          setState(() => this.isListening = isListening);

          if (!isListening) {
            Future.delayed(Duration(seconds: 1), () {
              _assistant(text);
            });
          }
        },

      );
      
  void _assistant (text) async{
    final auth = IbmWatsonAssistantAuth(
      assistantId: '2f68dd98-0bf9-4f80-978b-0def32d79cd1',
      url: 'https://api.eu-de.assistant.watson.cloud.ibm.com/instances/ed320605-9ccf-4e95-b918-b80698dbaedc',
      apikey: 'dAVIoFt4z2yfWe2zjamBEJimDoAoxoYE_9FQmwwxUh5i',
    );

    final dynamic bot = IbmWatsonAssistant(auth);
    final sessionId = await bot.createSession();
    ///print(sessionId);
  
    print('your response: $text');
    String question = text;

  
    final dynamic botRes = await bot.sendInput(question, sessionId: sessionId);
    
    String response = botRes.responseText;
    print(response);

    if(text != 'bye'){
      await speak(response);
      toggleRecording();
    }

    bot.deleteSession(sessionId);

  }

  Future speak(text) async{

    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(text);
    
  }
}
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

  bool isIntialized = false;
  dynamic bot = '';
  dynamic sessionId = '';
  //intializer();

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

    
    ///print(sessionId);
  
    print('your response: $text');
    String question = text;
    
    if(!isIntialized){
      await intializer();
    }
    
    print(sessionId);

    dynamic botRes = await bot.sendInput(question, sessionId: sessionId);
    String response = await botRes.responseText;
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

  Future<void> intializer() async {
    isIntialized = true;
    final auth = IbmWatsonAssistantAuth(
      assistantId: '50eab400-4b27-4690-8c9d-c3cefb5760c5',
      url: 'https://api.us-south.assistant.watson.cloud.ibm.com/instances/41c945ac-df60-4f99-971d-34eb9197fce8',
      apikey: 'VYNIBb65AHWyPV4iTueF4Wmo8a6i-1AFJiVFzkaiSyQa',
    );


    bot = IbmWatsonAssistant(auth);
    sessionId = await bot.createSession();
  }
}
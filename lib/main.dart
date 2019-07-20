import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
//  Firestore.instance.collection("mensagens").snapshots().listen((snapshot) {
//    for (DocumentSnapshot doc in snapshot.documents) {
//    print(doc.data);
//    }
//  });
//

  runApp(MyApp());
}

final ThemeData IOSTheme = ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light);

final ThemeData DefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  primaryColor: Colors.orangeAccent[400],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chat App",
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context).platform == TargetPlatform.iOS
          ? IOSTheme
          : DefaultTheme,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat App"),
          centerTitle: true,
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: TextComposer(),
            )
          ],
        ),
      ),
    );
  }
}

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isComposing = false;
  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[200])))
            : null,
        child: Row(children: <Widget>[
          Container(
            child: IconButton(icon: Icon(Icons.photo_camera), onPressed: () {}),
          ),
          Expanded(
              child: TextField(
            decoration: InputDecoration.collapsed(hintText: "Enviar Mensagem"),
            onChanged: (text) {
              setState(() {
                _isComposing = text.length > 0;
              });
            },
          )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoButton(
                    child: Text("Enviar"),
                    onPressed: _isComposing ? () {} : null,
                  )
                : IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _isComposing ? () {} : null,
                  ),
          ),
        ]),
      ),
    );
  }
}

class ChatMenssage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0 ,horizontal: 10.0),
      child: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage("https://images.app.goo.gl/S8SHFYMKBsFd9wPV8"),
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    "Rafael",
                    style: Theme.of(context).textTheme.subhead,
                    
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text("testando"),
                  )
                ],
              ),
            )
          ],
      ),
    );
  }
}


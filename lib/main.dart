import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  Firestore.instance.collection("mensagens").snapshots().listen((snapshot) {
    for (DocumentSnapshot doc in snapshot.documents) {
    print(doc.data);
    }
  });


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

final _googleSingIn = GoogleSignIn();
final _auth = FirebaseAuth.instance;

Future<Null> _ensuredLoggedIn() async {
  GoogleSignInAccount user = _googleSingIn.currentUser;
  if (user == null) user = await _googleSingIn.signInSilently();
  if (user == null) user = await _googleSingIn.signIn();
  if (await _auth.currentUser() == null) {
    user = _handleSignIn() as GoogleSignInAccount;
  }
}

Future<FirebaseUser> _handleSignIn() async {
  final GoogleSignInAccount googleUser = await _googleSingIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user = await _auth.signInWithCredential(credential);
  print("signed in " + user.displayName);
  return user;
}

final _textController = TextEditingController();

_HandlerSubmitedTex(String text) async {
  await _ensuredLoggedIn();
  _sendMessage(text: text);
}

void _sendMessage({String text, String imgURL}) {
  Firestore.instance.collection("mensagens").add({
    "text": text,
    "imgURL": imgURL,
    "senderName": _googleSingIn.currentUser.displayName,
    "senderPhotoUrl": _googleSingIn.currentUser.photoUrl
  });
}

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
            Expanded(
              child: StreamBuilder(
                  stream:
                      Firestore.instance.collection("mensagens").snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        return ListView.builder(
                          reverse: true,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            List reversed =
                                snapshot.data.documents.reversed.toList();
                            return ChatMenssage(reversed[index].data);
                          },
                        );
                    }
                  }),
            ),
            Divider(
              height: 1,
            ),
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

  void _reset() {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

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
            controller: _textController,
            decoration: InputDecoration.collapsed(hintText: "Enviar Mensagem"),
            onChanged: (text) {
              setState(() {
                _isComposing = text.length > 0;
              });
            },
            onSubmitted: (text) {
              _HandlerSubmitedTex(text);
              _reset();
            },
          )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Theme.of(context).platform == TargetPlatform.iOS
                ? CupertinoButton(
                    child: Text("Enviar"),
                    onPressed: _isComposing
                        ? () {
                            _HandlerSubmitedTex(_textController.text);
                            _reset();
                          }
                        : null,
                  )
                : IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _isComposing
                        ? () {
                            _HandlerSubmitedTex(_textController.text);
                            _reset();
                          }
                        : null,
                  ),
          ),
        ]),
      ),
    );
  }
}

class ChatMenssage extends StatelessWidget {
  final Map<String, dynamic> data;

  ChatMenssage(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
                backgroundImage: NetworkImage(data["senderPhotoUrl"])),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data["nome"],
                  style: Theme.of(context).textTheme.subhead,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: data["imgURL"] != null
                      ? Image.network(data["imgURL"], width: 250.0)
                      : Text(data["text"]),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

//await auth.signInWithCredential(GoogleAuthProvider.getCredential(
//idToken: credentials.idToken, accessToken: credentials.accessToken));

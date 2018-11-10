import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(new FriendlyChatApp());

final ThemeData kIOSTheme = new ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light
);

final ThemeData kDefaultTheme = new ThemeData(
    primarySwatch: Colors.purple,
    accentColor: Colors.orangeAccent[400],
);

class FriendlyChatApp extends StatelessWidget {
    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'Friendly Chat',
            theme: defaultTargetPlatform == TargetPlatform.iOS ? kIOSTheme : kDefaultTheme,
            home: new ChatScreen(),
        );
    }
}

class ChatScreen extends StatefulWidget {
    @override
    State createState() => new ChatScreenState();
}

final List<String> _saved = <String>[];

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
    final TextEditingController _textController = new TextEditingController();
    final List<ChatMessage> _messages = <ChatMessage>[];
    bool _isComposing = false;

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
            appBar: new AppBar(
                title: new Text('FriendlyChat'),
                elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
                actions: <Widget>[
                    new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved,)
                ],
            ),
            body: Container(
              child: new Column(
                  children: <Widget>[
                      new Flexible(
                          child: new ListView.builder(
                              padding: new EdgeInsets.all(8.0),
                              reverse: true,
                              itemBuilder: (_, int index) => _messages[index],
                              itemCount: _messages.length,
                          ),
                      ),
                      new Divider(height: 1.0,),
                      new Container(
                          decoration: new BoxDecoration(
                              color: Theme.of(context).cardColor
                          ),
                          child: _buildTextComposer(),
                      )
                  ],
              ),
              decoration: Theme.of(context).platform == TargetPlatform.iOS ? new BoxDecoration(
                  border: new Border(top: new BorderSide(color: Colors.grey[200]))
              ) : null,
            )
        );
    } 

    Widget _buildTextComposer() {
        return new IconTheme(
            data: new IconThemeData(color: Theme.of(context).accentColor),
            child: new Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: new Row(children: <Widget>[
                    new Flexible(
                        child: new TextField(
                            controller: _textController,
                            onChanged: (String text) {
                                setState(() {
                                    _isComposing = text.length > 0;
                                });
                            },
                            onSubmitted: _handleSubmitted,
                            decoration: new InputDecoration.collapsed(
                                hintText: 'Send Message'
                            ),
                        ),
                    ),
                    new Container(
                        margin: new EdgeInsets.symmetric(horizontal: 4.0),
                        child: Theme.of(context).platform == TargetPlatform.iOS ? 
                        new CupertinoButton(
                            child: new Text('Send'),
                            onPressed: _isComposing ? () => _handleSubmitted(_textController.text) : null,
                        ): 
                        new IconButton(
                            icon: new Icon(Icons.send),
                            onPressed: _isComposing ? () => _handleSubmitted(_textController.text) : null,
                        ),
                    )
                ],)
            ),
        );
    }

    void _handleSubmitted(String text) {
        if (text != '') {
            _textController.clear();
            setState(() {                                                    //new
                _isComposing = false;                                          //new
            }); 
            ChatMessage message = new ChatMessage(
                text: text,
                animationController: new AnimationController(
                    duration: new Duration(milliseconds: 700),
                    vsync: this,
                ),
            );
            setState(() {
                _messages.insert(0, message);          
            });
            message.animationController.forward();
        }
    }

    @override
    void dispose() {
        for (ChatMessage message in _messages)
            message.animationController.dispose();
        
        super.dispose();
    }

    void _pushSaved() {
        Navigator.of(context).push(
            new MaterialPageRoute<void>(
                builder: (BuildContext context) {
                    final Iterable<ListTile> tiles = _saved.map(
                        (String message) {
                            return new ListTile(
                                title: new Text(
                                    message
                                ),
                            );
                        }
                    );

                    final List<Widget> divided = ListTile.divideTiles(
                        context: context,
                        tiles: tiles
                    ).toList();

                    return new Scaffold(
                        appBar: new AppBar(
                            title: const Text('Saved Suggestions'),
                        ),
                        body: new ListView(children: divided),
                    );
                }
            )
        );
    }
}

const String _name = 'arbiyanto wijaya';

class ChatMessage extends StatefulWidget {
    ChatMessage({ this.text, this.animationController });
    final String text;
    final AnimationController animationController;

    @override
    State createState() => new ChatMessageState();
}

class ChatMessageState extends State<ChatMessage> {
    @override
    Widget build(BuildContext context) {
        final bool alreadySaved = _saved.contains(widget.text);

        return SizeTransition(
            sizeFactor: new CurvedAnimation(parent: widget.animationController, curve: Curves.easeOut),
            axisAlignment: 0.0,
            child: new Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        new Container(
                            margin: const EdgeInsets.only(right: 16.0),
                            child: new CircleAvatar(child: new Text(_name[0]),),
                        ),
                        new Expanded(
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                  new Text(_name, style: Theme.of(context).textTheme.subhead),
                                  new Container(
                                      margin: const EdgeInsets.only(top: 5.0),
                                      child: new Text(widget.text),
                                  )
                              ],
                          ),
                        ),
                        new IconButton(
                            icon: new Icon(
                                alreadySaved ? Icons.favorite : Icons.favorite_border,
                                color: alreadySaved ? Colors.red : null,
                            ),
                            onPressed: () {
                                setState(() {
                                    if (alreadySaved) {
                                        _saved.remove(widget.text);
                                    } else {
                                        _saved.add(widget.text);
                                    }
                                    print(_saved);
                                    print(widget.text);
                                });
                            },
                        ),
                    ],
                ),
            ),
        );
    }
}
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const id = "/chat";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController(); 

  String message;
  FirebaseUser loggedInUser;

  void initState(){
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser()async{
    try{
      final user = await _auth.currentUser();
      if(user!=null){
        this.setState((){
          loggedInUser = user;
        });
        print(loggedInUser.email);    
      }
    }catch(e){
      print(e);
    }
  }

/* 
  void getMessages()async{
    final messages = await _firestore.collection('messages').getDocuments();
    for(var message in messages.documents){
      print(message.data);
    }
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: loggedInUser==null?
          Center(
            child:RefreshProgressIndicator()
          )
        :
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(firestore: _firestore,currentUser:loggedInUser.email),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        this.setState((){
                           message = value; 
                        });
                        //Do something with the user input.
                      },
                      style: TextStyle(color: Colors.black),
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                        messageTextController.clear();
                      _firestore.collection('messages').add({
                        'sender':loggedInUser.email,
                        'text':message
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  MessageStream({@required firestore,this.currentUser}):
  _firestore=firestore;

  final Firestore _firestore;
  final currentUser;

  Widget getStream(){
      return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbleList = List<MessageBubble>();
        for(var message in messages){
          messageBubbleList.add(MessageBubble(
            sender: message['sender'],
            text: message['text'],
            isUser:message['sender']==currentUser
            )
          );
        }
        
        return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(vertical:10,horizontal: 10),
              children:messageBubbleList
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('SNAPSHOT');
    print(_firestore.collection('messages').snapshots());
    return getStream();
  }
}

class MessageBubble extends StatelessWidget {
  
  final String sender;
  final String text;
  final bool isUser;

  MessageBubble({this.sender,this.text,this.isUser});
  @override
  Widget build(BuildContext context) {

    BorderRadius borderRadius(){
      return isUser?
             BorderRadius.only(
              topLeft:Radius.circular(30),
              bottomLeft:Radius.circular(30),
              bottomRight:Radius.circular(30)
            ):
            BorderRadius.only(
              topRight:Radius.circular(30),
              bottomLeft:Radius.circular(30),
              bottomRight:Radius.circular(30)
            );
    }

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isUser?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: <Widget>[
          Text(sender,style:TextStyle(
            fontSize: 12,
            color: Colors.blueGrey
          )),
          Material(
            borderRadius:borderRadius(),
            elevation: 5,
            color: isUser?Colors.lightBlueAccent:Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical:10),
              child: Text(text,
                style:TextStyle(
                  color:isUser?Colors.white:Colors.black38,
                  fontSize: 15
                )
              ),
            )
          ),
        ],
      ),
    );
  }
}
import 'package:chat_app/ads/ad_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/search/add_user.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Chat extends StatefulWidget {
  final String convId;
  final String convName;
  Chat({required this.convId, required this.convName});

  @override
  _ChatState createState() => _ChatState(convId: convId, convName: convName);
}

class _ChatState extends State<Chat> {
  final String convId;
  final String convName;

  TextEditingController messageEditingController = new TextEditingController();

  _ChatState({required this.convId, required this.convName});

  InterstitialAd? _interstitialAd;

  // TODO: Add _isInterstitialAdReady
  bool _isInterstitialAdReady = false;


  Widget chatMessages(){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore
        .instance
        .collection('messages')
        .where('conversation_id', isEqualTo: convId)
        .orderBy('datetime')
        .snapshots(),
      builder: (context, snapshot){
        return snapshot.hasData ?  ListView.builder(
          padding: const EdgeInsets.only(bottom: 60),          
          itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index){
              return MessageTile(
                message: snapshot.data!.docs[index].get('content'),
                sendByMe: FirebaseAuth.instance.currentUser!.uid == snapshot.data!.docs[index].get('from_id'),
              );
            }) : Container();
      },
    );
  }
  addMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      CollectionReference messages = FirebaseFirestore.instance.collection('messages');
      messages.add({
        'conversation_id' : convId,
        'content' : messageEditingController.text,
        'datetime' : DateTime.now(),
        'from_id' : FirebaseAuth.instance.currentUser!.uid,
        'type' : 'text'
      }).then((value) => 
        FirebaseFirestore
        .instance
        .collection('conversations')
        .doc(convId)
        .update({'last_message' : value.id})
      );
      
      setState(() {
        messageEditingController.text = "";
      });
    }
  }
  void addUser(BuildContext context) {
    Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => UserSearch(convId: convId, convName: convName,)));
  }

  

  @override
  Widget build(BuildContext context) {
    _loadInterstitialAd();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(convName),
            IconButton(
              onPressed: () => _isInterstitialAdReady? 
                _interstitialAd?.show() :
                addUser(context),
              icon: Icon(Icons.add, size: 30)
            )
          ]
        )
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(alignment: Alignment.bottomCenter,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                color: Colors.indigo[200],
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageEditingController,
                          decoration: InputDecoration(
                              hintText: "Message ...",
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              border: InputBorder.none
                          ),
                        )),
                    SizedBox(width: 16,),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36FFFFFF),
                                    const Color(0x0FFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight
                              ),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          padding: EdgeInsets.all(12),
                          child: Image.asset("assets/images/send.png",
                            height: 25, width: 25,)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // TODO: Implement _loadInterstitialAd()
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          this._interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              addUser(context);
            },
          );

          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }
  @override
    void dispose() {
      
    // TODO: Dispose an InterstitialAd object
    _interstitialAd?.dispose();

      super.dispose();
    }
}
class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({required this.message, required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(
            top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) :
            BorderRadius.only(
        topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
          bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe ? [
                const Color(0xff007EF4),
                const Color(0xff2A75BC)
              ] : [
                const Color(0x5f555555),
                const Color(0x5f555555)
              ],
            )
        ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'OverpassRegular',
            fontWeight: FontWeight.w300)),
      ),
    );
  }
}
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/ads/ad_helper.dart';
import 'package:chat_app/screens/auth/authenticate.dart';
import 'package:chat_app/screens/auth/profile.dart';
import 'package:chat_app/screens/auth/settings.dart';
import 'package:chat_app/screens/auth/sign_in.dart';
import 'package:chat_app/screens/search/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/home/home_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Home extends StatefulWidget {
  
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  // TODO: Add _bannerAd
  late BannerAd _bannerAd;

  // TODO: Add _isBannerAdReady
  bool _isBannerAdReady = false;

  // TODO: Add _rewardedAd
  late RewardedAd _rewardedAd;

  // TODO: Add _isRewardedAdReady
  bool _isRewardedAdReady = false;

  @override
  void initState() {
    // TODO: Initialize _bannerAd
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();

    _loadRewardedAd();
  }
  // TODO: Implement _loadRewardedAd()
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          this._rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                _isRewardedAdReady = false;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
          setState(() {
            _isRewardedAdReady = false;
          });
        },
      ),
    );
  }
  Widget build(BuildContext context) {
    Future<InitializationStatus> _initGoogleMobileAds() {
      // TODO: Initialize Google Mobile Ads SDK
      return MobileAds.instance.initialize();
    }
    // print("Add ready? "+_isBannerAdReady.toString());
    // print("Other Ad readi? "+_isRewardedAdReady.toString());
    return Scaffold(
      body: (_auth.currentUser == null)
        ? Authenticate()
        : Stack (children: [
          HomeBuilder(),
          if(_isBannerAdReady)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ]
      ),
      appBar: AppBar(
        backgroundColor: Colors.indigo[400],
        leading: Builder(builder: (BuildContext context) {
          return new GestureDetector(
            key: Key('drawer'),
            onTap: (){
              Scaffold.of(context).openDrawer();
            },
            child: new Container(
              child: Icon(Icons.list, size: 30),
              padding: new EdgeInsets.all(7.0),
            ),
          );
        }),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            showDisplayName(),
            IconButton(
                key: Key("New Convo"),
                onPressed: () => _isRewardedAdReady ? 
                _rewardedAd.show(onUserEarnedReward: (_, reward) {createNewConvo(context);}) : 
                createNewConvo(context),
                icon: Icon(Icons.add, size: 30)
            )
          ],
        )
      ),
      drawer: Drawer(
        //key: Key('drawer'),
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo[400],
              ),
              child: profilePic()
            ),
            ListTile(
              title: Text('Chats'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              },
            ),
          ],
        ),
      ),
    );
    
  }
  void createNewConvo(BuildContext context) {
    Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => Search()));
  }
  Future<String> displayName() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
    return docSnap.get('display_name');
  }
  Widget showDisplayName() {
    return FutureBuilder(
      future: displayName(),
        builder: (context, snapshot) {
          // if(!snapshot.hasData) {
          //   return Center (
          //     child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo)));
          // } else {
            return Text(snapshot.data.toString(), style: TextStyle(fontSize: 18), key: Key('username'),);
         // }
        },
    );
  }
  Future<String> profilePicURL() async {
    //String? photoURL = FirebaseAuth.instance.currentUser!.photoURL;
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
    return docSnap.get('profile_pic');
  }
  Widget profilePic() {
    return FutureBuilder(
      future: profilePicURL(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            constraints: BoxConstraints.expand(),
            child: Icon(Icons.account_circle_outlined, size: 75, color: Colors.indigo[100],)
          );
        } else if (snapshot.data.toString().isEmpty) {
          return Container(
            child: Icon(Icons.account_circle_outlined, size: 75, color: Colors.indigo[100],)
          );
        } else {
          String url = snapshot.data.toString();
          return Container(
            constraints: BoxConstraints.expand(),
            child: CachedNetworkImage(
              width: 75,
              height: 75,
              imageUrl: url,
              placeholder: (context,url) => Icon(Icons.account_circle_outlined, size: 75, color: Colors.indigo[100],),
              errorWidget: (context,url,error) => Icon(Icons.account_circle_outlined, size: 75, color: Colors.indigo[100],),
            )
          );
        }
      }
    );
  }
  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _bannerAd.dispose();
    
    // TODO: Dispose a RewardedAd object
    _rewardedAd.dispose();

    super.dispose();
  }
}
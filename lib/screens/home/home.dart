import 'package:chat_app/ads/ad_helper.dart';
import 'package:chat_app/screens/auth/authenticate.dart';
import 'package:chat_app/screens/auth/sign_in.dart';
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
  }
  
  Widget build(BuildContext context) {

    // @override
    // void initState() {
    //   // TODO: Initialize _bannerAd
    //   _bannerAd = BannerAd(
    //     adUnitId: AdHelper.bannerAdUnitId,
    //     request: AdRequest(),
    //     size: AdSize.banner,
    //     listener: BannerAdListener(
    //       onAdLoaded: (_) {
    //         setState(() {
    //           _isBannerAdReady = true;
    //         });
    //       },
    //       onAdFailedToLoad: (ad, err) {
    //         print('Failed to load a banner ad: ${err.message}');
    //         _isBannerAdReady = false;
    //         ad.dispose();
    //       },
    //     ),
    //   );

    //   _bannerAd.load();
    // }
    // @override
    // void dispose() {
    //   // TODO: Dispose a BannerAd object
    //   _bannerAd.dispose();


    //   super.dispose();
    // }

    Future<InitializationStatus> _initGoogleMobileAds() {
      // TODO: Initialize Google Mobile Ads SDK
      return MobileAds.instance.initialize();
    }
    print("Add ready? "+_isBannerAdReady.toString());
    return Scaffold(
        body: (_auth.currentUser == null)
            ? Authenticate()
            : Stack (children: [
              HomeBuilder(),
              if(_isBannerAdReady)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: _bannerAd.size.width.toDouble(),
                    height: _bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  ),
                ),]));
    
  }
    @override
    void dispose() {
      // TODO: Dispose a BannerAd object
      _bannerAd.dispose();
      super.dispose();
    }
}
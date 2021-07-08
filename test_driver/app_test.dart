//import 'package:flutter_driver/driver_extension.dart';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
//import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart';
//import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Flutter Auth Registration Test", () {
    //auth page
    final reg = find.text('Sign Up');
    final google = find.text('Sign in with Google');
    final signin = find.text('Sign in with Email');
    final anon = find.text('Sign in Anonymously');
    //sign in page
    final signInPage = find.byType('SignIn');
    final emailField = find.byValueKey('email-field');
    final passField = find.byValueKey('pass-field');
    final sub = find.text('Submit');
    final errMess = find.byValueKey('err');
    final okButt = find.text("Ok");
    //register page
    final signUpPage = find.byType('EmailSignUp');
    final reg_dnameField = find.byValueKey('dname-field');
    final reg_emailField = find.byValueKey("email-field");
    final reg_passField = find.byValueKey('pass-field');
    final reg_sub = find.text('Submit');
    //home
    final home = find.byType('Home');
    final drawer = find.byValueKey('drawer');
    final set = find.text('Settings');
    final newConvo = find.byValueKey('New Convo');
    //settings
    final settings = find.byType('SettingsPage'); 
    final logout = find.text('Logout');
    //search
    final search = find.byType('Search');
    final searchField = find.byValueKey('search-field');
    final searchButt = find.byValueKey('Search Button');
    final messageButt = find.byValueKey('Message');
    var emailDisplay = find.byValueKey('newguy@g.com');

    late FlutterDriver driver;
    setUpAll(()async{
      driver = await FlutterDriver.connect();
    });
    tearDownAll(()async {
      if (driver != null) {
        driver.close();
      }
    });
    // test("login with email and pass", () async {
    //   await driver.tap(signin);
    //   assert(signInPage != null);
    //   await driver.tap(emailField);
    //   await driver.enterText("test@g.com");
    //   await driver.tap(passField);
    //   await driver.enterText("pppppp");
    //   await driver.tap(sub);
    //   assert (home != null);
    //   await driver.tap(drawer);
    //   await driver.tap(set);
    //   assert (settings != null);
    //   await driver.tap(logout);
    //   await driver.waitUntilNoTransientCallbacks();
    // });
    // test("login with wrong password", () async {
    //   await driver.tap(signin);
    //   assert(signInPage != null);
    //   await driver.tap(emailField);
    //   await driver.enterText("test@g.com");
    //   await driver.tap(passField);
    //   await driver.enterText("pppappp");
    //   await driver.tap(sub);
    //   assert (errMess.toString() == "The password is invalid or the user does not have a password.");
    //   await driver.tap(okButt);
    //   await driver.waitUntilNoTransientCallbacks();
    // });
    // test("register", () async {
    //   await driver.tap(reg);
    //   assert(signInPage != null);
    //   await driver.tap(reg_dnameField);
    //   await driver.enterText("fakename");
    //   await driver.tap(reg_emailField);
    //   await driver.enterText("another@email.com");
    //   await driver.tap(reg_passField);
    //   await driver.enterText("pppppp");
    //   await driver.tap(sub);
    //   assert (home != null);
    //   await driver.waitUntilNoTransientCallbacks();
    // });
    test("start a convo", () async {
      await driver.tap(signin);
      assert(signInPage != null);
      await driver.tap(emailField);
      await driver.enterText("test@g.com");
      await driver.tap(passField);
      await driver.enterText("pppppp");
      await driver.tap(sub);
      assert (home != null);
      await driver.tap(newConvo);
      assert (search != null);
      await driver.tap(searchField);
      await driver.enterText("new guy");
      await driver.tap(searchButt);
      sleep(Duration(seconds: 5));
      emailDisplay = find.byValueKey('newguy@g.com');
      expect(await driver.getText(emailDisplay),'newguy@g.com');
      //expect(actual, matcher)
      // await driver.tap(searchButt);
      // await driver.tap(messageButt);
      // assert (home != null);
    });
  });
}
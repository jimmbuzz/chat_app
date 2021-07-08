import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

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
    var errMess = find.byValueKey('err');
    final okButt = find.text("Ok");
    //register page
    final signUpPage = find.byType('EmailSignUp');
    final regDnameField = find.byValueKey('dname-field');
    final regEmailField = find.byValueKey("email-field");
    final regPassField = find.byValueKey('pass-field');
    final regSub = find.text('Submit');
    //home
    final home = find.byType('Home');
    final drawer = find.byValueKey('drawer');
    final set = find.text('Settings');
    final newConvo = find.byValueKey('New Convo');
    var userName = find.byValueKey('username');
    var convoDisplayName;
    //settings
    final settings = find.byType('SettingsPage'); 
    final logout = find.text('Logout');
    final anonReg = find.text('Register');
    //search
    final search = find.byType('Search');
    final searchField = find.byValueKey('search-field');
    final searchButt = find.byValueKey('Search Button');
    final messageButt = find.byValueKey('Message');
    var emailDisplay;
    var convoName;
    var confirmButt;
    //conversation
    final addUserButt = find.byValueKey('add user');
    final message = find.byValueKey('message-field');
    final sendButt = find.byValueKey('send');
    var messageContent;
    //add user
    final addSearchField = find.byValueKey('search-field');
    final addSearchButt = find.byValueKey('Search Button');
    final addButt = find.byValueKey('Add');
    var addEmailDisplay;
    var returnButt;

    late FlutterDriver driver;
    setUpAll(()async{
      driver = await FlutterDriver.connect();
    });
    tearDownAll(()async {
      if (driver != null) {
        driver.close();
      }
    });
    test("login with email and pass", () async {
      await driver.tap(signin);
      assert(signInPage != null);
      await driver.tap(emailField);
      await driver.enterText("test@g.com");
      await driver.tap(passField);
      await driver.enterText("pppppp");
      await driver.tap(sub);
      assert (home != null);
      await driver.tap(drawer);
      await driver.tap(set);
      assert (settings != null);
      await driver.tap(logout);
      await driver.waitUntilNoTransientCallbacks();
    });
    test("register with email and password", () async {
      await driver.tap(reg);
      assert(signInPage != null);
      await driver.tap(regDnameField);
      await driver.enterText("fakename");
      await driver.tap(regEmailField);
      await driver.enterText("another@email.com");
      await driver.tap(regPassField);
      await driver.enterText("pppppp");
      await driver.tap(sub);
      sleep(Duration(seconds: 2));
      userName = find.byValueKey('username');
      expect(await driver.getText(userName), 'fakename');
      await driver.tap(drawer);
      await driver.tap(set);
      assert (settings != null);
      await driver.tap(logout);
      await driver.waitUntilNoTransientCallbacks();
    });
    test("sign in anon and register later", () async {
      await driver.tap(anon);
      sleep(Duration(seconds: 2));
      userName = find.byValueKey('username');
      expect(await driver.getText(userName), 'Anon');
      await driver.tap(drawer);
      await driver.tap(set);
      assert (settings != null);
      await driver.tap(anonReg);
      assert(signInPage != null);
      await driver.tap(regDnameField);
      await driver.enterText("No longer anon");
      await driver.tap(regEmailField);
      await driver.enterText("anonsnew@email.com");
      await driver.tap(regPassField);
      await driver.enterText("pppppp");
      await driver.tap(sub);
      sleep(Duration(seconds: 2));
      userName = find.byValueKey('username');
      expect(await driver.getText(userName), 'No longer anon');
      await driver.tap(drawer);
      await driver.tap(set);
      assert (settings != null);
      await driver.tap(logout);
      await driver.waitUntilNoTransientCallbacks();
    });
    test("start a conversation, add a user, and send a message", () async {
      await driver.tap(signin);
      assert(signInPage != null);
      await driver.tap(emailField);
      await driver.enterText("anonsnew@email.com");
      await driver.tap(passField);
      await driver.enterText("pppppp");
      await driver.tap(sub);
      assert (home != null);
      await driver.tap(newConvo);
      assert (search != null);
      await driver.tap(searchField);
      await driver.enterText("new guy");
      await driver.tap(searchButt);
      sleep(Duration(seconds: 2));
      emailDisplay = find.byValueKey('newguy@g.com');
      expect(await driver.getText(emailDisplay),'newguy@g.com');
      await driver.tap(messageButt);
      convoName = find.byValueKey('Convo name');
      confirmButt = find.byValueKey('Confirm butt');
      await driver.tap(convoName);
      await driver.enterText('A Convo name');
      await driver.tap(confirmButt);
      sleep(Duration(seconds: 2));
      userName = find.byValueKey('username');
      expect(await driver.getText(userName), 'No longer anon');
      convoDisplayName = find.text('A Convo name');
      await driver.tap(convoDisplayName);
      await driver.tap(addUserButt);
      await driver.tap(addSearchField);
      await driver.enterText('Bumbling Benjamin');
      await driver.tap(addSearchButt);
      sleep(Duration(seconds: 2));
      addEmailDisplay = find.byValueKey('bumbling.benjamin@gmail.com');
      expect(await driver.getText(addEmailDisplay),'bumbling.benjamin@gmail.com');
      await driver.tap(addButt);
      returnButt = find.text('Return');
      await driver.tap(returnButt);
      await driver.tap(message);
      await driver.enterText('Hello!');
      await driver.tap(sendButt);
      messageContent = find.text('Hello!');
      expect(await driver.getText(messageContent), 'Hello!');
      await driver.waitUntilNoTransientCallbacks();
    });
  });
}
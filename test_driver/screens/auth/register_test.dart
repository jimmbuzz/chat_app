import 'package:chat_app/main.dart';
import 'package:chat_app/screens/auth/authenticate.dart';
import 'package:chat_app/screens/auth/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFire extends Mock implements Firebase {}

void main() {
  test('register ...', () async {
    // TODO: Implement test
    final mockFire = MockFire();
    
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(MyApp());
  });
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:co_run/services/auth_service.dart';
import 'package:co_run/services/location_service.dart';
import 'package:co_run/services/firestore_service.dart';
import 'package:co_run/screens/wrapper.dart';
import 'package:co_run/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        Provider(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'coRun',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const Wrapper(),
      ),
    );
  }
}

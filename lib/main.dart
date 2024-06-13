import 'package:booksearchapp/constants/themes.dart';
import 'package:booksearchapp/firebase_options.dart';
import 'package:booksearchapp/pages/internet_connectivity.dart';
import 'package:booksearchapp/pages/login.dart';
import 'package:booksearchapp/pages/main_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    child: const MainApp(),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeData,
        home: StreamBuilder<List>(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, snapshot) {
            var data = snapshot.data;
            if(snapshot.hasData && data!.contains(ConnectivityResult.none)) return InternetCheck();
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.data!=null) {
                  Provider.of<ThemeProvider>(context).loadingTheme();
                  return MainPage();
                }
                return LoginPage();
              },
            );
          }
        ));
  }
}

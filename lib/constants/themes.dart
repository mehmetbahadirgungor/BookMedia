import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class DarkTheme {
  static const String backgroundColor = "1C1C1C";
  static const String darkColor = "252525";
}

class LightTheme {
  static const String backgroundColor = "FBF9F1";
  static const String darkColor = "E5E1DA";
}

ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    dividerColor: Colors.black,
    switchTheme: SwitchThemeData(
      thumbColor:
          MaterialStatePropertyAll(HexColor(LightTheme.backgroundColor)),
      trackColor: MaterialStatePropertyAll(HexColor(LightTheme.darkColor)),
    ),
    checkboxTheme:
        CheckboxThemeData(checkColor: MaterialStateProperty.all(Colors.black)),
    dialogTheme: DialogTheme(
      surfaceTintColor: HexColor(LightTheme.backgroundColor),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.black)),
    drawerTheme: DrawerThemeData(
      backgroundColor: HexColor(LightTheme.backgroundColor),
      surfaceTintColor: HexColor(LightTheme.backgroundColor),
    ),
    appBarTheme: AppBarTheme(
        color: HexColor(LightTheme.backgroundColor),
        surfaceTintColor: HexColor(LightTheme.backgroundColor)),
    cardTheme: CardTheme(
      surfaceTintColor: HexColor(LightTheme.darkColor),
      color: HexColor(LightTheme.darkColor),
    ),
    colorScheme: const ColorScheme.light().copyWith(
      background: HexColor(LightTheme.backgroundColor),
      primary: HexColor(LightTheme.darkColor),
    ));

ThemeData darkTheme = ThemeData(
    dividerColor: Colors.white,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStatePropertyAll(HexColor(DarkTheme.backgroundColor)),
      trackColor: MaterialStatePropertyAll(HexColor(DarkTheme.darkColor)),
    ),
    checkboxTheme:
        CheckboxThemeData(checkColor: MaterialStateProperty.all(Colors.white)),
    dialogTheme:
        DialogTheme(surfaceTintColor: HexColor(DarkTheme.backgroundColor)),
    drawerTheme: DrawerThemeData(
      backgroundColor: HexColor(DarkTheme.backgroundColor),
      surfaceTintColor: HexColor(DarkTheme.backgroundColor),
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
      primaryColor: Colors.white,
    )),
    appBarTheme: AppBarTheme(
        color: HexColor(DarkTheme.backgroundColor),
        surfaceTintColor: HexColor(DarkTheme.backgroundColor)),
    cardTheme: CardTheme(
      surfaceTintColor: HexColor(DarkTheme.darkColor),
      color: HexColor(DarkTheme.darkColor),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white)),
    colorScheme: const ColorScheme.dark().copyWith(
      background: HexColor(DarkTheme.backgroundColor),
      primary: HexColor(DarkTheme.darkColor),
    ));

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightTheme;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() async {
    if (_themeData == lightTheme) {
      themeData = darkTheme;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({"theme": "darkTheme"});
    } else {
      themeData = lightTheme;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({"theme": "lightTheme"});
    }
  }

  void loadingTheme() async {
    dynamic data;

    try {
      data = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      data = data?.data()["theme"];
      if (data == null) {
        throw Exception("Somethings went wrong");
      }
    } catch (e) {
      print("Error: $e");
    }


    if (data == "lightTheme") {
      themeData = lightTheme;
    } else if (data == "darkTheme") {
      themeData = darkTheme;
    }
  }
}

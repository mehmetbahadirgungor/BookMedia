import 'dart:io';

import 'package:flutter/material.dart';

class InternetCheck extends StatelessWidget {
  const InternetCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Connection Error"),
      content: Text("Please check your internet connection."),
      actions: [
        TextButton(onPressed: () {
          exit(0);
        }, child: Text("Ok"))
      ],
    );
  }
}
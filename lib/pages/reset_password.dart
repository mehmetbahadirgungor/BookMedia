import 'package:booksearchapp/layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();

  void confirmNewPasswordFunction() async {
    var user = FirebaseAuth.instance.currentUser;
    dynamic email = user?.email;

    if ((confirmNewPasswordController.text == newPasswordController.text)) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
            email: email, password: currentPasswordController.text);
        await user?.reauthenticateWithCredential(credential);
        
        await user?.updatePassword(confirmNewPasswordController.text);
        currentPasswordController.text = "";
        newPasswordController.text = "";
        confirmNewPasswordController.text = "";

        passwordFocusNode.unfocus();
        Navigator.of(context).pop();
      } on FirebaseAuthException catch (e) {
        // Handle errors (e.g., invalid current password)
        print('Error re-authenticating user: ${e.code}');
      }
    } else {
      print("Error re-authenticating user: Passwords are different from each other.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(
        title: Text("Reset Password"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: currentPasswordController,
              decoration: InputDecoration(hintText: "Current Password"),
              obscureText: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: newPasswordController,
              decoration: InputDecoration(hintText: "New Password"),
              obscureText: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: confirmNewPasswordController,
              focusNode: passwordFocusNode,
              onEditingComplete: confirmNewPasswordFunction,
              decoration: InputDecoration(hintText: "Confirm Password"),
              obscureText: true,
            ),
          ),
        ]),
      ),
    );
  }
}

import 'package:booksearchapp/layout.dart';
import 'package:booksearchapp/pages/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key, required this.username, required this.uid});
  final String username;
  final String uid;
  @override
  State<ChangeUsername> createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  TextEditingController usernameController = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();

  @override
  void initState(){
    super.initState();
    usernameController.text = widget.username;
  }

  void changeUsernameFunction() async {
    await FirebaseFirestore.instance.collection("users").doc(widget.uid).update({
      "username" : usernameController.text,
    });
    passwordFocusNode.unfocus();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MySettings();
    },));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar(
        title: Text("Change Username"),
      ),
      body: Padding(padding: EdgeInsets.fromLTRB(30, 10, 30, 10), child: TextField(
          focusNode: passwordFocusNode,
          onEditingComplete: changeUsernameFunction,
          controller: usernameController,
          decoration: InputDecoration(hintText: "Username"),
        ),),
    );
  }
}
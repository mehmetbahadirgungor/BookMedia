import 'package:booksearchapp/constants/themes.dart';
import 'package:booksearchapp/data/data.dart';
import 'package:booksearchapp/data/firebase_storage.dart';
import 'package:booksearchapp/layout.dart';
import 'package:booksearchapp/main.dart';
import 'package:booksearchapp/pages/change_username.dart';
import 'package:booksearchapp/pages/reset_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  bool switchValue_ = false;

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    dynamic uid = user?.uid;

    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          dynamic username =
              (snapshot.data?.data() == null) ? {} : snapshot.data?.data();

          username = (username["username"] == null) ? "" : username["username"];

          return Scaffold(
            drawer: SideBar(),
            appBar: NavBar(
              title: Text("Settings"),
            ),
            body: Padding(
              padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Theme"),
                      Switch(
                          value: switchValue_,
                          onChanged: (value) async {
                            setState(() {
                              switchValue_ = value;
                            });

                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme();
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return ChangeUsername(
                                username: username,
                                uid: uid,
                              );
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Username"),
                                Row(
                                  children: [
                                    Text(username),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return ResetPassword();
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Password"),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            var pickedImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedImage != null)
                              await ProfilePicture().uploadProfilePhoto(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  pickedImage);
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text("Profile Photo"),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Delete Photo"),
                                                content: Text(
                                                    "Are you sure to delete your profile photo?"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("No")),
                                                  TextButton(
                                                      onPressed: () {
                                                        try {
                                                          ProfilePicture()
                                                              .deleteProfilePhoto(
                                                                  uid);
                                                        } catch (e) {
                                                          print(e);
                                                        }
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("Yes"))
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text("Delete Photo", style: TextStyle(
                                          color: Colors.grey
                                        ),)),
                                  ],
                                ),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Delete Account"),
                                    content: Text(
                                        "Are you sure to delete your account?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("No")),
                                      TextButton(
                                          onPressed: () async {
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(FirebaseAuth.instance
                                                      .currentUser?.uid)
                                                  .delete();
                                              await ProfilePicture()
                                                  .deleteProfilePhoto(
                                                      FirebaseAuth.instance
                                                          .currentUser?.uid);
                                              await FirebaseAuth
                                                  .instance.currentUser
                                                  ?.delete();

                                              await fetchData().then((value) =>
                                                  Navigator.pushReplacement(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder:
                                                          (context, a1, a2) =>
                                                              MainApp(),
                                                      transitionDuration:
                                                          Duration.zero,
                                                      reverseTransitionDuration:
                                                          Duration.zero,
                                                    ),
                                                  ));
                                            } catch (e) {
                                              print(e);
                                            }
                                          },
                                          child: Text("Yes")),
                                    ],
                                  );
                                });
                          },
                          child: Text(
                            "Delete Account",
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 0, 0)),
                          )),
                      TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            fetchData().then((value) =>
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, a1, a2) => MainApp(),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                ));
                          },
                          child: Text("Sign Out",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 0, 0)))),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}

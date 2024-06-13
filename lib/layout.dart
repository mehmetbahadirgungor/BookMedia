// ignore_for_file: must_be_immutable

import 'package:booksearchapp/data/data.dart';
import 'package:booksearchapp/data/firebase_storage.dart';
import 'package:booksearchapp/pages/library.dart';
import 'package:booksearchapp/pages/main_page.dart';
import 'package:booksearchapp/pages/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key, this.title});
  final Widget? title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
    );
  }
}

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    dynamic email = user?.email;
    dynamic uid = user?.uid;
    dynamic photoURL = user?.photoURL;

    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          dynamic username =
              (snapshot.data?.data() == null) ? {} : snapshot.data?.data();

          username = (username["username"] == null) ? "" : username["username"];

          return FutureBuilder<String?>(
              future: ProfilePicture().getProfilePictureUrl(uid),
              builder: (context, snapshot) {
                String profilePhotoURL = (snapshot.data == null)
                    ? "https://upload.wikimedia.org/wikipedia/commons/a/ac/Default_pfp.jpg?20200418092106"
                    : snapshot.data!;

                return Drawer(
                    child: Column(
                  children: [
                    UserAccountsDrawerHeader(
                      margin: EdgeInsets.zero,
                      currentAccountPicture: ClipOval(
                        child: Image.network(
                          (user?.photoURL==null) ? profilePhotoURL : photoURL,
                          fit: BoxFit.cover,
                        ),
                      ),
                      accountName: Text(username),
                      accountEmail: Text(
                          email), // FirebaseAuth.instance.currentUser?.email
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        // Main Page
                        ListTile(
                          leading: const Icon(Icons.search),
                          title: const Text("Search"),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        MainPage(),
                                transitionDuration: const Duration(seconds: 1),
                                reverseTransitionDuration:
                                    const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),

                        // Library
                        ListTile(
                          leading: const Icon(Icons.my_library_books),
                          title: const Text("Library"),
                          onTap: () async {
                            // pulling data
                            dynamic libraryData = await FirebaseFirestore
                                .instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser?.uid)
                                .get();
                            libraryData = (libraryData.data() != null)
                                ? (libraryData.data()["library"] != null)
                                    ? libraryData.data()["library"]
                                    : []
                                : [];

                            List data = await getSingleData(libraryData);
                            Map dataCategories = getCategories(data);

                            await fetchData().then((value) {
                              try {
                                return Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            LibraryBooks(
                                      data: data,
                                      dataCategories: dataCategories,
                                    ),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              } catch (e) {
                                print(e);
                              }
                            });
                          },
                        ),

                        // Settings
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: const Text("Settings"),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        const MySettings(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      ],
                    ))
                  ],
                ));
              });
        });
  }
}

class CheckBoxBar extends StatefulWidget {
  CheckBoxBar(
      {super.key,
      required this.title,
      required this.isChecked,
      required this.dataCategories});

  final String title;
  bool? isChecked;
  Map dataCategories;
  @override
  State<CheckBoxBar> createState() => _CheckBoxBarState();
}

class _CheckBoxBarState extends State<CheckBoxBar> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(widget.title),
        value: widget.isChecked,
        onChanged: (e) {
          setState(() {
            widget.isChecked = e;
            widget.dataCategories[widget.title] = widget.isChecked;
          });
        });
  }
}

class MyComment extends StatelessWidget {
  const MyComment({
    super.key,
    required this.userUID,
    required this.username,
    required this.comment,
  });

  final String userUID;
  final String username;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ProfilePicture().getProfilePictureUrl(userUID),
      builder: (context, snapshot) {
        String profilePhotoURL = (snapshot.data == null)
                    ? "https://upload.wikimedia.org/wikipedia/commons/a/ac/Default_pfp.jpg?20200418092106"
                    : snapshot.data!;
        
        return Container(
          width: EdgeInsetsGeometry.infinity.vertical,
          margin: EdgeInsets.all(7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  profilePhotoURL,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              Flexible(
                child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$username  $comment",
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            children: [],
                          ),
                        )
                      ],
                    )),
              ),
            ],
          ),
        );
      }
    );
  }
}

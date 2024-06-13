import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/book_page.dart';

class BookCard extends StatefulWidget {
  const BookCard({
    super.key,
    required this.id,
    required this.title,
    required this.publicationYear,
    required this.author,
    required this.coverImage,
    required this.description,
    required this.categories,
    required this.selfLink,
    required this.publisher,
    required this.industryIdentifiers,
    required this.pageCount,
    required this.previewLink,
    required this.saleInfo,
    required this.accessInfo,
  });
  final String id;
  final String title;
  final String publicationYear;
  final String author;
  final String description;
  final String coverImage;
  final List categories;
  final String selfLink;
  final String publisher;
  final List industryIdentifiers;
  final int pageCount;
  final String previewLink;
  final Map saleInfo;
  final Map accessInfo;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  dynamic data;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    late IconData icon;

    void routeToBookPage() {
      setState(() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => BookPage(
                      id: widget.id,
                      title: widget.title,
                      publicationYear: widget.publicationYear,
                      author: widget.author,
                      coverImage: widget.coverImage,
                      description: widget.description,
                      categories: widget.categories,
                      selfLink: widget.selfLink,
                      publisher: widget.publisher,
                      industryIdentifiers: widget.industryIdentifiers,
                      pageCount: widget.pageCount,
                      previewLink: widget.previewLink,
                      saleInfo: widget.saleInfo,
                      accessInfo: widget.accessInfo,
                    )));
      });
    }

    void backendOfAddRemoveButton() {
      if (icon == Icons.add) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  const Text("Adding Book", style: TextStyle(fontSize: 20)),
              content: const Text("Are you sure to add this book from your library?",
                  style: TextStyle(fontSize: 15)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () async {
                    // Pull data
                    dynamic data = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .get();

                    // data guard
                    if (data.data()["library"] == null) {
                      // if there is no book
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .update({"library": []});
                    }
                    var loadData =
                        (data.data()["library"] != null) ? data.data()["library"] : [];
                    loadData.add(widget.selfLink);

                    // adding book to data
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .update({"library": loadData});

                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:
                  const Text("Removing Book", style: TextStyle(fontSize: 20)),
              content: const Text(
                  "Are you sure to remove this book from your library?",
                  style: TextStyle(fontSize: 15)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () async {
                    // Pull data
                    dynamic data = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .get();

                    // data guard
                    if (data.exists) {
                      List loadData = data.data()["library"];
                      loadData.remove(widget.selfLink);

                      if (loadData.isNotEmpty) {
                        // removing book from data
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .update({"library": loadData});
                      } else {  
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .update({"library": FieldValue.delete()});
                      }
                    }
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        );
      }
    }

    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          try {
            data = snapshot.data?.data();
            data = data["library"];

            if (data.contains(widget.selfLink)) {
                icon = Icons.remove;
            } else {
              icon = Icons.add;
            }

          } catch (e) {
            icon = Icons.add;
          }

          return InkWell(
            onTap: routeToBookPage,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 18),
                        child: DecoratedBox(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: (brightness == Brightness.dark)
                                  ? Colors.white.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ]),
                          child: Image.network(
                            widget.coverImage,
                            width: MediaQuery.of(context).size.width / 6,
                            height: MediaQuery.of(context).size.height / 9,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.publicationYear,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.author,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(icon),
                        onPressed: backendOfAddRemoveButton,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

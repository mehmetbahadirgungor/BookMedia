import 'package:booksearchapp/layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookPage extends StatefulWidget {
  const BookPage({
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
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  TextEditingController commentController_ = TextEditingController();
  FocusNode _focusNode = FocusNode();
  dynamic data;

  Future<void> _launchUrl(String url) async {
    var _url = Uri.parse(url);
    if (!await launchUrl(_url,mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  void sendComment() async {
    // Pull data
    dynamic data = await FirebaseFirestore.instance
        .collection('books')
        .doc(widget.id)
        .get();

    // data guard
    if (data.data() == null) {
      // if there is no book
      await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.id)
          .set({"comments": []});
      data = await FirebaseFirestore.instance
          .collection('books')
          .doc(widget.id)
          .get();
    }

    // Pull user
    dynamic username = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    Map comment = {
      "userUID": FirebaseAuth.instance.currentUser?.uid,
      "username": username["username"],
      "comment": commentController_.text
    };

    List loadData =
        (data.data()["comments"] != null) ? data.data()["comments"] : [];
    loadData.add(comment);

    // adding book to data
    await FirebaseFirestore.instance
        .collection('books')
        .doc(widget.id)
        .update({"comments": loadData});

    setState(() {
      _focusNode.unfocus();
      commentController_.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Scaffold(
      appBar: NavBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        primary: false,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: (brightness == Brightness.dark)
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.network(
                      widget.coverImage,
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.width / 4,
                      height: MediaQuery.of(context).size.height / 5,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, top: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              widget.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Text(widget.publicationYear),
                            Text("Categories: ${widget.categories.join(", ")}"),
                          ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 0.7, indent: 0.0, endIndent: 0.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Publisher: ${widget.publisher}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "ISBN: ${(widget.industryIdentifiers.isNotEmpty) ? widget.industryIdentifiers[0]["identifier"] : null}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Page Count: ${widget.pageCount}"),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "E-Book: ${(widget.saleInfo["isEbook"]) ? "Yes" : "No"}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "List Price: ${(widget.saleInfo["listPrice"] != null && widget.saleInfo["listPrice"].length! <= 2) ? "${widget.saleInfo["listPrice"]["amount"]} ${widget.saleInfo["listPrice"]["currencyCode"]}" : null}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Access: ${widget.accessInfo["accessViewStatus"][0] + widget.accessInfo["accessViewStatus"].substring(1).toLowerCase()}"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 0.7, indent: 0.0, endIndent: 0.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("Preview Link: "),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await _launchUrl(widget.previewLink);
                            },
                            child: Text(
                              widget.previewLink,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text("Buy Link: "),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (widget.saleInfo["buyLink"]!=null) await _launchUrl(widget.saleInfo["buyLink"]);
                            },
                            child: Text(
                              "${widget.saleInfo["buyLink"]}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 0.7, indent: 0.0, endIndent: 0.0),
              const Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const Divider(thickness: 0.7, indent: 0.0, endIndent: 0.0),

              // Comments
              const Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Text(
                  "Comments",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Comment
              FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('books')
                      .doc(widget.id)
                      .get(),
                  builder: (context, snapshot) {
                    data = (snapshot.data?.data() == null)
                        ? {}
                        : snapshot.data?.data();

                    data = (data["comments"] == null) ? [] : data["comments"];

                    return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return MyComment(
                          userUID: data[index]["userUID"],
                          username: data[index]["username"],
                          comment: data[index]["comment"],
                        );
                      },
                    );
                  }),

              // Send Comment
              TextField(
                focusNode: _focusNode,
                controller: commentController_,
                onEditingComplete: sendComment,
                decoration: InputDecoration(
                    hintText: "Comment",
                    suffixIcon: IconButton(
                        onPressed: sendComment, icon: Icon(Icons.send))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:booksearchapp/widgets/book_card.dart';
import 'package:booksearchapp/layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LibraryBooks extends StatefulWidget {
  const LibraryBooks({
    super.key,
    required this.data,
    required this.dataCategories,
  });

  final List data;
  final Map dataCategories;

  @override
  State<LibraryBooks> createState() => _LibraryBooksState();
}

class _LibraryBooksState extends State<LibraryBooks> {
  late List showByCategories;
  TextEditingController searchBarController = TextEditingController();

  void backendOfshowingByCategories() {
    if (widget.dataCategories.values.contains(true)) {
      List chosenCategories = widget.dataCategories.keys
          .where((element) => widget.dataCategories[element] == true)
          .toList();
      showByCategories = showByCategories.where((element) {
        for (int i = 0; i < chosenCategories.length; i++) {
          if (element["volumeInfo"]["categories"]
              .contains(chosenCategories[i])) {
            return true;
          }
        }
        return false;
      }).toList();
    }
  }

  void backendOfsearchBar() {
    if (searchBarController.value.text.isNotEmpty) {
      showByCategories = showByCategories.where((element) {
        for (int i = 0; i < element["volumeInfo"].values.length; i++) {
          if (element["volumeInfo"].values.toList()[i] is String) {
            if (element["volumeInfo"]
                .values
                .toList()[i]
                .toLowerCase()
                .contains(searchBarController.value.text.toLowerCase())) {
              return true;
            }
          }
        }
        return false;
      }).toList();
    }
  }

  Widget showingBooksOnApp(BuildContext context, int index) {
    if (showByCategories[index]["volumeInfo"]["categories"] == null) {
      showByCategories[index]["volumeInfo"]["categories"] = [];
    }
    if (showByCategories[index]["volumeInfo"]["publishedDate"] == null) {
      showByCategories[index]["volumeInfo"]["publishedDate"] = "";
    }
    if (showByCategories[index]["volumeInfo"]["authors"] == null) {
      showByCategories[index]["volumeInfo"]["authors"] = [""];
    }
    if (showByCategories[index]["volumeInfo"]["imageLinks"] == null) {
      showByCategories[index]["volumeInfo"]["imageLinks"] = {
        "thumbnail": "https://via.placeholder.com/687x1000"
      };
    }
    if (showByCategories[index]["volumeInfo"]["description"] == null) {
      showByCategories[index]["volumeInfo"]["description"] = "";
    }
    if (showByCategories[index]["volumeInfo"]["publisher"] == null) {
      showByCategories[index]["volumeInfo"]["publisher"] = "";
    }
    if (showByCategories[index]["volumeInfo"]["industryIdentifiers"] == null) {
      showByCategories[index]["volumeInfo"]["industryIdentifiers"] = [];
    }
    if (showByCategories[index]["volumeInfo"]["pageCount"] == null) {
      showByCategories[index]["volumeInfo"]["pageCount"] = 0;
    }
    if (showByCategories[index]["volumeInfo"]["previewLink"] == null) {
      showByCategories[index]["volumeInfo"]["previewLink"] = "";
    }
    return BookCard(
      id: showByCategories[index]["id"],
      title: showByCategories[index]["volumeInfo"]["title"],
      publicationYear: showByCategories[index]["volumeInfo"]["publishedDate"],
      author: showByCategories[index]["volumeInfo"]["authors"][0],
      coverImage: showByCategories[index]["volumeInfo"]["imageLinks"]
          ["thumbnail"],
      description: showByCategories[index]["volumeInfo"]["description"],
      categories: showByCategories[index]["volumeInfo"]["categories"],
      selfLink: showByCategories[index]["selfLink"],
      publisher: showByCategories[index]["volumeInfo"]["publisher"],
      industryIdentifiers: showByCategories[index]["volumeInfo"]
          ["industryIdentifiers"],
      pageCount: showByCategories[index]["volumeInfo"]["pageCount"],
      previewLink: showByCategories[index]["volumeInfo"]["previewLink"],
      saleInfo: showByCategories[index]["saleInfo"],
      accessInfo: showByCategories[index]["accessInfo"],
    );
  }

  void backendOfCategoryFilter() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Categories"),
            content: SingleChildScrollView(
              child: Column(
                children: widget.dataCategories.keys
                    .map((title) => CheckBoxBar(
                          title: title,
                          isChecked: widget.dataCategories[title],
                          dataCategories: widget.dataCategories,
                        ))
                    .toList(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: const Text("Ok"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    showByCategories = widget.data;

    backendOfshowingByCategories();
    backendOfsearchBar();

    return Scaffold(
      drawer: const SideBar(),
      appBar: const NavBar(
        title: Text("Library"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 3, 0, 0),
            child: Row(
              children: [
                Flexible(
                  child: CupertinoSearchTextField(
                    controller: searchBarController,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                IconButton(
                  onPressed: backendOfCategoryFilter,
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: showByCategories.length,
              itemBuilder: showingBooksOnApp,
            ),
          )),
        ],
      ),
    );
  }
}

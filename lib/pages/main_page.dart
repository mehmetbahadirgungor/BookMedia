import 'package:booksearchapp/widgets/book_card.dart';
import 'package:booksearchapp/data/data.dart';
import 'package:booksearchapp/layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List data = [];
  bool check = true;
  TextEditingController searchBarController = TextEditingController();

  void searchBarFunction(String value) async {
    if (value != "") {
      data = await getData(value);
    } else {
      data = [];
    }
    setState(() {});
  }

  Widget showingBooksOnApp(BuildContext context, int index) {
    return BookCard(
      id: data[index]["id"],
      title: data[index]["volumeInfo"]["title"],
      publicationYear: (data[index]["volumeInfo"]["publishedDate"] != null)
          ? data[index]["volumeInfo"]["publishedDate"]
          : "",
      author: (data[index]["volumeInfo"]["authors"] != null)
          ? data[index]["volumeInfo"]["authors"][0]
          : "",
      coverImage: (data[index]["volumeInfo"]["imageLinks"] != null)
          ? data[index]["volumeInfo"]["imageLinks"]["thumbnail"]
          : "https://bookstoreromanceday.org/wp-content/uploads/2020/08/book-cover-placeholder.png",
      description: (data[index]["volumeInfo"]["description"] != null)
          ? data[index]["volumeInfo"]["description"]
          : "",
      categories: (data[index]["volumeInfo"]["categories"] != null)
          ? data[index]["volumeInfo"]["categories"]
          : [],
      selfLink: data[index]["selfLink"],
      publisher: (data[index]["volumeInfo"]["publisher"] != null)
          ? data[index]["volumeInfo"]["publisher"]
          : "",
      industryIdentifiers:
          (data[index]["volumeInfo"]["industryIdentifiers"] != null)
              ? data[index]["volumeInfo"]["industryIdentifiers"]
              : [],
      pageCount: (data[index]["volumeInfo"]["pageCount"] != null)
          ? data[index]["volumeInfo"]["pageCount"]
          : 0,
      previewLink: (data[index]["volumeInfo"]["previewLink"] != null)
          ? data[index]["volumeInfo"]["previewLink"]
          : "",
      saleInfo: data[index]["saleInfo"],
      accessInfo: data[index]["accessInfo"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideBar(),
      appBar: NavBar(
        title: CupertinoSearchTextField(
          controller: searchBarController,
          onSubmitted: searchBarFunction,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          searchBarFunction(searchBarController.value.text);
        },
        child: Column(
          children: [
            if (data.isEmpty)
              const Flexible(
                child: Center(
                  child: Text(
                    "Please search a book using search bar. \n\nThis application is supported by Google Books API.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            if (data.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                    child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: showingBooksOnApp,
                )),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List> getData(String value) async {
  String url=''; //key part

  url += "&q=$value";

  List<dynamic> booksData=[];
  try{
    var response = await http.get(Uri.parse(url));
    booksData = json.decode(response.body)["items"];
  }
  catch(e){
    booksData = [];
  }
  return booksData;
}

Future<List> getSingleData(List libraryData) async {
  List<Map> returnList=[];
  for(int i=0; i<libraryData.length; i++){
    var response = await http.get(Uri.parse(libraryData[i]));
    Map<String, dynamic> bookData = json.decode(response.body);
    
    if(bookData["volumeInfo"]["categories"]!=null) {
      for(int i=0; i<bookData["volumeInfo"]["categories"].length; i++){
        bookData["volumeInfo"]["categories"][i] = bookData["volumeInfo"]["categories"][i].split(" / ")[0];
      }
      bookData["volumeInfo"]["categories"] = bookData["volumeInfo"]["categories"].toSet().toList();
      
      returnList.add(bookData);
    }

  }
  
  return returnList;
}

Map getCategories(List data){
  Map categories={};
  for(int a=0; a<data.length; a++){
    for(int b=0; b<data[a]["volumeInfo"]["categories"].length; b++){
      categories[data[a]["volumeInfo"]["categories"][b]] = false;
    }
  }
  return categories;
}

Future<String> fetchData() async {
  return 'Data fetched!';
}

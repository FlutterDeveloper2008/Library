import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main (){
  runApp(MaterialApp(
    home: API(),
  ));

}



class API extends StatefulWidget {
  const API({super.key});

  @override
  State<API> createState() => _APIState();
}

class _APIState extends State<API> {
 
 List <Map<String,dynamic>>  data= [];

Future <void> fetchData()async{
 
 final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=Malaysia'));
 if (response.statusCode == 200){
final List <dynamic> jsonData =  json.decode(response.body);

for(var item in jsonData){
 data.add(Map<String,dynamic>.from(item));

}
setState(() {
  
});
 }
 else {
  throw Exception("API xato");
}
}


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("API"),backgroundColor: Colors.blue,),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index){
          return Card(
            color: Colors.grey[100],
            child:Column(
              children: [
                
                Text("Universitet nomi  : ${data[index]['name']}"),
                Text("Mamlakat nomi  : ${data[index]['country']}")],
            ),
          );
        }),
    );
  }
}
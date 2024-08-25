import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Add1 extends StatefulWidget {
  const Add1({Key? key}) : super(key: key);

  @override
  State<Add1> createState() => _Add1State();
}

class _Add1State extends State<Add1> {
  Future<void> postData(String nomi, int narxi) async {
    final String post = "your api";

    try {
      final response = await http.post(
        Uri.parse(post),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': '1234',
          'productname': nomi,
          'productprice': narxi.toString(), 
        },
      );

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Ma'lumot bazaga saqlandi"),
          backgroundColor: Colors.blue,
        ));
      });
      print(response.body);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ma'lumot saqlashda xatolik yuz berdi"),
          backgroundColor: Colors.blue,
        ),
      );
      print(e.toString());
    }
  }

  String name = "";
  int price = 0;
  TextEditingController nomi = TextEditingController();
  TextEditingController narxi = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add API"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nomi,
                decoration: InputDecoration(
                  labelText: "Nomi",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: narxi,
                decoration: InputDecoration(
                  labelText: "Narxi",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  name = nomi.text;
                  price = int.parse(narxi.text); 
                });

                Future.delayed(Duration(seconds: 1), () {
                  postData(name, price); 
                });
              },
              child: Text("Bazaga qo`shish"),
            ),
          ],
        ),
      ),
    );
  }
}
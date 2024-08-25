import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/data.dart';

class MyRentalsadd extends StatefulWidget {
  final Book rentbook;
  final User currentUser;

  const MyRentalsadd(
      {Key? key, required this.rentbook, required this.currentUser})
      : super(key: key);

  @override
  _MyRentalsaddState createState() => _MyRentalsaddState();
}

class _MyRentalsaddState extends State<MyRentalsadd> {
  late DateTime borrowedDate;
  late DateTime returnDate;

  @override
  void initState() {
    super.initState();
    borrowedDate = DateTime.now();
    returnDate = borrowedDate.add(Duration(days: 14)); // Default 2 weeks rental
  }

  Future<void> rentBook() async {
    final String postUrl = "https://dash.vips.uz/api-in/31/2432/35127";

    try {
      final response = await http.post(
        Uri.parse(postUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': '1234',
          'userid': widget.currentUser.id.toString(),
          'bookid': widget.rentbook.id.toString(),
          'borroweddate': borrowedDate.toIso8601String(),
          'returndate': returnDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Book rented successfully"),
          backgroundColor: Colors.blue,
        ));
        Navigator.pop(context);
      } else {
        throw Exception('Failed to rent book');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to rent book"),
          backgroundColor: Colors.red,
        ),
      );
      print(e.toString());
    }
  }

  Future<void> _selectBorrowedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: borrowedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != borrowedDate) {
      setState(() {
        borrowedDate = picked;
        if (returnDate.isBefore(borrowedDate.add(Duration(days: 1)))) {
          returnDate = borrowedDate.add(Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectReturnDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: returnDate,
      firstDate: borrowedDate.add(Duration(days: 1)),
      lastDate: borrowedDate.add(Duration(days: 365)),
    );
    if (picked != null && picked != returnDate) {
      setState(() {
        returnDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rent Book')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Book: ${widget.rentbook.name}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                  'Borrowed Date: ${borrowedDate.toString().substring(0, 10)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectBorrowedDate(context),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                  'Return Date: ${returnDate.toString().substring(0, 10)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectReturnDate(context),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: rentBook,
              child: Text('Confirm Rental'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

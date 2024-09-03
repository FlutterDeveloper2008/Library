import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/data.dart';
import 'package:intl/intl.dart';

class MyRentalsadd extends StatefulWidget {
  final Book rentbook;
  final User currentUser;

  const MyRentalsadd({Key? key, required this.rentbook, required this.currentUser})
      : super(key: key);

  @override
  _MyRentalsaddState createState() => _MyRentalsaddState();
}

class _MyRentalsaddState extends State<MyRentalsadd> {
  
  late DateTime borrowedDate;
  late DateTime returnDate;
  Map<String, dynamic>? bookDetails;
  bool hasAvailableCopies = true;

  @override
  void initState() {
    super.initState();
    borrowedDate = DateTime.now();
    returnDate = borrowedDate.add(Duration(days: 14));
    fetchBookDetails();
  }

  Future<void> fetchBookDetails() async {
    final String apiUrl =
        "https://dash.vips.uz/r-api/31/2432/126?:bookid=${widget.rentbook.id}";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          bookDetails = json.decode(response.body)[0];
          hasAvailableCopies = int.parse(bookDetails!['qoldiq']) > 0;

          if (!hasAvailableCopies) {
            borrowedDate = DateTime.parse(bookDetails!['qaytadigankun'])
                .add(Duration(days: 1));
            returnDate = borrowedDate.add(Duration(days: 14));
          }
        });
      } else {
        throw Exception('Failed to load book details');
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load book details"), backgroundColor: Colors.red),
      );
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Book rented successfully"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to rent book');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to rent book"), backgroundColor: Colors.red),
      );
      print(e.toString());
    }
  }

  Future<void> _selectBorrowedDate(BuildContext context) async {
    DateTime firstAvailableDate = hasAvailableCopies
        ? DateTime.now()
        : DateTime.parse(bookDetails!['qaytadigankun']).add(Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: borrowedDate.isAfter(firstAvailableDate) ? borrowedDate : firstAvailableDate,
      firstDate: firstAvailableDate,
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null && picked != borrowedDate) {
      setState(() {
        borrowedDate = picked;
        returnDate = borrowedDate.add(Duration(days: 14));
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
      appBar: AppBar(
        title: Text('Rent Book'),
        backgroundColor: Colors.orange,
      ),
      body: bookDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  widget.rentbook.image!,
                                  height: 200,
                                  width: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.book, size: 150),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              widget.rentbook.name!,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Author: ${widget.rentbook.author}',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Available Copies: ${bookDetails!['qoldiq']}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            if (!hasAvailableCopies)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Available getting date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(bookDetails!['qaytadigankun']))}',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rental Details',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            ListTile(
                              title: Text('Getting Date'),
                              subtitle: Text(DateFormat('MMM dd, yyyy').format(borrowedDate)),
                              trailing: Icon(Icons.calendar_today,color: !hasAvailableCopies?Colors.transparent:Colors.black,),
                              onTap: hasAvailableCopies ? () => _selectBorrowedDate(context) : null,
                            ),
                            ListTile(
                              title: Text('Return Date'),
                              subtitle: Text(DateFormat('MMM dd, yyyy').format(returnDate)),
                              trailing: Icon(Icons.calendar_today),
                              onTap: () => _selectReturnDate(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: rentBook,
                        child: Text('Confirm Rental', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
backgroundColor: Colors.amber,                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
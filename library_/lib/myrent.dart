import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/data.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class MyRentalsPage extends StatefulWidget {
  final User? currentUser;

  const MyRentalsPage({Key? key, this.currentUser}) : super(key: key);

  @override
  _MyRentalsPageState createState() => _MyRentalsPageState();
}

class _MyRentalsPageState extends State<MyRentalsPage> with TickerProviderStateMixin {
  List<Loan> loans = [];
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchLoans();
  }

  void fetchLoans() async {
    if (widget.currentUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://dash.vips.uz/r-api/31/2432/123?userid=${widget.currentUser!.id}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> loansData = json.decode(response.body);
        List<Loan> fetchedLoans =
            loansData.map((data) => Loan.fromJson(data)).toList();

        // Filter loans based on user ID
        List<Loan> filteredLoans = fetchedLoans
            .where((loan) => loan.userid == widget.currentUser!.id)
            .toList();

        setState(() {
          loans = filteredLoans;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load loans');
      }
    } catch (e) {
      print('Error fetching loans: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Loan> getActiveLoans() {
    DateTime now = DateTime.now();
    return loans.where((loan) {
      DateTime borrowedDate = DateFormat('yyyy-MM-dd').parse(loan.borroweddate);
      DateTime returnDate = DateFormat('yyyy-MM-dd').parse(loan.returndate);
      return borrowedDate.isBefore(now) && returnDate.isAfter(now);
    }).toList();
  }

  List<Loan> getComingLoans() {
    DateTime now = DateTime.now();
    return loans.where((loan) {
      DateTime borrowedDate = DateFormat('yyyy-MM-dd').parse(loan.borroweddate);
      return borrowedDate.isAfter(now);
    }).toList();
  }

  List<Loan> getExpiredLoans() {
    DateTime now = DateTime.now();
    return loans.where((loan) {
      DateTime returnDate = DateFormat('yyyy-MM-dd').parse(loan.returndate);
      return returnDate.isBefore(now);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Rentals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active'),
            Tab(text: 'Coming'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildLoansList(getActiveLoans()),
                buildLoansList(getComingLoans()),
                buildLoansList(getExpiredLoans()),
              ],
            ),
    );
  }

  Widget buildLoansList(List<Loan> loansList) {
    if (loansList.isEmpty) {
      return Center(child: Text('No rentals found.'));
    }
    return ListView.builder(
      itemCount: loansList.length,
      itemBuilder: (context, index) {
        final loan = loansList[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: loan.image.isNotEmpty
                ? Image.network(
                    loan.image,
                    width: 50,
                    height: 75,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.book),
            title: Text(loan.name),
            subtitle: Text(
                'Borrowed: ${loan.borroweddate}\nReturn: ${loan.returndate}'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}

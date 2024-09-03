import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/data.dart';
import 'package:intl/intl.dart';

class LoanDetailPage extends StatelessWidget {
  final Loan loan;
  const LoanDetailPage({Key? key, required this.loan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime borrowedDate = DateFormat('yyyy-MM-dd').parse(loan.borroweddate);
    DateTime returnDate = DateFormat('yyyy-MM-dd').parse(loan.returndate);
    DateTime today = DateTime.now();

    int loanDuration = returnDate.difference(borrowedDate).inDays;
    int daysLeft = returnDate.difference(today).inDays;
    bool isActive = today.isAfter(borrowedDate) && today.isBefore(returnDate);
    bool isComing = today.isBefore(borrowedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(loan.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book image and details
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      loan.image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                loan.image,
                                width: 80,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.book, size: 80, color: Colors.blue),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.name,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('Borrowed: ${loan.borroweddate}'),
                            Text('Return: ${loan.returndate}'),
                            SizedBox(height: 8),
                            Text('Loan duration: $loanDuration days', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Loan status
              Card(
                color: isActive ? Colors.green[100] : (isComing ? Colors.orange[100] : Colors.red[100]),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loan Status',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        isActive
                            ? 'Active: $daysLeft days left to return'
                            : (isComing
                                ? '${borrowedDate.difference(today).inDays} days left to get book'
                                : 'Completed'),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Calendar to mark borrowed and return dates
              Card(
                elevation: 4,
                child: TableCalendar(
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: borrowedDate,
                  calendarFormat: CalendarFormat.month,
                  rangeStartDay: borrowedDate,
                  rangeEndDay: returnDate,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  rangeSelectionMode: RangeSelectionMode.toggledOn,
                  calendarStyle: CalendarStyle(
                    rangeHighlightColor: Colors.blue.shade100,
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    rangeStartDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  selectedDayPredicate: (day) {
                    return isSameDay(day, borrowedDate) ||
                        (day.isAfter(borrowedDate) && day.isBefore(returnDate)) ||
                        isSameDay(day, returnDate);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
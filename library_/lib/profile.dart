import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/data.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final User? user;
  final VoidCallback onLogout;

  const ProfilePage({Key? key, this.user, required this.onLogout})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Loan> userLoans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      fetchUserLoans();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserLoans() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://dash.vips.uz/api/31/2432/35127?userid=${widget.user!.id}'),
        headers: {'Api-Key': '1234'},
      );

      if (response.statusCode == 200) {
        List<dynamic> loansData = json.decode(response.body);
        setState(() {
          userLoans = loansData.map((data) => Loan.fromJson(data)).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.white,
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: ListTile(
                  title: Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    widget.onLogout();
                    userLoans.clear(); // Call the onLogout callback
                  },
                  leading: Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                ),
              )
            ],
          )
        ],
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
        title: Text('Profilim', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: widget.user == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 370,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(50)),
                      color: Colors.amber,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 80),
                        CircleAvatar(
                          backgroundImage: NetworkImage(widget.user!.image),
                          radius: 50,
                        ),
                        SizedBox(height: 20),
                        Text(
                          '${widget.user!.firstname} ${widget.user!.lastname}',
                          style: TextStyle(color: Colors.white, fontSize: 26),
                        ),
                        Text(
                          widget.user!.email,
                          style: TextStyle(color: Colors.grey.shade200),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(15, 25, 15, 10),
                    margin: EdgeInsets.fromLTRB(20, 330, 20, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(50)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
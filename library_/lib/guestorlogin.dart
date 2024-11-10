import 'package:flutter/material.dart';
import 'package:library_/main.dart';

void main() {
  runApp(Guestorlogin());
}

class Guestorlogin extends StatefulWidget {
  const Guestorlogin({super.key});

  @override
  State<Guestorlogin> createState() => _GuestorloginState();
}

class _GuestorloginState extends State<Guestorlogin> {
  void handleLogout() {
  // Implement your logout logic here
  print("User  logged out");
  // You might want to navigate to a login screen or perform other actions
}
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                child: Image.asset('image/pngimg.com - book_PNG2113.png'),
              ),
              GestureDetector(
                child: Container(
                  child: Center(
                      child: Text(
                    'Go To Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  )),
                  height: 70,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.amber, Colors.amber.shade900],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter),
                      borderRadius: BorderRadius.circular(20)),
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
              ),GestureDetector(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>Home(onLogout:handleLogout )));},
                child: Container(
                  child: Center(
                      child: Text(
                    'Continu as guest',
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  )),
                  height: 70,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber,),
                      borderRadius: BorderRadius.circular(20)),
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

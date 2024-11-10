import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:library_/guestorlogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'models/data.dart';
import 'dart:convert';
import 'search.dart';
import 'home.dart';
import 'myrent.dart';
import 'profile.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? currentUserJson = prefs.getString('currentUser');
  User? currentUser;

  if (currentUserJson != null) {
    currentUser = User.fromJson(json.decode(currentUserJson));
  }

  runApp(MyApp(isLoggedIn: isLoggedIn, currentUser: currentUser));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final User? currentUser;

  const MyApp({Key? key, required this.isLoggedIn, this.currentUser})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isLoggedIn;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    _currentUser = widget.currentUser;
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: _isLoggedIn
          ? Home(onLogout: _handleLogout, currentUser: _currentUser)
          : Guestorlogin(),
    );
  }
}

class Home extends StatefulWidget {
  final VoidCallback onLogout;
  final User? currentUser;

  const Home({Key? key, required this.onLogout, this.currentUser})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Book> books = [];
  bool isLoading = true;
  User? currentUser;
  String selectedLanguageFilter = 'Barchasi';

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final booksResponse =
          await http.get(Uri.parse('https://dash.vips.uz/api/31/2432/35126'));
      final ratingsResponse =
          await http.get(Uri.parse('https://dash.vips.uz/r-api/31/2432/125'));
      final bookmarksResponse = await http.get(Uri.parse(
          'https://dash.vips.uz/api/31/2432/40534?userid=${currentUser!.id}')); // Bookmark API link

      if (booksResponse.statusCode == 200 &&
          ratingsResponse.statusCode == 200 &&
          bookmarksResponse.statusCode == 200) {
        List<Book> allBooks = (json.decode(booksResponse.body) as List)
            .map((data) => Book.fromJson(data))
            .toList();

        List<dynamic> ratings = json.decode(ratingsResponse.body);
        List<dynamic> bookmarks = json.decode(bookmarksResponse.body);

        // Merge ratings and bookmark status with books
        allBooks = allBooks.map((book) {
          final ratingData = ratings.firstWhere(
            (rating) => rating['bookid'] == book.id,
            orElse: () => null,
          );

          final isBookmarked =
              bookmarks.any((bookmark) => bookmark['bookid'] == book.id);

          return Book(
            id: book.id,
            name: book.name,
            author: book.author,
            genre: book.genre,
            pages: book.pages,
            shortinfo: book.shortinfo,
            image: book.image,
            language: book.language,
            avgRating: ratingData != null
                ? double.tryParse(ratingData['avg(starmark)'])
                : null,
            isBookmarked: isBookmarked,
          );
        }).toList();

        setState(() {
          books = applyLanguageFilter(allBooks, selectedLanguageFilter);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
    }
  }

  List<Book> applyLanguageFilter(List<Book> allBooks, String language) {
    if (language == 'Barchasi') {
      return allBooks;
    }
    return allBooks.where((book) => book.language == language).toList();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFilterSelected(String language) {
    setState(() {
      selectedLanguageFilter = language;
      isLoading = true;
      fetchBooks();
    });
  }

  Future<void> handleLogout() async {
    // Clear SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears all stored preferences

    // Reset current user
    setState(() {
      currentUser = null;
      books = []; // Clear the books list
      isLoading = true; // Set isLoading to true to fetch new data
    });

    // Call the onLogout callback
    widget.onLogout();

    // Navigate to login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      BookList(
        books: books,
        isLoading: isLoading,
        onFilterSelected: _onFilterSelected,
        selectedLanguageFilter: selectedLanguageFilter,
        currentUser: currentUser,
      ),
      SearchPage(books: books, currentUser: currentUser),
      MyRentalsPage(currentUser: currentUser),
      ProfilePage(user: currentUser, onLogout: handleLogout),
    ];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchBooks,
        color: Colors.amber,
        strokeWidth: 5,
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
            gap: 8,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            tabBackgroundColor: Colors.grey.withOpacity(0.3),
            activeColor: Colors.black,
            color: Colors.grey,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
              ),
              GButton(
                icon: Icons.menu_book,
                text: 'Rentals',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

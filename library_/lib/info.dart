import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'models/data.dart';
import 'addrent.dart';

List<Review> reviews = [];
int _leng = 400;

class InfoPage extends StatefulWidget {
  final Book? booky;
  final User? currentUser;

  const InfoPage({Key? key, this.booky, this.currentUser}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = false;
  String? errorMessage;
  late TextEditingController _commentController;
  int _currentRating = 0;
  bool _isRatingSelected = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _commentController = TextEditingController();
    if (widget.booky != null) {
      fetchReviews();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> fetchReviews() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response =
          await http.get(Uri.parse('https://dash.vips.uz/api/31/2432/44367'));
      if (response.statusCode == 200) {
        final List<dynamic> allReviewsJson = json.decode(response.body);
        final List<Review> allReviews =
            allReviewsJson.map((json) => Review.fromJson(json)).toList();

        setState(() {
          reviews = allReviews
              .where((review) => review.bookId == widget.booky?.id)
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load reviews: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> postData(int starmark, String comment) async {
    if (widget.booky == null || widget.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book or user information is missing')),
      );
      return;
    }

    final String post =
        "https://dash.vips.uz/api-in/31/2432/44367"; // Replace with actual API URL

    try {
      final response = await http.post(
        Uri.parse(post),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': '1234',
          'bookid': widget.booky!.id.toString(),
          'userid': widget.currentUser!.id.toString(),
          'starmark': starmark.toString(),
          'comment': comment,
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Comment added"),
          backgroundColor: Colors.yellow,
        ));
        fetchReviews(); // Refresh reviews after posting
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Ma'lumot saqlashda xatolik yuz berdi: ${e.toString()}"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _showRatingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Rating'),
          content: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _currentRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentRating = index + 1;
                      _isRatingSelected = true;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }),
            ),
          ),
        );
      },
    );
  }

  void _submitReview() {
    if (_currentRating > 0 && _commentController.text.isNotEmpty) {
      postData(_currentRating, _commentController.text);
      setState(() {
        _currentRating = 0;
        _isRatingSelected = false;
      });
      _commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating and enter a comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFloatingActionButton(),
        body: _buildBody(),
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return _tabController.index == 0
        ? _buildRentButton()
        : widget.currentUser!.username!='guest'? _buildCommentField():Container(height: 50,width: double.infinity,color: Colors.grey.shade300,child: Center(child: Text('Loign to rate'),),);
  }

  Widget _buildCommentField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: _isRatingSelected
                    ? 'Type your comment...'
                    : 'Tap to rate...',
                border: InputBorder.none,
                prefixIcon: _isRatingSelected
                    ? IconButton(
                        onPressed: _showRatingDialog,
                        icon: Icon(Icons.star, color: Colors.amber),
                      )
                    : null,
              ),
              readOnly: !_isRatingSelected,
              onTap: _isRatingSelected ? null : _showRatingDialog,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _submitReview,
          ),
        ],
      ),
    );
  }

  Future<void> unbook() async {
    final String postUrl =
        "https://dash.vips.uz/api-del/31/2432/40534?bookid=${widget.booky?.id ?? 1}";

    try {
      final response = await http.post(
        Uri.parse(postUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': '1234',
        },
      );

      if (response.statusCode == 200) {
setState(() {
          widget.booky!.isBookmarked=false;

});      } else {
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

  Widget _buildRentButton() {
    return GestureDetector(
      onTap: () {
        if (widget.currentUser != null && widget.booky != null&&widget.currentUser!.username!= 'guest' ) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyRentalsadd(
                rentbook: widget.booky!,
                currentUser: widget.currentUser!,
              ),
            ),
          );
        }  else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to rent a book')),
          );
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 53,
        width: double.infinity,
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange, Color.fromARGB(255, 252, 130, 0)],
          ),
        ),
        child: Text(
          'Rent',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildBackgroundGradient(),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 500),
              _buildContentContainer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 255, 143, 7),
            const Color.fromARGB(255, 255, 213, 0),
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 60),
          _buildBookImage(),
          SizedBox(height: 15),
          _buildStarRating(widget.booky?.avgRating ?? 3),
          SizedBox(height: 15),
          _buildBookInfo(),
          SizedBox(height: 15),
          _buildBookDetails(),
        ],
      ),
    );
  }

  Widget _buildBookImage() {
    return Hero(
      tag: widget.booky?.image ?? 'image',
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                widget.booky?.image ?? 'https://example.com/default-image.png'),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.yellow, size: 24);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.yellow, size: 24);
        } else {
          return Icon(Icons.star_border, color: Colors.yellow, size: 24);
        }
      }),
    );
  }

  Future<void> addbook() async {
    final String postUrl = "https://dash.vips.uz/api-in/31/2432/40534";

    try {
      final response = await http.post(
        Uri.parse(postUrl),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'apipassword': '1234',
          'userid': widget.currentUser?.id ?? 1.toString(),
          'bookid': widget.booky?.id ?? 1.toString(),
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          widget.booky?.isBookmarked = true;
        });
      } else {
        throw Exception('Failed to rent book');
      }
    } catch (e) {
      setState(() {
        widget.booky?.isBookmarked = false;
      });
      print(e.toString());
    }
  }

  Widget _buildBookInfo() {
    return Column(
      children: [
        Text(textAlign: TextAlign.center,
          widget.booky?.name ?? 'No Name',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.fade,
        ),
        Text(
          widget.booky?.author ?? 'Unknown Author',
          style: TextStyle(color: Colors.grey.shade300),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBookDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDetailColumn('Sahifa', widget.booky?.pages ?? 'N/A'),
        SizedBox(width: 60),
        _buildDetailColumn('Til', widget.booky?.language ?? 'Unknown'),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade300)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildContentContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          TabBar(
            dividerColor: Colors.transparent,
            controller: _tabController,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: 'Umumiy ma\'lumot'),
              Tab(text: 'Fikr va mulohazalar'),
            ],
          ),
          SizedBox(height: 10),
          Container(
            height: _tabController.index == 0 ? 400 : reviews.length * 140 + 90,
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Text(
                      widget.booky?.shortinfo ?? 'No short information',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: _buildReviewsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }
    if (reviews.isEmpty) {
      return Center(child: Text('No reviews yet'));
    }
    return ListView.builder(
      itemCount: reviews.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _buildReviewItem(review);
      },
    );
  }

  Widget _buildReviewItem(Review review) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('User ID: ${review.userId}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(DateFormat('yyyy-MM-dd').format(review.date),
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < review.starRating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(review.comment),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      actions: [
        IconButton(
            onPressed: () {
              if(widget.currentUser!.username!='guest'){
              widget.booky?.isBookmarked ?? false ? unbook() : addbook();}
              else{ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login to bookmark books')));}
            },
            icon: widget.booky?.isBookmarked ?? false
                ? Icon(Icons.bookmark)
                : Icon(Icons.bookmark_outline))
      ],
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}

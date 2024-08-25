class Book {
  final String? id;
  final String? name;
  final String? author;
  final String? image;
  final String? pages;
  final String? shortinfo;
  final String? language;
  final String? genre;
  final double? avgRating; // Add this field for star ratings
  bool? isBookmarked; // Add this field for bookmark status

  Book({
    this.id,
    this.name,
    this.author,
    this.image,
    this.pages,
    this.shortinfo,
    this.language,
    this.genre,
    this.avgRating,
    this.isBookmarked = false, // Initialize with false
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      name: json['name'],
      author: json['author'],
      image: json['image'],
      pages: json['pages'],
      shortinfo: json['shortinfo'],
      language: json['language'],
      genre: json['genre'],
      avgRating: json['avg(starmark)'] != null
          ? double.tryParse(json['avg(starmark)'])
          : null, // Parse the rating
      isBookmarked: json['isBookmarked'] ?? false, // Initialize with false
    );
  }
}
class User {
  final String id;
  final String firstname;
  final String lastname;
  final String birthdate;
  final String regdate;
  final String image;
  final String username;
  final String password;
  final String email;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.birthdate,
    required this.regdate,
    required this.image,
    required this.username,
    required this.password,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      birthdate: json['birthdate'],
      regdate: json['regdate'],
      image: json['image'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'birthdate': birthdate,
      'regdate': regdate,
      'image': image,
      'username': username,
      'password': password,
      'email': email,
    };
  }
}

class Loan {
  final String name;
  final String image;
  final String borroweddate;
  final String returndate;
  final String userid;

  Loan({
    required this.name,
    required this.image,
    required this.borroweddate,
    required this.returndate,
    required this.userid,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      name: json['name'],
      image: json['image'],
      borroweddate: json['borroweddate'],
      returndate: json['returndate'],
      userid: json['userid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'borroweddate': borroweddate,
      'returndate': returndate,
      'userid': userid,
    };
  }
}


class Review {
  final String id;
  final String bookId;
  final String userId;
  final int starRating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.starRating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      bookId: json['bookid'],
      userId: json['userid'],
      starRating: int.parse(json['starmark']),
      comment: json['comment'],
      date: DateTime.parse(json['date']),
    );
  }
}
class Bookmarked {
  final int id;
  final int bookId;
  final int userId;

  Bookmarked({required this.id, required this.bookId, required this.userId});

  factory Bookmarked.fromJson(Map<String, dynamic> json) {
    return Bookmarked(
      id: json['id'],
      bookId: json['bookid'],
      userId: json['userid'],
    );
  }
}
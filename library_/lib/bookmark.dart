import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'models/data.dart';
import 'info.dart';

class BookmarkedBooksPage extends StatelessWidget {
  final List<Book> books;
  final bool isLoading;
  final User? currentUser;

  const BookmarkedBooksPage({
    Key? key,
    required this.books,
    required this.isLoading,
    this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool sh=false;
    // Filter the books to only show bookmarked ones
    final bookmarkedBooks = books
        .where(
          (book) => book.isBookmarked == true,
        )
        .toList();
        bookmarkedBooks!=null?sh=false:sh=true;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.home_outlined,
          color: Colors.white,
        ),
      ),
      extendBodyBehindAppBar: true,
      body:CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            centerTitle: false,
            title: Text('Bookmarked Books'),
            leading: BackButton(),
            backgroundColor: Colors.transparent,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: isLoading
                ? SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SliverAnimatedGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index, animation) {
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child:
                                _buildBookItem(context, bookmarkedBooks[index]),
                          ),
                        ),
                      );
                    },
                    initialItemCount: bookmarkedBooks.length,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfoPage(
              booky: book,
              currentUser: currentUser,
            ),
          ),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Hero(
                  tag: book.image!,
                  child: Image.network(
                    book.image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.name!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    book.author!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      if (book.avgRating != null) ...[
                        Text(
                          book.avgRating!.toStringAsFixed(1),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        SizedBox(width: 4),
                        _buildStarRating(book.avgRating!),
                      ] else
                        Text(
                          'Not rated',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: 14);
        } else if (index < rating && index + 1 > rating) {
          return Icon(Icons.star_half, color: Colors.amber, size: 14);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 14);
        }
      }),
    );
  }
}

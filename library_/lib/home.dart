import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:library_/bookmark.dart';
import 'models/data.dart';
import 'info.dart';

class BookList extends StatelessWidget {
  final List<Book> books;
  final bool isLoading;
  final ValueChanged<String> onFilterSelected;
  final String selectedLanguageFilter;
  final User? currentUser;

  const BookList({
    Key? key,
    required this.books,
    required this.isLoading,
    required this.onFilterSelected,
    required this.selectedLanguageFilter,
    this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BookmarkedBooksPage(books: books, isLoading: isLoading)));
        },
        child: Icon(
          Icons.bookmark_outline,
          color: Colors.white,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            centerTitle: false,
            title: Text('Kitoblar Olami'),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.bookmark_outline),
              ),
            ],
            leading: DrawerButton(),
            backgroundColor: Colors.transparent,
            flexibleSpace: SizedBox(
              height: double.infinity,
              width: double.infinity,
            ),
            bottom: AppBar(
              shadowColor: Colors.white,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              title: Container(
                width: double.infinity,
                height: 100,
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        FilterButton(
                          label: 'Barchasi',
                          isSelected: selectedLanguageFilter == 'Barchasi',
                          onTap: () => onFilterSelected('Barchasi'),
                        ),
                        FilterButton(
                          label: 'uzbek',
                          isSelected: selectedLanguageFilter == 'uzbek',
                          onTap: () => onFilterSelected('uzbek'),
                        ),
                        FilterButton(
                          label: 'russian',
                          isSelected: selectedLanguageFilter == 'russian',
                          onTap: () => onFilterSelected('russian'),
                        ),
                        FilterButton(
                          label: 'english',
                          isSelected: selectedLanguageFilter == 'english',
                          onTap: () => onFilterSelected('english'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: isLoading
                ? SliverFillRemaining(
                    child: Center(
                        child: SpinKitWave(
                      size: 30,
                      color: Colors.amber,
                    )),
                  )
                : SliverAnimatedGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index, animation) {
                      // Reverse the list
                      final reversedBooks = books.reversed.toList();
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child:
                                _buildBookItem(context, reversedBooks[index]),
                          ),
                        ),
                      );
                    },
                    initialItemCount: books.length,
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
        // Each full star is represented by an index increment of 1
        if (index < rating.floor()) {
          // Full star
          return Icon(Icons.star, color: Colors.amber, size: 14);
        } else if (index < rating && index + 1 > rating) {
          // Half star (when there's a decimal part)
          return Icon(Icons.star_half, color: Colors.amber, size: 14);
        } else {
          // Empty star
          return Icon(Icons.star_border, color: Colors.amber, size: 14);
        }
      }),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber),
          color: isSelected ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

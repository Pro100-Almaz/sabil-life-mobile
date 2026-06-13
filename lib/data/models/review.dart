class Review {
  const Review({
    required this.author,
    required this.rating,
    required this.text,
    required this.monthsAgo,
  });

  final String author;
  final double rating;
  final String text;
  final int monthsAgo;
}

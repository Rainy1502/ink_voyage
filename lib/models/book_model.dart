class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final int totalPages;
  final int currentPage;
  final String status; // 'reading', 'completed', 'not-started'
  final String? genre; // optional genre/category
  final int? rating; // rating 1-5 stars
  final String? notes; // user notes/review
  final DateTime createdAt;
  final DateTime? updatedAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.totalPages,
    this.currentPage = 0,
    this.status = 'not-started',
    this.genre,
    this.rating,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate reading progress percentage
  double get progressPercentage {
    if (totalPages == 0) return 0;
    return (currentPage / totalPages * 100).clamp(0, 100);
  }

  // Check if book is completed
  bool get isCompleted => status == 'completed' || currentPage >= totalPages;

  // Check if book is being read
  bool get isReading =>
      status == 'reading' && currentPage > 0 && currentPage < totalPages;

  // Copy with method for updating
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? imageUrl,
    int? totalPages,
    int? currentPage,
    String? status,
    String? genre,
    int? rating,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to map for storage (Firestore)
  Map<String, dynamic> toMap() {
    return {
      // Don't include 'id' - it's the document ID in Firestore
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'status': status,
      'genre': genre,
      'rating': rating,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from map
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      imageUrl: map['imageUrl'] as String,
      totalPages: map['totalPages'] as int,
      currentPage: map['currentPage'] as int? ?? 0,
      status: map['status'] as String? ?? 'not-started',
      genre: map['genre'] as String?,
      rating: map['rating'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

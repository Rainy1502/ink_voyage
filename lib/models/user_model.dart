class User {
  final String id;
  final String name;
  final String email;
  final DateTime joinedDate;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    DateTime? joinedDate,
    this.profileImageUrl,
  }) : joinedDate = joinedDate ?? DateTime.now();

  // Get initial for avatar
  String get initial {
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  // Get formatted created date (Indonesian format)
  String get createdAt {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${joinedDate.day} ${months[joinedDate.month - 1]} ${joinedDate.year}';
  }

  // Copy with method for updating
  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? joinedDate,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      joinedDate: joinedDate ?? this.joinedDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'joinedDate': joinedDate.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create from map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      joinedDate: DateTime.parse(map['joinedDate'] as String),
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

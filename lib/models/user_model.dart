class User {
  final String id;
  final String name;
  final String email;
  final DateTime joinedDate;
  final String? profileImageUrl;
  final String role;
  final Map<String, dynamic>? authorProfile;
  final String?
  authorApplicationStatus; // 'pending', 'approved', 'rejected', null
  final DateTime? authorApplicationDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    DateTime? joinedDate,
    this.profileImageUrl,
    this.role = 'reader',
    this.authorProfile,
    this.authorApplicationStatus,
    this.authorApplicationDate,
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
    String? role,
    Map<String, dynamic>? authorProfile,
    String? authorApplicationStatus,
    DateTime? authorApplicationDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      joinedDate: joinedDate ?? this.joinedDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      authorProfile: authorProfile ?? this.authorProfile,
      authorApplicationStatus:
          authorApplicationStatus ?? this.authorApplicationStatus,
      authorApplicationDate:
          authorApplicationDate ?? this.authorApplicationDate,
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
      'role': role,
      'authorProfile': authorProfile,
      'authorApplicationStatus': authorApplicationStatus,
      'authorApplicationDate': authorApplicationDate?.toIso8601String(),
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
      role: map['role'] as String? ?? 'reader',
      authorProfile: map['authorProfile'] as Map<String, dynamic>?,
      authorApplicationStatus: map['authorApplicationStatus'] as String?,
      authorApplicationDate: map['authorApplicationDate'] != null
          ? DateTime.parse(map['authorApplicationDate'] as String)
          : null,
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

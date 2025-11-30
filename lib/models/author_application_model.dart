class AuthorApplication {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy; // moderator user ID
  final String? reviewerName; // moderator name
  final String? notes; // rejection reason or approval notes
  final Map<String, dynamic>? applicationData; // bio, reason for applying, etc.

  AuthorApplication({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.appliedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewerName,
    this.notes,
    this.applicationData,
  });

  // Get formatted applied date (Indonesian format)
  String get appliedAtFormatted {
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
    return '${appliedAt.day} ${months[appliedAt.month - 1]} ${appliedAt.year}';
  }

  // Get formatted reviewed date (Indonesian format)
  String? get reviewedAtFormatted {
    if (reviewedAt == null) return null;
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
    return '${reviewedAt!.day} ${months[reviewedAt!.month - 1]} ${reviewedAt!.year}';
  }

  // Status display
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Application Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  // Copy with method
  AuthorApplication copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewerName,
    String? notes,
    Map<String, dynamic>? applicationData,
  }) {
    return AuthorApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewerName: reviewerName ?? this.reviewerName,
      notes: notes ?? this.notes,
      applicationData: applicationData ?? this.applicationData,
    );
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'reviewerName': reviewerName,
      'notes': notes,
      'applicationData': applicationData,
    };
  }

  // Create from map
  factory AuthorApplication.fromMap(Map<String, dynamic> map) {
    return AuthorApplication(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userEmail: map['userEmail'] as String,
      status: map['status'] as String,
      appliedAt: DateTime.parse(map['appliedAt'] as String),
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.parse(map['reviewedAt'] as String)
          : null,
      reviewedBy: map['reviewedBy'] as String?,
      reviewerName: map['reviewerName'] as String?,
      notes: map['notes'] as String?,
      applicationData: map['applicationData'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthorApplication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/author_application_model.dart';

class AuthorApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit author application
  Future<void> submitApplication({
    required String userId,
    required String userName,
    required String userEmail,
    Map<String, dynamic>? applicationData,
  }) async {
    try {
      final applicationId = _firestore
          .collection('author_applications')
          .doc()
          .id;
      final now = DateTime.now();

      final application = AuthorApplication(
        id: applicationId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        status: 'pending',
        appliedAt: now,
        applicationData: applicationData,
      );

      debugPrint('📝 Creating application with status: ${application.status}');

      // Create application document
      await _firestore
          .collection('author_applications')
          .doc(applicationId)
          .set(application.toMap());

      debugPrint('✅ Application created in Firestore');

      // Update user document with application status ONLY (not role!)
      final updateData = {
        'authorApplicationStatus': 'pending',
        'authorApplicationDate': now.toIso8601String(),
      };

      debugPrint('📤 Updating user with: $updateData');

      // Use set with merge to ensure fields are added
      await _firestore
          .collection('users')
          .doc(userId)
          .set(updateData, SetOptions(merge: true));

      debugPrint(
        '✅ User document updated with merge - role should still be reader',
      );

      // Verify update
      final verifyDoc = await _firestore.collection('users').doc(userId).get();
      debugPrint(
        '🔍 Verification - User doc after update: ${verifyDoc.data()}',
      );
    } catch (e) {
      debugPrint('❌ Error in submitApplication: $e');
      throw Exception('Failed to submit application: $e');
    }
  }

  // Get application for a user
  Future<AuthorApplication?> getApplicationByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('author_applications')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      // Sort manually in memory to avoid index requirement
      final docs = querySnapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['appliedAt'] as Timestamp).toDate();
        final bTime = (b.data()['appliedAt'] as Timestamp).toDate();
        return bTime.compareTo(aTime); // descending
      });

      return AuthorApplication.fromMap(docs.first.data());
    } catch (e) {
      throw Exception('Failed to get application: $e');
    }
  }

  // Get all pending applications (for moderator) - as Future
  Future<List<AuthorApplication>> getPendingApplications() async {
    try {
      final snapshot = await _firestore
          .collection('author_applications')
          .where('status', isEqualTo: 'pending')
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AuthorApplication.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get all pending applications as Stream (for moderator)
  Stream<List<Map<String, dynamic>>> getPendingApplicationsStream() {
    return _firestore
        .collection('author_applications')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          // Get all docs
          final docs = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          // Sort manually in memory to avoid composite index requirement
          docs.sort((a, b) {
            final aTime = a['appliedAt'];
            final bTime = b['appliedAt'];

            // Handle both Timestamp and String formats
            DateTime aDate;
            DateTime bDate;

            if (aTime is Timestamp) {
              aDate = aTime.toDate();
            } else if (aTime is String) {
              aDate = DateTime.parse(aTime);
            } else {
              aDate = DateTime.now();
            }

            if (bTime is Timestamp) {
              bDate = bTime.toDate();
            } else if (bTime is String) {
              bDate = DateTime.parse(bTime);
            } else {
              bDate = DateTime.now();
            }

            return bDate.compareTo(aDate); // descending (newest first)
          });

          return docs;
        });
  }

  // Approve application (moderator action)
  Future<void> approveApplication(
    String applicationId,
    String moderatorId, {
    String? notes,
  }) async {
    try {
      final now = DateTime.now();

      // Get application to get userId
      final appDoc = await _firestore
          .collection('author_applications')
          .doc(applicationId)
          .get();

      if (!appDoc.exists) {
        throw Exception('Application not found');
      }

      final userId = appDoc.data()!['userId'];

      // Update application status
      await _firestore
          .collection('author_applications')
          .doc(applicationId)
          .update({
            'status': 'approved',
            'reviewedAt': Timestamp.fromDate(now),
            'reviewedBy': moderatorId,
            'notes': notes ?? 'Approved',
          });

      // Update user role to author
      await _firestore.collection('users').doc(userId).update({
        'role': 'author',
        'authorApplicationStatus': 'approved',
        'authorProfile': {'bio': '', 'appliedAt': now.toIso8601String()},
      });
    } catch (e) {
      throw Exception('Failed to approve application: $e');
    }
  }

  // Reject application (moderator action)
  Future<void> rejectApplication(
    String applicationId,
    String moderatorId,
    String notes,
  ) async {
    try {
      final now = DateTime.now();

      // Get application to get userId
      final appDoc = await _firestore
          .collection('author_applications')
          .doc(applicationId)
          .get();

      if (!appDoc.exists) {
        throw Exception('Application not found');
      }

      final userId = appDoc.data()!['userId'];

      // Update application status
      await _firestore
          .collection('author_applications')
          .doc(applicationId)
          .update({
            'status': 'rejected',
            'reviewedAt': Timestamp.fromDate(now),
            'reviewedBy': moderatorId,
            'notes': notes,
          });

      // Update user status
      await _firestore.collection('users').doc(userId).update({
        'authorApplicationStatus': 'rejected',
      });
    } catch (e) {
      throw Exception('Failed to reject application: $e');
    }
  }

  // Cancel application (user action)
  Future<void> cancelApplication({
    required String applicationId,
    required String userId,
  }) async {
    try {
      // Delete application document
      await _firestore
          .collection('author_applications')
          .doc(applicationId)
          .delete();

      // Update user document to remove application status
      await _firestore.collection('users').doc(userId).update({
        'authorApplicationStatus': FieldValue.delete(),
        'authorApplicationDate': FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to cancel application: $e');
    }
  }

  // Check if user has pending application
  Future<bool> hasPendingApplication(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('author_applications')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get application status for user
  Future<String?> getApplicationStatus(String userId) async {
    try {
      final application = await getApplicationByUserId(userId);
      return application?.status;
    } catch (e) {
      return null;
    }
  }
}

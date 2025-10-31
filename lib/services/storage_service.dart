import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Upload profile image
  /// Returns the download URL if successful, null if failed
  Future<String?> uploadProfileImage(File imageFile) async {
    if (_userId == null) {
      debugPrint('User not authenticated');
      return null;
    }

    try {
      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_$timestamp.jpg';

      // Reference to storage location
      final ref = _storage.ref().child('profile_images/$_userId/$fileName');

      // Upload file
      final uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Profile image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  /// Upload book cover image
  /// Returns the download URL if successful, null if failed
  Future<String?> uploadBookCover(File imageFile) async {
    if (_userId == null) {
      debugPrint('User not authenticated');
      return null;
    }

    try {
      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'book_$timestamp.jpg';

      // Reference to storage location
      final ref = _storage.ref().child('book_covers/$_userId/$fileName');

      // Upload file
      final uploadTask = ref.putFile(imageFile);

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Book cover uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading book cover: $e');
      return null;
    }
  }

  /// Upload book cover with progress callback
  /// Returns the download URL if successful, null if failed
  Future<String?> uploadBookCoverWithProgress(
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    if (_userId == null) {
      debugPrint('User not authenticated');
      return null;
    }

    try {
      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'book_$timestamp.jpg';

      // Reference to storage location
      final ref = _storage.ref().child('book_covers/$_userId/$fileName');

      // Upload file
      final uploadTask = ref.putFile(imageFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Book cover uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading book cover: $e');
      return null;
    }
  }

  /// Delete profile image
  Future<bool> deleteProfileImage(String imageUrl) async {
    if (_userId == null) {
      debugPrint('User not authenticated');
      return false;
    }

    try {
      // Get reference from URL
      final ref = _storage.refFromURL(imageUrl);

      // Delete file
      await ref.delete();

      debugPrint('Profile image deleted');
      return true;
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
      return false;
    }
  }

  /// Delete book cover image
  Future<bool> deleteBookCover(String imageUrl) async {
    if (_userId == null) {
      debugPrint('User not authenticated');
      return false;
    }

    try {
      // Get reference from URL
      final ref = _storage.refFromURL(imageUrl);

      // Delete file
      await ref.delete();

      debugPrint('Book cover deleted');
      return true;
    } catch (e) {
      debugPrint('Error deleting book cover: $e');
      return false;
    }
  }

  /// Get all book covers for current user
  Future<List<String>> getUserBookCovers() async {
    if (_userId == null) {
      debugPrint('User not authenticated');
      return [];
    }

    try {
      final ref = _storage.ref().child('book_covers/$_userId');
      final result = await ref.listAll();

      final urls = await Future.wait(
        result.items.map((item) => item.getDownloadURL()),
      );

      return urls;
    } catch (e) {
      debugPrint('Error getting user book covers: $e');
      return [];
    }
  }

  /// Delete all book covers for current user
  Future<bool> deleteAllUserBookCovers() async {
    if (_userId == null) {
      debugPrint('User not authenticated');
      return false;
    }

    try {
      final ref = _storage.ref().child('book_covers/$_userId');
      final result = await ref.listAll();

      // Delete all files
      await Future.wait(result.items.map((item) => item.delete()));

      debugPrint('All user book covers deleted');
      return true;
    } catch (e) {
      debugPrint('Error deleting all user book covers: $e');
      return false;
    }
  }
}

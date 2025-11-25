import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

void showFollowersDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => const FollowersDialog());
}

class FollowersDialog extends StatelessWidget {
  const FollowersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Please login first'),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('followers')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Dialog(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final followerDocs = snapshot.data!.docs;
        final followers = followerDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Unknown';
          return {
            'id': doc.id,
            'name': name,
            'email': data['email'] ?? '',
            'role': data['role'] ?? 'reader',
            'initial': name.isNotEmpty ? name[0].toUpperCase() : 'U',
          };
        }).toList();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 378),
            height: 396,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 25,
                    bottom: 25,
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9D5FF),
                          border: Border.all(
                            color: const Color(0xFFDAB2FF),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.people,
                          size: 24,
                          color: Color(0xFF8200DB),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Followers',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Arimo',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${followers.length} orang mengikuti Anda',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF717182),
                                fontFamily: 'Arimo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Followers List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: followers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada followers',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                    fontFamily: 'Arimo',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: followers.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final follower = followers[index];
                              return _buildFollowerCard(
                                context,
                                follower,
                                currentUserId,
                              );
                            },
                          ),
                  ),
                ),

                // Footer - Total
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 17,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    border: Border.all(
                      color: const Color(0xFFE9D4FF),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 14,
                        color: Color(0xFF8200DB),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Arimo',
                              color: const Color(0xFF8200DB),
                              fontSize: 13,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Total: ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(text: '${followers.length} followers'),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowerCard(
    BuildContext context,
    Map<String, dynamic> follower,
    String currentUserId,
  ) {
    final theme = Theme.of(context);
    final isAuthor = follower['role'] == 'author';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE9D5FF),
              border: Border.all(color: const Color(0xFFDAB2FF), width: 1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                follower['initial'] ?? '',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF8200DB),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Arimo',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        follower['name'] ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Arimo',
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isAuthor
                            ? const Color(0xFFE9D5FF)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        isAuthor ? '✍️ Author' : '📖 Reader',
                        style: TextStyle(
                          color: isAuthor
                              ? const Color(0xFF8200DB)
                              : const Color(0xFF364153),
                          fontFamily: 'Arimo',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Email
                Row(
                  children: [
                    const Icon(Icons.email, size: 12, color: Color(0xFF6A7282)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        follower['email'] ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6A7282),
                          fontFamily: 'Arimo',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Follow back button (only for authors)
          if (follower['role'] == 'author')
            FutureBuilder<bool>(
              future: _checkIfFollowing(currentUserId, follower['id']),
              builder: (context, snapshot) {
                final isFollowing = snapshot.data ?? false;
                
                return IconButton(
                onPressed: () async {
                  try {
                    final followerRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(follower['id'])
                        .collection('followers')
                        .doc(currentUserId);

                    if (isFollowing) {
                      // Unfollow
                      await followerRef.delete();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Unfollowed ${follower['name']}')),
                        );
                      }
                    } else {
                      // Follow back
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUserId)
                          .get();
                      
                      final userData = userDoc.data();
                      
                      await followerRef.set({
                        'userId': currentUserId,
                        'name': userData?['name'] ?? 'Unknown User',
                        'email': userData?['email'] ?? '',
                        'role': userData?['role'] ?? 'reader',
                        'followedAt': FieldValue.serverTimestamp(),
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Following ${follower['name']}')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                icon: Icon(
                  isFollowing ? Icons.person_remove_alt_1 : Icons.person_add_alt,
                  size: 20,
                  color: isFollowing ? Colors.red : const Color(0xFF10B981),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _checkIfFollowing(String currentUserId, String followerId) async {
    try {
      final followerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(followerId)
          .collection('followers')
          .doc(currentUserId)
          .get();
      return followerDoc.exists;
    } catch (e) {
      // Error checking following status
      return false;
    }
  }
}

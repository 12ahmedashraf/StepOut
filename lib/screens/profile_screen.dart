import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/app_bar.dart';
import '../widgets/navbar.dart';

class user_profile_screen extends StatefulWidget {
  final String userId;

  const user_profile_screen({super.key, required this.userId});

  @override
  State<user_profile_screen> createState() => _user_profile_screenState();
}

class _user_profile_screenState extends State<user_profile_screen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isFriend = false;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _isCurrentUser = widget.userId == currentUser?.uid;
    if (!_isCurrentUser) {
      _checkFriendship();
    }
  }

  Future<void> _checkFriendship() async {
    final friendDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('friends')
        .doc(widget.userId)
        .get();

    setState(() {
      _isFriend = friendDoc.exists;
    });
  }

  Future<void> _toggleLike(String postId) async {
    if (currentUser?.uid == null) return;

    final postRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('posts')
        .doc(postId);

    final batch = FirebaseFirestore.instance.batch();

    final currentLikeStatus = (await postRef.get()).data()?['likedBy']?.contains(currentUser?.uid) ?? false;

    if (currentLikeStatus) {
      batch.update(postRef, {
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([currentUser?.uid]),
      });
    } else {
      batch.update(postRef, {
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([currentUser?.uid]),
      });
    }

    await batch.commit();
  }

  Future<void> _toggleFriendship() async {
    final batch = FirebaseFirestore.instance.batch();
    final currentUserFriendsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('friends')
        .doc(widget.userId);

    final targetUserFriendsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('friends')
        .doc(currentUser?.uid);

    if (_isFriend) {
      batch.delete(currentUserFriendsRef);
      batch.delete(targetUserFriendsRef);
    } else {
      batch.set(currentUserFriendsRef, {'since': Timestamp.now()});
      batch.set(targetUserFriendsRef, {'since': Timestamp.now()});
    }

    await batch.commit();
    setState(() {
      _isFriend = !_isFriend;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: App_Bar(),
      body: ScreenWithNavBar(
        currentIndex: 3,
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['username'] ?? 'No username';
            final firstName = userData['firstName'] ?? '';
            final lastName = userData['lastName'] ?? '';
            final profilePicture = userData['profilePicture'];
            final points = userData['points'] ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: profilePicture != null
                              ? NetworkImage(profilePicture)
                              : null,
                          child: profilePicture == null
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '@$username',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$firstName $lastName',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!_isCurrentUser)
                          IconButton(
                            icon: FaIcon(
                              _isFriend
                                  ? FontAwesomeIcons.userCheck
                                  : FontAwesomeIcons.userPlus,
                              color: _isFriend ? Colors.green : Colors.blue,
                              size: 28,
                            ),
                            onPressed: _toggleFriendship,
                            tooltip: _isFriend ? 'Friends' : 'Add Friend',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Color(0xFFE9FBF4),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          '$points Points',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .collection('posts')
                        .orderBy('timestamp', descending: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final posts = snapshot.data!.docs;

                      if (posts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No posts yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final data = post.data() as Map<String, dynamic>;
                          final text = data['text'] ?? '';
                          final imageUrl = data['imageUrl'];
                          final timestamp = data['timestamp'] as Timestamp?;
                          final isLiked = data['likedBy']?.contains(currentUser?.uid) ?? false;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage: NetworkImage(profilePicture ?? ''),
                                        child: profilePicture == null
                                            ? const Icon(Icons.person, size: 16)
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '@$username',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            timestamp != null
                                                ? _formatDate(timestamp.toDate())
                                                : '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                                    child: Text(
                                      text,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                if (imageUrl != null && imageUrl.isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 300,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? Colors.red : Colors.black,
                                        size: 28,
                                      ),
                                      onPressed: () => _toggleLike(post.id),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
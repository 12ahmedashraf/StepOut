import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_bar.dart';
import '../widgets/navbar.dart';
import 'profile_screen.dart';

class leaderboard_screen extends StatefulWidget {
  const leaderboard_screen({super.key});

  @override
  State<leaderboard_screen> createState() => _leaderboard_screenState();
}

class _leaderboard_screenState extends State<leaderboard_screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currentUser = FirebaseAuth.instance.currentUser;
  String? _currentUserCountry;
  List<String> _friendIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser?.uid == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();

    final friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .collection('friends')
        .get();

    setState(() {
      _currentUserCountry = userDoc['country'];
      _friendIds = friendsSnapshot.docs.map((doc) => doc.id).toList();
      _friendIds.add(currentUser!.uid);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: App_Bar(),
      body: ScreenWithNavBar(
        currentIndex: 1,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              margin: const EdgeInsets.all(12),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '🌍 Global'),
                  Tab(text: '📍 Regional'),
                  Tab(text: '👥 Friends'),
                ],
                labelColor: Colors.green,
                unselectedLabelColor: Colors.white,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green.withOpacity(0.2),
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGlobalLeaderboard(),
                  _buildRegionalLeaderboard(),
                  _buildFriendsLeaderboard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalLeaderboard() {
    return _buildLeaderboard(
      query: FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .limit(100),
      title: 'Global Champions',
    );
  }

  Widget _buildRegionalLeaderboard() {
    if (_currentUserCountry == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildLeaderboard(
      query: FirebaseFirestore.instance
          .collection('users')
          .where('country', isEqualTo: _currentUserCountry)
          .orderBy('points', descending: true),
      title: 'Local Heroes (${_currentUserCountry})',
    );
  }

  Widget _buildFriendsLeaderboard() {
    if (_friendIds.isEmpty) {
      return const Center(child: Text('Add friends to see the leaderboard'));
    }

    return _buildLeaderboard(
      query: FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: _friendIds)
          .orderBy('points', descending: true),
      title: 'Friendlies',
    );
  }

  Widget _buildLeaderboard({
    required Query query,
    required String title,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        final users = snapshot.data!.docs;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final data = user.data() as Map<String, dynamic>;
                  final isCurrentUser = user.id == currentUser?.uid;

                  return _buildLeaderboardTile(
                    rank: index + 1,
                    user: user,
                    data: data,
                    isCurrentUser: isCurrentUser,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaderboardTile({
    required int rank,
    required QueryDocumentSnapshot user,
    required Map<String, dynamic> data,
    required bool isCurrentUser,
  }) {
    final points = data['points'] ?? 0;
    final username = data['username'] ?? 'No username';
    final firstName = data['firstName'] ?? '';
    final lastName = data['lastName'] ?? '';
    final profilePicture = data['profilePicture'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? Colors.green : Colors.grey.shade200,
          width: isCurrentUser ? 1.5 : 1,
        ),
        boxShadow: [
          if (isCurrentUser)
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          backgroundImage: profilePicture != null
              ? NetworkImage(profilePicture)
              : null,
          child: profilePicture == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '@$username',
                style: TextStyle(
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentUser ? Colors.green : Colors.black,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text('$firstName $lastName'),
        trailing: Chip(
          label: Text(
            '$points pts',
            style: TextStyle(
              color: isCurrentUser ? Colors.green : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey[100],
          side: BorderSide.none,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => user_profile_screen(userId: user.id),
            ),
          );
        },
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return Colors.amber;
      case 2: return Colors.grey;
      case 3: return Colors.brown;
      default: return Colors.grey[200]!;
    }
  }
}
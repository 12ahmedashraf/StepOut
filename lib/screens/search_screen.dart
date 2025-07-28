import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_bar.dart';
import '../widgets/navbar.dart';
import 'profile_screen.dart';

class search_screen extends StatefulWidget {
  const search_screen({super.key});

  @override
  State<search_screen> createState() => _search_screenState();
}

class _search_screenState extends State<search_screen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: App_Bar(),
      body: ScreenWithNavBar(
        currentIndex: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                    _isSearching = value.isNotEmpty;
                  });
                },
              ),
            ),
            Expanded(
              child: _isSearching
                  ? _buildSearchResults()
                  : _buildRecentSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return const Center(child: Text('Start typing to search users'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: _searchQuery)
          .where('username', isLessThan: '${_searchQuery}z')
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final data = user.data() as Map<String, dynamic>;
            final username = data['username'] ?? 'No username';
            final firstName = data['firstName'] ?? '';
            final lastName = data['lastName'] ?? '';
            final profilePicture = data['profilePicture'];

            return ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: profilePicture != null
                    ? NetworkImage(profilePicture)
                    : null,
                child: profilePicture == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text('@$username'),
              subtitle: Text('$firstName $lastName'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => user_profile_screen(userId: user.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return const Center(
      child: Text(
        'Search for users by username',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
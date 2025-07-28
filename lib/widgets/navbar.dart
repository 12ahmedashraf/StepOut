import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
final _profileImageCache = <String, String>{};

class NavBar extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF10B981),
      unselectedItemColor: Colors.black,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'Dosis',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Dosis',
        fontSize: 12,
      ),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Leaderboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: _ProfileAvatar(uid: currentUser?.uid),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  final String? uid;

  const _ProfileAvatar({this.uid});

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  String? _cachedImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) {
      _cachedImageUrl = _profileImageCache[widget.uid];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.uid == null) return _buildDefaultAvatar();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final profilePic = snapshot.data!['profilePicture'] as String?;
          if (profilePic != null && profilePic.isNotEmpty) {
            _cachedImageUrl = profilePic;
            _profileImageCache[widget.uid!] = profilePic;

            return CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(profilePic),
            );
          }
        }

        if (_cachedImageUrl != null) {
          return CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(_cachedImageUrl!),
          );
        }

        return _buildDefaultAvatar();
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return const CircleAvatar(
      radius: 14,
      child: Icon(Icons.person, size: 14),
    );
  }
}

class ScreenWithNavBar extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final List<Widget>? actions;

  const ScreenWithNavBar({
    super.key,
    required this.child,
    required this.currentIndex,
    this.actions,
  });

  @override
  State<ScreenWithNavBar> createState() => _ScreenWithNavBarState();
}

class _ScreenWithNavBarState extends State<ScreenWithNavBar> {
  void _onItemTapped(int index) {
    if (index == widget.currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/leaderboard');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavBar(
        currentIndex: widget.currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
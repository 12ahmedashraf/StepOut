import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_bar.dart';
import '../widgets/navbar.dart';

class home_screen extends StatefulWidget {
  const home_screen({super.key});

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _hasPosted = false;
  bool _cantComplete = false;

  @override
  void initState() {
    super.initState();
    _checkStreak();
  }

  Future<void> _checkStreak() async {
    final today = DateTime.now();
    final startOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('posts')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();
    if (postsSnapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'streak': 0});
    }
  }

  Future<String> getFirstName() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    return doc['firstName'] ?? 'User';
  }

  Future<Map<String, dynamic>?> getDailyChallenge() async {
    final today = DateTime.now();
    final formattedDate =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final doc =
    await FirebaseFirestore.instance.collection('daily_challenges').doc(formattedDate).get();
    return doc.exists ? doc.data() : null;
  }

  Future<bool> hasPostedToday() async {
    final today = DateTime.now();
    final startOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('posts')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();
    return postsSnapshot.docs.isNotEmpty;
  }

  void showPostPromptDialog(BuildContext context, Map<String, dynamic> challenge) async {
    final posted = await hasPostedToday();
    if (!mounted) return;

    if (posted) {
      setState(() {
        _hasPosted = true;
        _cantComplete = false;
      });
      return;
    }

    Navigator.pushNamed(context, '/create_post', arguments: {
      'challengePoints': challenge['points'],
      'challengeStep': challenge['challenge'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: App_Bar(),
      body: ScreenWithNavBar(
        currentIndex: 0,
        child: FutureBuilder(
          future: Future.wait([
            getFirstName(),
            getDailyChallenge(),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final firstName = snapshot.data![0] as String;
            final challenge = snapshot.data![1] as Map<String, dynamic>?;

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const CircularProgressIndicator();

                final stats = userSnapshot.data!.data() as Map<String, dynamic>;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Hi, $firstName 👋',
                          style:
                          const TextStyle(fontSize: 26, fontWeight: FontWeight.bold,fontFamily: 'Dosis')),
                      const SizedBox(height: 20),

                      if (challenge != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFE9FBF4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Challenge of the Day 🔥",
                                  style:
                                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold,fontFamily: 'Dosis',color: Color(0xFF10B981))),
                              const SizedBox(height: 8),
                              Text(challenge['quote'] ?? '',
                                  style: const TextStyle(fontStyle: FontStyle.italic,color: Colors.black87,fontFamily: 'Inter')),
                              const SizedBox(height: 10),
                              Text(challenge['challenge'] ?? '',style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,fontFamily: 'Dosis',color: Color(0xFF10B981)),textAlign: TextAlign.center,),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => showPostPromptDialog(context,challenge),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    child: Text("Gain ${challenge['points']} points",style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,fontFamily: 'Dosis',color: Color(0xFF10B981)),),
                                  ),
                                  ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                      _cantComplete = true;
                                      _hasPosted = false;
                                      });
                                      },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    child: Text("Can't do it :(",style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,fontFamily: 'Dosis',color: Colors.red),),
                                  ),
                                ],
                              ),
                              if (_hasPosted)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "You already posted today ✅",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              if (_cantComplete)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Don't worry! Try again tomorrow 🌞",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        const Text("No challenge available today."),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatBox("Points", (stats['points'] ?? 0).toString()),
                          _buildStatBox("Challenges",
                              (stats['completedChallenges'] ?? 0).toString()),
                          _buildStatBox("Streak", "${stats['streak'] ?? 0}d"),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Text("👣 Your Steps",
                          style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Color(0xFF10B981),fontFamily: 'Dosis')),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .collection('steps')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, stepSnapshot) {
                          if (!stepSnapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final steps = stepSnapshot.data!.docs;
                          if (steps.isEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:[ Text("You haven't taken any steps yet.",style:
                                TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.red,fontFamily: 'Dosis')),]
                            );
                          }
                          return Column(
                            children: steps.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE9FBF4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(data['step'] ?? 'No step description',style: TextStyle(color: Color(0xFF10B981),fontFamily: 'Dosis',fontWeight: FontWeight.bold,fontSize: 15),),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
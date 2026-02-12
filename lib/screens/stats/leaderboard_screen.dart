import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: const Center(
        child: Text('Leaderboard Coming Soon!', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}

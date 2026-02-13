import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final users = [
      {'name': 'Shoaib', 'distance': '124.5 km', 'rank': 1},
      {'name': 'RunnerX', 'distance': '98.2 km', 'rank': 2},
      {'name': 'Speedster', 'distance': '87.0 km', 'rank': 3},
      {'name': 'Ghost', 'distance': '45.3 km', 'rank': 4},
      {'name': 'Newbie', 'distance': '12.1 km', 'rank': 5},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E1E), Colors.black],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 100, bottom: 20),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isTop3 = index < 3;
            
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + (index * 100)),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: isTop3 
                      ? Border.all(color: const Color(0xFF00FF88).withOpacity(0.5)) 
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isTop3 ? const Color(0xFF00FF88) : Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${user['rank']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isTop3 ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        user['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      user['distance'] as String,
                      style: const TextStyle(
                        color: Color(0xFF00FF88),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

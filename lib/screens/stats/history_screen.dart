import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final runs = [
      {'date': 'Today', 'distance': '5.2 km', 'time': '24:30', 'pace': '4:42 /km'},
      {'date': 'Yesterday', 'distance': '3.1 km', 'time': '14:20', 'pace': '4:37 /km'},
      {'date': 'Feb 10', 'distance': '10.0 km', 'time': '48:15', 'pace': '4:49 /km'},
      {'date': 'Feb 8', 'distance': '2.5 km', 'time': '12:10', 'pace': '4:52 /km'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run History'),
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
          itemCount: runs.length,
          itemBuilder: (context, index) {
            final run = runs[index];
            
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(-50 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          run['date'] as String,
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FF88).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            run['distance'] as String,
                            style: const TextStyle(
                              color: Color(0xFF00FF88),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(run['time'] as String, style: const TextStyle(color: Colors.white)),
                        const SizedBox(width: 20),
                        const Icon(Icons.speed, color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(run['pace'] as String, style: const TextStyle(color: Colors.white)),
                      ],
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

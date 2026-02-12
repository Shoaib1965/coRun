import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run History')),
      body: const Center(
        child: Text('Run History Coming Soon!', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}

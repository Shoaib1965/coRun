import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class LiquidButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isRunning;
  final double size;

  const LiquidButton({
    super.key,
    required this.onTap,
    required this.isRunning,
    this.size = 80,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Fast press
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isRunning ? const Color(0xFFFF3B30) : const Color(0xFF00FF88), // iOS Red / Neon Green
            boxShadow: [
              BoxShadow(
                color: (widget.isRunning ? const Color(0xFFFF3B30) : const Color(0xFF00FF88)).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
              color: Colors.black,
              size: widget.size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

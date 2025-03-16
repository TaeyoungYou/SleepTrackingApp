import 'package:flutter/material.dart';
import 'package:unknow/config/colors.dart';

class SlidePopup extends StatefulWidget {
  final String message;
  final Duration displayDuration;

  const SlidePopup({
    super.key,
    required this.message,
    required this.displayDuration,
  });

  @override
  State<SlidePopup> createState() => _SlidePopupState();
}

class _SlidePopupState extends State<SlidePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    Future.delayed(widget.displayDuration, () {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        alignment: Alignment.bottomCenter,
        color: UI_Black.withOpacity(0.9),
        child: Text(
          widget.message,
          textAlign: TextAlign.center,
          style: TextStyle(color: UI_White, fontSize: 16),
        ),
      ),
    );
  }
}

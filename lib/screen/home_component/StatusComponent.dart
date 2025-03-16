import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../config/colors.dart';

class StatusComponent extends StatelessWidget {
  double result;
  StatusComponent({required this.result, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: UI_Black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child:
            (result > 0.4)
                ? Lottie.asset(
                  'assets/emoji/awake.json',
                  width: 160,
                  height: 160,
                  repeat: true,
                  animate: true,
                )
                : Lottie.asset(
                  'assets/emoji/sleep.json',
                  width: 160,
                  height: 160,
                  repeat: true,
                  animate: true,
                ),
      ),
    );
  }
}

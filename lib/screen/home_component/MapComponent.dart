import 'package:flutter/material.dart';
import 'package:unknow/map/google_lib.dart';

import '../../config/colors.dart';

class MapComponent extends StatelessWidget {
  const MapComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 350,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GoogleMapFlutter(),
      ),
    );
  }
}

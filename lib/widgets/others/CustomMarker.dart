import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomMarker extends StatelessWidget {
  Widget build(BuildContext context) {
    double ratio = MediaQuery.of(context).devicePixelRatio;
    double baseSize = 23.2727 * ratio;

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Icon(Icons.location_on, size: baseSize, color: Color.fromRGBO(252, 116, 79, 1)),
        Positioned(
            top: 0.234375 * baseSize,
            child: Container(
              height: 0.3125 * baseSize,
              width: 0.3125 * baseSize,
              color: Color.fromRGBO(252, 116, 79, 1),
            )
        ),
        Positioned(
            top: 0.15625 * baseSize,
            child: Icon(Icons.store, color: Colors.white, size: 0.46875 * baseSize)
        )
      ],
    );
  }
}
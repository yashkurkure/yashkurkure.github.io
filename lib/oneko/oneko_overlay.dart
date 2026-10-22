import 'package:flutter/material.dart';

/// Draws oneko cat on top of [child]
/// Port of https://github.com/adryd325/oneko.js (MIT).
/// 
/// TODO: There are several widget that a beginner like me does not know about. A list of them to
/// explore is as follows:
/// 1. Stack
/// 2. IgnorePointer
/// 3. ClipRect
/// 4. OverflowBox
/// 5. Transform
/// 6. Image

class OnekoOverlay extends StatelessWidget {
  
  // What is super.key?
  const OnekoOverlay({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {

    // What is the Stack widget?
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          left: 16,
          top: 16,
          // What is the IgnorePointer widget?
          child: IgnorePointer(
            child: SizedBox(
              width: 32,
              height: 32,
              // What is the ClipRect widget?
              child: ClipRect(
                // What is the OverflowBox?
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  maxWidth: 256,
                  maxHeight: 128,
                  // What is the Transform widget?
                  child: Transform.translate(
                    offset: const Offset(-3*32, -3*32),
                    // How do image assets work?
                    child: Image.asset('assets/images/oneko.png',
                    width: 256,
                    height: 128,
                    filterQuality: FilterQuality.none,)
                  )
                )
              )
            )
          )
        )
      ],
    );
  }
  
}
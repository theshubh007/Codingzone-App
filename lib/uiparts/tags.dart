import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Tags extends StatelessWidget {
  String title;
  int width;
  Color color;
  Tags({required this.title, required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.toDouble(),
      height: 45,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.only(
        left: 20,
        top: 11,
        right: 20,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: color,
        /* border: Border.all(
          color: Colors.teal,
          width: 2.00,
        ),*/
        borderRadius: BorderRadius.circular(12.00),
      ),
      child: Center(
        child: AutoSizeText(
          title,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

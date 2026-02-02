import 'package:flutter/material.dart';

class MeetingRoomMapPlaceholder extends StatelessWidget {
  const MeetingRoomMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: Image.asset(
        'assets/images/map_placeholder.png',
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}

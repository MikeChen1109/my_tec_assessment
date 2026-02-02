import 'package:flutter/material.dart';
import '../theme/meeting_room_theme.dart';

class MeetingRoomAppBarTitle extends StatelessWidget {
  const MeetingRoomAppBarTitle({super.key, required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: MeetingRoomTheme.primaryBlue,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.near_me_outlined,
            size: 20,
            color: MeetingRoomTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
}

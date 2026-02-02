import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/meeting_room_filter_state_provider.dart';
import '../state/meeting_room_home_state_provider.dart';
import '../utils/meeting_room_time_helper.dart';
import 'meeting_room_filter_chip.dart';
import 'meeting_room_filter_sheet.dart';

class MeetingRoomFilterBar extends ConsumerWidget {
  const MeetingRoomFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(meetingRoomHomeStateProvider);
    final filterState = ref.watch(meetingRoomFilterStateProvider);
    final cityName = homeState.city?.name ?? '';
    final centresLabel = filterState.selectedCentreCodes == null
        ? MeetingRoomFilterState.allCentresLabel(cityName)
        : filterState.centresLabel;
    final dateLabel = MeetingRoomTimeHelper.formatDateLabel(filterState.date);
    final timeRangeLabel = MeetingRoomTimeHelper.buildTimeRangeLabelFrom(
      filterState.startDateTime,
      filterState.endDateTime,
    );
    final capacityLabel = '${filterState.capacity} Seats';

    Future<void> openFilterSheet() async {
      final result = await MeetingRoomFilterSheet.show(
        context,
        data: filterState,
        centres: homeState.centreGroups,
        location: cityName,
      );
      if (result == null) {
        return;
      }
      final didChange = !_isSameFilter(filterState, result);
      ref.read(meetingRoomFilterStateProvider.notifier).updateFrom(result);
      if (didChange) {
        await ref.read(meetingRoomHomeStateProvider.notifier).refreshForFilter();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          MeetingRoomFilterChip(
            icon: Icons.tune,
            label: 'Filter',
            onTap: openFilterSheet,
            isPrimary: true,
          ),
          MeetingRoomFilterChip(
            icon: Icons.calendar_today_outlined,
            label: dateLabel,
            onTap: openFilterSheet,
          ),
          MeetingRoomFilterChip(
            icon: Icons.schedule,
            label: timeRangeLabel,
            onTap: openFilterSheet,
          ),
          MeetingRoomFilterChip(
            icon: Icons.people_outline,
            label: capacityLabel,
            onTap: openFilterSheet,
          ),
          MeetingRoomFilterChip(
            icon: Icons.apartment_outlined,
            label: centresLabel,
            onTap: openFilterSheet,
          ),
        ],
      ),
    );
  }
}

bool _isSameFilter(MeetingRoomFilterState current, MeetingRoomFilterState next) {
  return current.date == next.date &&
      current.startDateTime == next.startDateTime &&
      current.endDateTime == next.endDateTime &&
      current.capacity == next.capacity &&
      current.centresLabel == next.centresLabel &&
      listEquals(current.selectedCentreCodes, next.selectedCentreCodes) &&
      current.videoConferenceEnabled == next.videoConferenceEnabled;
}

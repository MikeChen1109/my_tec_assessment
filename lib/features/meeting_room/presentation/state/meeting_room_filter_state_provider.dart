import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/meeting_room_time_helper.dart';

final meetingRoomFilterStateProvider =
    StateNotifierProvider<MeetingRoomFilterStateNotifier, MeetingRoomFilterState>(
      (ref) {
        return MeetingRoomFilterStateNotifier();
      },
    );

class MeetingRoomFilterStateNotifier
    extends StateNotifier<MeetingRoomFilterState> {
  MeetingRoomFilterStateNotifier() : super(MeetingRoomFilterState.initial());

  void updateFrom(MeetingRoomFilterState data) {
    state = data;
  }

  void setDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    state = state.copyWith(
      date: normalizedDate,
      startDateTime: MeetingRoomFilterState.combineDateAndTime(
        normalizedDate,
        state.startDateTime,
      ),
      endDateTime: MeetingRoomFilterState.combineDateAndTime(
        normalizedDate,
        state.endDateTime,
      ),
    );
  }

  void setStartDateTime(DateTime dateTime) {
    final normalized = MeetingRoomFilterState.combineDateAndTime(
      state.date,
      dateTime,
    );
    final updatedEnd = state.endDateTime.isBefore(normalized)
        ? normalized.add(const Duration(minutes: 30))
        : state.endDateTime;
    state = state.copyWith(startDateTime: normalized, endDateTime: updatedEnd);
  }

  void setEndDateTime(DateTime dateTime) {
    final normalized = MeetingRoomFilterState.combineDateAndTime(
      state.date,
      dateTime,
    );
    final updatedEnd = normalized.isBefore(state.startDateTime)
        ? state.startDateTime.add(const Duration(minutes: 15))
        : normalized;
    state = state.copyWith(endDateTime: updatedEnd);
  }

  void setCapacity(int capacity) {
    state = state.copyWith(capacity: capacity);
  }

  void setVideoConferenceEnabled(bool enabled) {
    state = state.copyWith(videoConferenceEnabled: enabled);
  }

  void setAllCentresLabel(String location) {
    if (state.selectedCentreCodes != null) return;
    final label = MeetingRoomFilterState.allCentresLabel(location);
    if (state.centresLabel == label) return;
    state = state.copyWith(centresLabel: label);
  }
}

class MeetingRoomFilterState {
  static const String defaultCentresLabel = 'All Centres';

  const MeetingRoomFilterState({
    required this.date,
    required this.startDateTime,
    required this.endDateTime,
    required this.capacity,
    required this.centresLabel,
    required this.selectedCentreCodes,
    required this.videoConferenceEnabled,
  });

  final DateTime date;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int capacity;
  final String centresLabel;
  final List<String>? selectedCentreCodes;
  final bool videoConferenceEnabled;

  factory MeetingRoomFilterState.initial() {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    final start = MeetingRoomTimeHelper.nextQuarterHour(now);
    final end = start.add(const Duration(minutes: 30));
    return MeetingRoomFilterState(
      date: date,
      startDateTime: start,
      endDateTime: end,
      capacity: 4,
      centresLabel: defaultCentresLabel,
      selectedCentreCodes: null,
      videoConferenceEnabled: false,
    );
  }

  String get capacityLabel => capacity.toString();

  MeetingRoomFilterState copyWith({
    DateTime? date,
    DateTime? startDateTime,
    DateTime? endDateTime,
    int? capacity,
    String? centresLabel,
    List<String>? selectedCentreCodes,
    bool? videoConferenceEnabled,
  }) {
    return MeetingRoomFilterState(
      date: date ?? this.date,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      capacity: capacity ?? this.capacity,
      centresLabel: centresLabel ?? this.centresLabel,
      selectedCentreCodes: selectedCentreCodes ?? this.selectedCentreCodes,
      videoConferenceEnabled:
          videoConferenceEnabled ?? this.videoConferenceEnabled,
    );
  }

  static DateTime combineDateAndTime(DateTime date, DateTime time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static String allCentresLabel(String location) {
    final trimmed = location.trim();
    return trimmed.isEmpty ? defaultCentresLabel : 'All Centres in $trimmed';
  }
}

class RoomAvailability {
  const RoomAvailability({
    required this.roomCode,
    required this.isAvailable,
    required this.isWithinOfficeHour,
    required this.isPast,
    required this.nextAvailabilities,
  });

  final String roomCode;
  final bool isAvailable;
  final bool isWithinOfficeHour;
  final bool isPast;
  final List<dynamic> nextAvailabilities;
}

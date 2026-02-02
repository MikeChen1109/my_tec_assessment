import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/centre.dart';
import '../state/meeting_room_filter_state_provider.dart';
import '../theme/meeting_room_theme.dart';
import '../utils/meeting_room_time_helper.dart';

class MeetingRoomFilterSheet {
  const MeetingRoomFilterSheet._();

  static Future<MeetingRoomFilterState?> show(
    BuildContext context, {
    required MeetingRoomFilterState data,
    required List<Centre> centres,
    required String location,
  }) async {
    return showModalBottomSheet<MeetingRoomFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _MeetingRoomFilterSheetContent(
          data: data,
          centres: centres,
          location: location,
        );
      },
    );
  }
}

class _MeetingRoomFilterSheetContent extends StatefulWidget {
  const _MeetingRoomFilterSheetContent({
    required this.data,
    required this.centres,
    required this.location,
  });

  final MeetingRoomFilterState data;
  final List<Centre> centres;
  final String location;

  @override
  State<_MeetingRoomFilterSheetContent> createState() =>
      _MeetingRoomFilterSheetContentState();
}

class _MeetingRoomFilterSheetContentState
    extends State<_MeetingRoomFilterSheetContent> {
  static const double _pillWidth = 220;
  late MeetingRoomFilterState _data;
  OverlayEntry? _validationOverlayEntry;
  Timer? _validationOverlayTimer;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    if (_data.selectedCentreCodes == null) {
      final allCentresLabel =
          MeetingRoomFilterState.allCentresLabel(widget.location);
      if (_data.centresLabel != allCentresLabel) {
        _data = _data.copyWith(centresLabel: allCentresLabel);
      }
    }
  }

  void _apply() {
    Navigator.of(context).pop(_data);
  }

  void _reset() {
    final initial = MeetingRoomFilterState.initial();
    final allCentresLabel =
        MeetingRoomFilterState.allCentresLabel(widget.location);
    setState(() {
      _data = initial.copyWith(
        centresLabel: allCentresLabel,
        selectedCentreCodes: null,
      );
    });
  }

  @override
  void dispose() {
    _validationOverlayTimer?.cancel();
    _validationOverlayEntry?.remove();
    super.dispose();
  }

  void _showEndTimeValidationOverlay() {
    final overlay = Overlay.of(context);
    _validationOverlayEntry?.remove();
    _validationOverlayTimer?.cancel();

    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top;
    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 16,
          right: 16,
          top: 72 + topInset,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF323232),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'End time must be at least 30 minutes after start time.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _validationOverlayEntry = entry;
    _validationOverlayTimer = Timer(const Duration(seconds: 2), () {
      _validationOverlayEntry?.remove();
      _validationOverlayEntry = null;
    });
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final lastDate = firstDate.add(const Duration(days: 365));
    final initialDate = _data.date.isBefore(firstDate) ? firstDate : _data.date;
    final selected = await _showDatePickerBottomSheet(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (selected == null) return;
    final normalizedDate = DateTime(
      selected.year,
      selected.month,
      selected.day,
    );
    setState(() {
      _data = _data.copyWith(
        date: normalizedDate,
        startDateTime: MeetingRoomFilterState.combineDateAndTime(
          normalizedDate,
          _data.startDateTime,
        ),
        endDateTime: MeetingRoomFilterState.combineDateAndTime(
          normalizedDate,
          _data.endDateTime,
        ),
      );
    });
  }

  Future<void> _selectStartTime() async {
    final selected = await _showTimePickerBottomSheet(
      title: 'Start Time',
      initialDateTime: _data.startDateTime,
    );
    if (selected == null) return;
    final normalized = MeetingRoomFilterState.combineDateAndTime(
      _data.date,
      selected,
    );
    setState(() {
      _data = _data.copyWith(
        startDateTime: normalized,
        endDateTime: normalized.add(const Duration(minutes: 30)),
      );
    });
  }

  Future<void> _selectEndTime() async {
    final selected = await _showTimePickerBottomSheet(
      title: 'End Time',
      initialDateTime: _data.endDateTime,
    );
    if (selected == null) return;
    final normalized = MeetingRoomFilterState.combineDateAndTime(
      _data.date,
      selected,
    );
    final minimumEnd = _data.startDateTime.add(const Duration(minutes: 30));
    if (normalized.isBefore(minimumEnd)) {
      _showEndTimeValidationOverlay();
      return;
    }
    setState(() {
      _data = _data.copyWith(endDateTime: normalized);
    });
  }

  Future<void> _selectCapacity() async {
    final selected = await _showCapacityPickerBottomSheet(
      initialCapacity: _data.capacity,
    );
    if (selected == null) return;
    setState(() {
      _data = _data.copyWith(capacity: selected);
    });
  }

  Future<void> _selectCentres() async {
    final selection = await _showCentrePickerBottomSheet(
      centres: widget.centres,
      location: widget.location,
      selectedCentreCodes: _data.selectedCentreCodes,
    );
    if (selection == null) return;
    setState(() {
      _data = _data.copyWith(
        centresLabel: selection.label,
        selectedCentreCodes: selection.codes,
      );
    });
  }

  String _formatTimeLabel(DateTime dateTime) {
    return MeetingRoomTimeHelper.formatTime(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _reset,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade500,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade300, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  _FilterRow(
                    label: 'Date',
                    child: _PillButton(
                      label: MeetingRoomTimeHelper.formatDateLabel(_data.date),
                      icon: Icons.calendar_today_outlined,
                      width: _pillWidth,
                      onTap: _selectDate,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FilterRow(
                    label: 'Start Time',
                    child: _PillButton(
                      label: _formatTimeLabel(_data.startDateTime),
                      icon: Icons.access_time,
                      width: _pillWidth,
                      onTap: _selectStartTime,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FilterRow(
                    label: 'End Time',
                    child: _PillButton(
                      label: _formatTimeLabel(_data.endDateTime),
                      icon: Icons.access_time,
                      width: _pillWidth,
                      onTap: _selectEndTime,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FilterRow(
                    label: 'Capacity',
                    child: _PillButton(
                      label: _data.capacityLabel,
                      icon: Icons.expand_more,
                      width: _pillWidth,
                      onTap: _selectCapacity,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FilterRow(
                    label: 'Centres',
                    child: _PillButton(
                      label: _data.centresLabel,
                      icon: Icons.expand_more,
                      width: _pillWidth,
                      onTap: _selectCentres,
                      labelOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FilterRow(
                    label: 'Video Conference',
                    child: Switch.adaptive(
                      value: _data.videoConferenceEnabled,
                      onChanged: (value) => setState(() {
                        _data = _data.copyWith(videoConferenceEnabled: value);
                      }),
                      activeColor: MeetingRoomTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MeetingRoomTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _showDatePickerBottomSheet({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    DateTime selectedDate = initialDate;
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Select date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (value) => selectedDate = value,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(selectedDate),
                      style: TextButton.styleFrom(
                        foregroundColor: MeetingRoomTheme.primaryBlue,
                      ),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<DateTime?> _showTimePickerBottomSheet({
    required String title,
    required DateTime initialDateTime,
  }) async {
    DateTime selectedDateTime = initialDateTime;
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false,
                  minuteInterval: 15,
                  initialDateTime: initialDateTime,
                  onDateTimeChanged: (value) => selectedDateTime = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(selectedDateTime),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MeetingRoomTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int?> _showCapacityPickerBottomSheet({
    required int initialCapacity,
  }) async {
    final capacities = List<int>.generate(20, (index) => index + 1);
    int selectedCapacity = initialCapacity;
    final initialIndex = capacities.indexOf(initialCapacity).clamp(0, 19);
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Capacity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: CupertinoPicker(
                  itemExtent: 36,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  onSelectedItemChanged: (index) {
                    selectedCapacity = capacities[index];
                  },
                  children: capacities
                      .map(
                        (value) => Center(
                          child: Text(
                            value.toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(selectedCapacity),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MeetingRoomTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<_CentreSelection?> _showCentrePickerBottomSheet({
    required List<Centre> centres,
    required String location,
    required List<String>? selectedCentreCodes,
  }) async {
    final allCentresLabel = MeetingRoomFilterState.allCentresLabel(location);
    return showModalBottomSheet<_CentreSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Centres',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: centres.length + 1,
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade200, height: 1),
                    itemBuilder: (context, index) {
                      final isAllCentres = index == 0;
                      final label = isAllCentres
                          ? allCentresLabel
                          : _centreLabel(centres[index - 1]);
                      final centreCodes = isAllCentres
                          ? null
                          : centres[index - 1].centreCodesForVoCwCheckout;
                      final isSelected = isAllCentres
                          ? selectedCentreCodes == null
                          : listEquals(selectedCentreCodes, centreCodes);
                      return ListTile(
                        title: Text(
                          label,
                          style: const TextStyle(
                            color: MeetingRoomTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                                color: MeetingRoomTheme.primaryBlue,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(
                          _CentreSelection(codes: centreCodes, label: label),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _centreLabel(Centre centre) {
    return centre.localizedName.en ??
        centre.localizedName.zhHans ??
        centre.localizedName.zhHant ??
        centre.localizedName.jp ??
        centre.localizedName.kr ??
        'Unnamed Centre';
  }
}

class _CentreSelection {
  const _CentreSelection({required this.codes, required this.label});

  final List<String>? codes;
  final String label;
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: MeetingRoomTheme.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.width,
    this.labelOverflow,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double width;
  final TextOverflow? labelOverflow;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      overflow: labelOverflow,
      style: const TextStyle(
        color: MeetingRoomTheme.primaryBlue,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );

    final iconWidget = Icon(icon, size: 18, color: Colors.grey.shade500);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: width,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: labelWidget),
              const SizedBox(width: 8),
              iconWidget,
            ],
          ),
        ),
      ),
    );
  }
}

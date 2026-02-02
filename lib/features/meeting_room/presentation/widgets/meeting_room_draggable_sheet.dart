import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/meeting_room_view_mode.dart';
import '../state/meeting_room_home_state_provider.dart';

class MeetingRoomDraggableSheetController {
  Object? _owner;
  Future<void> Function(MeetingRoomViewMode)? _request;

  bool get isAttached => _request != null;

  void _attach(
    Object owner,
    Future<void> Function(MeetingRoomViewMode) request,
  ) {
    _owner = owner;
    _request = request;
  }

  void _detach(Object owner) {
    if (_owner != owner) return;
    _owner = null;
    _request = null;
  }

  Future<void> requestMode(MeetingRoomViewMode target) {
    final request = _request;
    if (request == null) return Future.value();
    return request(target);
  }
}

class MeetingRoomDraggableSheet extends ConsumerStatefulWidget {
  const MeetingRoomDraggableSheet({
    super.key,
    this.controller,
    required this.header,
    required this.child,
  });

  final MeetingRoomDraggableSheetController? controller;
  final Widget header;
  final Widget child;

  @override
  ConsumerState<MeetingRoomDraggableSheet> createState() =>
      _MeetingRoomDraggableSheetState();
}

class _MeetingRoomDraggableSheetState
    extends ConsumerState<MeetingRoomDraggableSheet>
    with SingleTickerProviderStateMixin {
  static const double _minSize = 0.35;
  static const double _midSize = 0.55;
  static const double _maxSize = 1.05;

  late final AnimationController _animController;
  Animation<double>? _sizeAnim;

  double _sheetSize = _minSize;
  bool _switchingToList = false;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        )..addListener(() {
          final anim = _sizeAnim;
          if (anim == null) return;
          setState(() => _sheetSize = anim.value);
        });
    widget.controller?._attach(this, _setMode);
  }

  @override
  void didUpdateWidget(MeetingRoomDraggableSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller?._detach(this);
    widget.controller?._attach(this, _setMode);
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _animController.dispose();
    super.dispose();
  }

  double _clampSize(double v) => v.clamp(_minSize, _maxSize);

  double _nearestSnap(double v) {
    const snaps = [_minSize, _midSize, _maxSize];
    double best = snaps.first;
    double bestDist = (v - best).abs();
    for (final s in snaps.skip(1)) {
      final d = (v - s).abs();
      if (d < bestDist) {
        bestDist = d;
        best = s;
      }
    }
    return best;
  }

  Future<void> _animateSheetTo(double target) async {
    target = _clampSize(target);
    _animController.stop();
    _sizeAnim = Tween<double>(
      begin: _sheetSize,
      end: target,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController
      ..reset()
      ..forward();
    await _animController.forward(from: 0);
  }

  Future<void> _setMode(MeetingRoomViewMode target) async {
    final current = ref.read(meetingRoomHomeStateProvider).viewMode;
    if (current == target) return;

    if (current == MeetingRoomViewMode.list &&
        target == MeetingRoomViewMode.map) {
      ref.read(meetingRoomHomeStateProvider.notifier).setViewMode(target);
      await _animateSheetTo(_midSize);
      return;
    }

    if (target == MeetingRoomViewMode.list) {
      _switchingToList = true;
      try {
        await _animateSheetTo(_maxSize);
        ref.read(meetingRoomHomeStateProvider.notifier).setViewMode(target);
      } finally {
        _switchingToList = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(meetingRoomHomeStateProvider).viewMode;
    final bool isListMode =
        viewMode == MeetingRoomViewMode.list && !_switchingToList;

    final media = MediaQuery.of(context);
    final appBarH =
        Scaffold.maybeOf(context)?.appBarMaxHeight ?? kToolbarHeight;
    final screenH =
        media.size.height - media.padding.top - media.padding.bottom - appBarH;
    final sheetH = screenH * (isListMode ? _maxSize : _sheetSize);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: sheetH,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isListMode
              ? BorderRadius.zero
              : const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5),
          ],
        ),
        child: Column(
          children: [
            _SheetDragArea(
              onDragUpdate: isListMode
                  ? null
                  : (dy) {
                      const lockThreshold = 0.985;
                      if (_sheetSize >= _maxSize * lockThreshold && dy > 0) {
                        return;
                      }

                      final delta = dy / screenH;
                      setState(
                        () => _sheetSize = _clampSize(_sheetSize - delta),
                      );
                    },
              onDragEnd: isListMode
                  ? null
                  : () async {
                      final snapped = _nearestSnap(_sheetSize);
                      if (snapped == _maxSize) {
                        await _setMode(MeetingRoomViewMode.list);
                        return;
                      }

                      await _animateSheetTo(snapped);

                      if (ref.read(meetingRoomHomeStateProvider).viewMode !=
                          MeetingRoomViewMode.map) {
                        ref
                            .read(meetingRoomHomeStateProvider.notifier)
                            .setViewMode(MeetingRoomViewMode.map);
                      }
                    },
              child: Column(
                children: [
                  // handle
                  if (!isListMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 8),
                      child: Container(
                        width: 80,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: widget.header,
                  ),
                ],
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

class _SheetDragArea extends StatelessWidget {
  const _SheetDragArea({
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  final ValueChanged<double>? onDragUpdate;
  final VoidCallback? onDragEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onDragUpdate == null
          ? null
          : (details) => onDragUpdate!(details.delta.dy),
      onVerticalDragEnd: onDragEnd == null ? null : (_) => onDragEnd!(),
      child: child,
    );
  }
}

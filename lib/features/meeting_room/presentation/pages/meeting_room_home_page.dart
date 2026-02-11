import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/meeting_room_home_state.dart';
import '../state/meeting_room_home_state_provider.dart';
import '../state/meeting_room_view_mode.dart';
import '../widgets/meeting_room_draggable_sheet.dart';
import '../widgets/meeting_room_app_bar_title.dart';
import '../widgets/meeting_room_error_retry.dart';
import '../widgets/meeting_room_filter_bar.dart';
import '../widgets/meeting_room_location_dialog.dart';
import '../widgets/meeting_room_map_placeholder.dart';
import '../widgets/meeting_room_room_list_content.dart';
import '../theme/meeting_room_theme.dart';

class MeetingRoomHomePage extends ConsumerStatefulWidget {
  const MeetingRoomHomePage({super.key});

  @override
  ConsumerState<MeetingRoomHomePage> createState() =>
      _MeetingRoomHomePageState();
}

class _MeetingRoomHomePageState extends ConsumerState<MeetingRoomHomePage> {
  late final MeetingRoomDraggableSheetController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = MeetingRoomDraggableSheetController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(meetingRoomHomeStateProvider);
    final viewMode = homeState.viewMode;

    final IconData viewModeIcon = viewMode == MeetingRoomViewMode.map
        ? Icons.list
        : Icons.map;

    void toggleViewMode() {
      final target = viewMode == MeetingRoomViewMode.map
          ? MeetingRoomViewMode.list
          : MeetingRoomViewMode.map;
      final handled = _sheetController.isAttached;
      _sheetController.requestMode(target);
      if (!handled) {
        ref.read(meetingRoomHomeStateProvider.notifier).setViewMode(target);
      }
    }

    final Widget body = homeState.status == MeetingRoomHomeStatus.error
        ? MeetingRoomErrorRetry(
            onRetry: () =>
                ref.read(meetingRoomHomeStateProvider.notifier).retry(),
          )
        : Stack(
            children: [
              const Positioned.fill(child: MeetingRoomMapPlaceholder()),
              MeetingRoomDraggableSheet(
                controller: _sheetController,
                header: SizedBox(
                  width: double.infinity,
                  child: MeetingRoomFilterBar(),
                ),
                child: MeetingRoomRoomListContent(
                  status: homeState.status,
                  isEmpty: homeState.groupedRoomsWithPricing.isEmpty,
                  groupedRoomsWithPricing: homeState.groupedRoomsWithPricing,
                  enableRefresh: viewMode == MeetingRoomViewMode.list,
                  onRefresh: () =>
                      ref.read(meetingRoomHomeStateProvider.notifier).refresh(),
                ),
              ),
            ],
          );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Material(
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.2),
          child: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: MeetingRoomAppBarTitle(
              title: homeState.city?.name ?? '',
              onTap: () async {
                final selected = await MeetingRoomLocationDialog.show(
                  context,
                  initialCity: homeState.city,
                  groupedCities: homeState.citiesGroupedByRegion,
                  onSelectNearest: () => ref
                      .read(meetingRoomHomeStateProvider.notifier)
                      .resolveNearestCity(),
                );
                if (selected == null || selected == homeState.city) {
                  return;
                }
                await ref
                    .read(meetingRoomHomeStateProvider.notifier)
                    .changeCity(selected);
              },
            ),
            actions: [
              IconButton(
                onPressed: toggleViewMode,
                icon: Icon(viewModeIcon, color: MeetingRoomTheme.primaryBlue),
              ),
            ],
          ),
        ),
      ),
      body: body,
    );
  }
}

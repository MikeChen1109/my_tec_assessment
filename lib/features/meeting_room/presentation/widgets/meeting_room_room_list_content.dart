import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import '../state/meeting_room_home_state.dart';
import '../theme/meeting_room_theme.dart';

class MeetingRoomRoomListContent extends StatelessWidget {
  const MeetingRoomRoomListContent({
    super.key,
    required this.status,
    required this.isEmpty,
    required this.groupedRoomsWithPricing,
    required this.enableRefresh,
    required this.onRefresh,
  });

  final MeetingRoomHomeStatus status;
  final bool isEmpty;
  final Map<String, List<MeetingRoomWithPricing>> groupedRoomsWithPricing;
  final bool enableRefresh;
  final Future<void> Function() onRefresh;

  ScrollPhysics get _scrollPhysics {
    if (enableRefresh) {
      return const AlwaysScrollableScrollPhysics();
    } else {
      return const ClampingScrollPhysics();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == MeetingRoomHomeStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isEmpty) {
      final listView = ListView(
        physics: _scrollPhysics,
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.meeting_room_outlined, size: 40, color: Colors.black45),
          SizedBox(height: 12),
          Text(
            "There's no meeting rooms available right now.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      );
      return enableRefresh
          ? RefreshIndicator(onRefresh: onRefresh, child: listView)
          : listView;
    }

    final groupedItems = _GroupedRoomItem.fromGroupedRooms(
      groupedRoomsWithPricing,
    );
    final listView = GroupedListView<_GroupedRoomItem, String>(
      elements: groupedItems,
      physics: _scrollPhysics,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      groupBy: (item) => item.groupName,
      groupSeparatorBuilder: (groupName) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text(
            groupName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MeetingRoomTheme.primaryBlue,
            ),
          ),
        );
      },
      itemBuilder: (context, item) {
        final model = _RoomListItemModel.fromRoomWithPricing(
          groupName: item.groupName,
          data: item.data,
        );
        return _RoomListItemCard(item: model);
      },
      order: GroupedListOrder.ASC,
    );
    return enableRefresh
        ? RefreshIndicator(onRefresh: onRefresh, child: listView)
        : listView;
  }
}

class _RoomListItemModel {
  const _RoomListItemModel({
    required this.buildingName,
    required this.roomName,
    required this.seatsLabel,
    required this.priceLabel,
    required this.photoUrl,
    required this.isEnquiryOnly,
  });

  final String buildingName;
  final String roomName;
  final String seatsLabel;
  final String priceLabel;
  final String? photoUrl;
  final bool isEnquiryOnly;

  factory _RoomListItemModel.fromRoomWithPricing({
    required String groupName,
    required MeetingRoomWithPricing data,
  }) {
    final room = data.room;
    final roomName = _buildRoomName(room.floor, room.roomName);
    final priceLabel = _formatPrice(data.finalPrice, data.currencyCode);
    final photoUrl = room.photoUrls.isEmpty ? null : room.photoUrls.first;
    return _RoomListItemModel(
      buildingName: groupName,
      roomName: roomName,
      seatsLabel: '${room.capacity} Seats',
      priceLabel: priceLabel,
      photoUrl: photoUrl,
      isEnquiryOnly: !room.isBookable,
    );
  }

  static String _buildRoomName(String floor, String roomName) {
    final trimmedFloor = floor.trim();
    final trimmedRoom = roomName.trim();
    if (trimmedFloor.isEmpty) {
      return trimmedRoom;
    }
    if (trimmedRoom.isEmpty) {
      return trimmedFloor;
    }
    return '$trimmedFloor, $trimmedRoom';
  }

  static String _formatPrice(num? price, String? currencyCode) {
    final trimmedCurrency = currencyCode?.trim();
    if (price == null || trimmedCurrency == null || trimmedCurrency.isEmpty) {
      return '--';
    }
    final amount = price % 1 == 0
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2);
    final formattedAmount = _formatNumberWithCommas(amount);
    return '$trimmedCurrency $formattedAmount';
  }

  static String _formatNumberWithCommas(String amount) {
    final parts = amount.split('.');
    final integerPart = parts.first.replaceAll(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      ',',
    );
    if (parts.length == 1) {
      return integerPart;
    }
    return '$integerPart.${parts[1]}';
  }
}

class _RoomListItemCard extends StatelessWidget {
  const _RoomListItemCard({required this.item});

  final _RoomListItemModel item;

  @override
  Widget build(BuildContext context) {
    const cardRadius = 16.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _RoomImage(photoUrl: item.photoUrl),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.roomName,
                  style: const TextStyle(
                    color: MeetingRoomTheme.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        item.buildingName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      item.seatsLabel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item.priceLabel,
                      style: const TextStyle(
                        color: MeetingRoomTheme.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomImage extends StatelessWidget {
  const _RoomImage({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = photoUrl?.trim();
    if (trimmedUrl == null || trimmedUrl.isEmpty) {
      return const _RoomImagePlaceholder();
    }
    return Image.network(
      trimmedUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const _RoomImagePlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return const _RoomImagePlaceholder();
      },
    );
  }
}

class _RoomImagePlaceholder extends StatelessWidget {
  const _RoomImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.meeting_room_outlined,
          color: Colors.white70,
          size: 40,
        ),
      ),
    );
  }
}

class _GroupedRoomItem {
  const _GroupedRoomItem({required this.groupName, required this.data});

  final String groupName;
  final MeetingRoomWithPricing data;

  static List<_GroupedRoomItem> fromGroupedRooms(
    Map<String, List<MeetingRoomWithPricing>> groupedRooms,
  ) {
    if (groupedRooms.isEmpty) {
      return const [];
    }
    final groupNames = groupedRooms.keys.toList()..sort();
    final items = <_GroupedRoomItem>[];
    for (final groupName in groupNames) {
      final rooms = groupedRooms[groupName] ?? const [];
      rooms.sort((a, b) => a.room.roomName.compareTo(b.room.roomName));
      for (final room in rooms) {
        items.add(_GroupedRoomItem(groupName: groupName, data: room));
      }
    }
    return items;
  }
}

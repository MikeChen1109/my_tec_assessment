import 'package:flutter/material.dart';
import '../../domain/entities/city.dart';
import '../theme/meeting_room_theme.dart';

class MeetingRoomLocationDialog {
  const MeetingRoomLocationDialog._();

  static Future<City?> show(
    BuildContext context, {
    required City? initialCity,
    required Map<String, List<City>> groupedCities,
    required Future<City?> Function() onSelectNearest,
  }) {
    return showDialog<City>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _MeetingRoomLocationDialogContent(
          initialCity: initialCity,
          groupedCities: groupedCities,
          onSelectNearest: onSelectNearest,
        );
      },
    );
  }
}

class _MeetingRoomLocationDialogContent extends StatefulWidget {
  const _MeetingRoomLocationDialogContent({
    required this.initialCity,
    required this.groupedCities,
    required this.onSelectNearest,
  });

  final City? initialCity;
  final Map<String, List<City>> groupedCities;
  final Future<City?> Function() onSelectNearest;

  @override
  State<_MeetingRoomLocationDialogContent> createState() =>
      _MeetingRoomLocationDialogContentState();
}

class _MeetingRoomLocationDialogContentState
    extends State<_MeetingRoomLocationDialogContent> {
  late City? _selectedCity;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isLocating = false;
  bool _isDropdownOpen = false;
  bool _hasUserTyped = false;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.initialCity;
    _searchController = TextEditingController(
      text: widget.initialCity?.name ?? '',
    );
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        _closeDropdown();
      } else {
        _openDropdown();
      }
    });
  }

  Future<void> _handleSelectNearest() async {
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
    });
    final nearest = await widget.onSelectNearest();
    if (!mounted) return;
    setState(() {
      _isLocating = false;
      if (nearest != null) {
        _selectedCity = nearest;
        _searchController.text = nearest.name;
        _hasUserTyped = false;
        _isDropdownOpen = false;
      }
    });
    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Map<String, List<City>> _filteredGroupedCities(String query) {
    final entries = widget.groupedCities.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (!_hasUserTyped) {
      return {for (final entry in entries) entry.key: entry.value};
    }
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      return {for (final entry in entries) entry.key: entry.value};
    }
    final filtered = <String, List<City>>{};
    for (final entry in entries) {
      final matches = entry.value
          .where((city) => city.name.toLowerCase().contains(trimmedQuery))
          .toList();
      if (matches.isNotEmpty) {
        filtered[entry.key] = matches;
      }
    }
    return filtered;
  }

  void _selectCity(City city) {
    setState(() {
      _selectedCity = city;
      _searchController.text = city.name;
      _hasUserTyped = false;
      _isDropdownOpen = false;
    });
    _searchFocusNode.unfocus();
  }

  void _openDropdown() {
    if (_isDropdownOpen) return;
    setState(() {
      _isDropdownOpen = true;
    });
  }

  void _closeDropdown() {
    if (!_isDropdownOpen) return;
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedCities = _filteredGroupedCities(_searchController.text);
    final canSave = _selectedCity != null;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Location',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MeetingRoomTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please select your city',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: MeetingRoomTheme.primaryBlue.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onTap: _openDropdown,
                  onChanged: (_) {
                    if (!_hasUserTyped) {
                      _hasUserTyped = true;
                    }
                    _openDropdown();
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Search city',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: MeetingRoomTheme.borderGrey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: MeetingRoomTheme.borderGrey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(
                        color: MeetingRoomTheme.primaryBlue,
                      ),
                    ),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ),
                if (_isDropdownOpen) ...[
                  Container(
                    clipBehavior: Clip.hardEdge,
                    constraints: const BoxConstraints(maxHeight: 140),
                    decoration: BoxDecoration(
                      border: Border.all(color: MeetingRoomTheme.borderGrey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: groupedCities.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'No cities found',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: MeetingRoomTheme.primaryBlue.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          )
                        : ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: [
                              for (final entry in groupedCities.entries) ...[
                                _RegionHeader(title: entry.key),
                                for (final city in entry.value)
                                  _CityRow(
                                    name: city.name,
                                    isSelected:
                                        _selectedCity?.code == city.code,
                                    onTap: () => _selectCity(city),
                                  ),
                              ],
                            ],
                          ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleSelectNearest,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: MeetingRoomTheme.borderGrey,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      foregroundColor: MeetingRoomTheme.primaryBlue,
                    ),
                    icon: _isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.near_me_outlined),
                    label: Text(
                      _isLocating ? 'Locating...' : 'Select Nearest City',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canSave
                        ? () => Navigator.of(context).pop(_selectedCity)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: MeetingRoomTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              color: MeetingRoomTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionHeader extends StatelessWidget {
  const _RegionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: MeetingRoomTheme.lightBlueSurface,
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: MeetingRoomTheme.primaryBlue,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _CityRow extends StatelessWidget {
  const _CityRow({
    required this.name,
    required this.onTap,
    required this.isSelected,
  });

  final String name;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? MeetingRoomTheme.selectedRowSurface
              : Colors.transparent,
        ),
        child: Text(
          name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: MeetingRoomTheme.primaryBlue,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// lib/providers/lab_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shadow_app/models/labs.dart';
import '../models/shadow_pair.dart'; // Needed for the updatedShadows list

// --- VIEW MODE STATE (All vs Focus) ---
enum ViewMode { all, focus }

class ViewModeNotifier extends Notifier<ViewMode> {
  @override
  ViewMode build() => ViewMode.all;

  void setMode(ViewMode mode) => state = mode;

  void toggle() =>
      state = state == ViewMode.all ? ViewMode.focus : ViewMode.all;
}

final viewModeProvider = NotifierProvider<ViewModeNotifier, ViewMode>(
  () => ViewModeNotifier(),
);

// --- GLOBAL OVERRIDE STATE ---
class GlobalOverrideNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Starts OFF by default

  void toggle() => state = !state;
}

final globalOverrideProvider = NotifierProvider<GlobalOverrideNotifier, bool>(
  () => GlobalOverrideNotifier(),
);

// --- ACTIVE LAB STATE ---
class ActiveLabNotifier extends Notifier<String?> {
  @override
  String? build() {
    // Automatically select the first lab on app startup if one exists
    final box = Hive.box<Lab>('labs_box');
    if (box.isNotEmpty) {
      final sortedLabs = box.values.toList()
        ..sort((a, b) => a.isPinned == b.isPinned ? 0 : (a.isPinned ? -1 : 1));
      return sortedLabs.first.id;
    }
    return null;
  }

  void setLab(String? labId) => state = labId;
}

final activeLabIdProvider = NotifierProvider<ActiveLabNotifier, String?>(
  () => ActiveLabNotifier(),
);

// --- THE MASTER LAB WORKSPACE PROVIDER ---
class LabListNotifier extends Notifier<List<Lab>> {
  late final Box<Lab> _box;

  @override
  List<Lab> build() {
    _box = Hive.box<Lab>('labs_box');

    // --- THE SMART DEFAULT LAB CHECK ---
    if (_box.isEmpty) {
      final defaultLab = Lab(
        id: 'lab_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Default Lab',
      );
      _box.put(defaultLab.id, defaultLab);
    }

    // --- NEW: Ensure a hidden Global Profile exists to store global colors! ---
    if (!_box.containsKey('GLOBAL_PROFILE')) {
      _box.put(
        'GLOBAL_PROFILE',
        Lab(id: 'GLOBAL_PROFILE', name: 'Global Profile'),
      );
    }

    return _getSortedLabs();
  }

  // --- NEW: Helper to safely fetch the global profile ---
  Lab? getGlobalProfile() => _box.get('GLOBAL_PROFILE');

  List<Lab> _getSortedLabs() {
    // --- NEW: Filter out the hidden GLOBAL_PROFILE so it doesn't show in the UI list! ---
    final labs = _box.values.where((l) => l.id != 'GLOBAL_PROFILE').toList();
    labs.sort((a, b) => a.isPinned == b.isPinned ? 0 : (a.isPinned ? -1 : 1));
    return labs;
  }

  // --- CRUD OPERATIONS ---
  void createLab(String name) {
    final newLab = Lab(
      id: 'lab_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
    );
    _box.put(newLab.id, newLab);
    state = _getSortedLabs();

    // Automatically switch to the newly created lab!
    ref.read(activeLabIdProvider.notifier).setLab(newLab.id);
  }

  void deleteLab(String labId) {
    _box.delete(labId);
    state = _getSortedLabs();
  }

  void togglePin(String labId) {
    final lab = _box.get(labId);
    if (lab != null) {
      final updated = lab.copyWith(isPinned: !lab.isPinned);
      _box.put(labId, updated);
      state = _getSortedLabs();
    }
  }

  // --- WORKSPACE COLOR CUSTOMIZATION ---
  // Mode-aware color updating to completely isolate light and dark setups
  void updateWorkspaceColors(
    String labId, {
    required bool isDarkMode,
    int? bg,
    int? card,
    int? mText,
    int? sText,
    int? slc,
  }) {
    final lab = _box.get(labId);
    if (lab == null) return;

    final updated = isDarkMode
        ? lab.copyWith(
            darkBgColor: bg != null ? () => bg : null,
            darkCardColor: card != null ? () => card : null,
            darkMainTextColor: mText != null ? () => mText : null,
            darkSubTextColor: sText != null ? () => sText : null,
            darkSlcColor: slc != null ? () => slc : null,
          )
        : lab.copyWith(
            lightBgColor: bg != null ? () => bg : null,
            lightCardColor: card != null ? () => card : null,
            lightMainTextColor: mText != null ? () => mText : null,
            lightSubTextColor: sText != null ? () => sText : null,
            lightSlcColor: slc != null ? () => slc : null,
          );

    _box.put(labId, updated);
    state = _getSortedLabs();
  }

  // --- FIXED RESET LOGIC ---
  // Explicitly forces configuration fields back to null database states
  void resetWorkspaceColors(String labId, bool isDarkMode) {
    final lab = _box.get(labId);
    if (lab == null) return;

    final updated = isDarkMode
        ? lab.copyWith(
            darkBgColor: () => null,
            darkCardColor: () => null,
            darkMainTextColor: () => null,
            darkSubTextColor: () => null,
            darkSlcColor: () => null,
          )
        : lab.copyWith(
            lightBgColor: () => null,
            lightCardColor: () => null,
            lightMainTextColor: () => null,
            lightSubTextColor: () => null,
            lightSlcColor: () => null,
          );

    _box.put(labId, updated);
    state = _getSortedLabs();
  }

  Lab? getLabById(String id) => _box.get(id);

  void updateLabShadows(String labId, List<ShadowPair> updatedShadows) {
    final lab = _box.get(labId);
    if (lab != null) {
      _box.put(labId, lab.copyWith(shadows: updatedShadows));
      state = _getSortedLabs();
    }
  }
}

final labProvider = NotifierProvider<LabListNotifier, List<Lab>>(
  () => LabListNotifier(),
);

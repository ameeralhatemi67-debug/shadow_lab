// lib/providers/shadow_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shadow_pair.dart';
import 'lab_provider.dart';

// --- UPGRADED THEME PROVIDER (Preserved) ---
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

// --- SHADOW LOGIC CONTROLLER ---
class ShadowController {
  final Ref ref;
  ShadowController(this.ref);

  void addShadowPair(String labId, String tokenName) {
    final labNotifier = ref.read(labProvider.notifier);
    final lab = labNotifier.getLabById(labId);
    if (lab == null) return;

    final newPair = ShadowPair(
      id: tokenName,
      light: ShadowSettings(
        blur: 10,
        distance: 4,
        angle: 45,
        colorValue: 0x33000000,
        size: 0,
        isVisible: true,
      ),
      dark: ShadowSettings(
        blur: 10,
        distance: 4,
        angle: 45,
        colorValue: 0x99000000,
        size: 0,
        isVisible: true,
      ),
      light2: ShadowSettings(
        blur: 0,
        distance: 0,
        angle: 45,
        colorValue: 0x22000000,
        size: 0,
        isVisible: true,
      ),
      dark2: ShadowSettings(
        blur: 0,
        distance: 0,
        angle: 45,
        colorValue: 0x66000000,
        size: 0,
        isVisible: true,
      ),
      isLinked: true,
      mainText: "Text",
      subText: "text",
    );

    // Grab the existing shadows, add the new one, and save the Lab
    final updatedShadows = List<ShadowPair>.from(lab.shadows)..add(newPair);
    labNotifier.updateLabShadows(labId, updatedShadows);
  }

  void updateShadow(
    String labId,
    String shadowId,
    bool isEditingLightMode,
    int layerIndex,
    ShadowSettings newSettings,
  ) {
    final labNotifier = ref.read(labProvider.notifier);
    final lab = labNotifier.getLabById(labId);
    if (lab == null) return;

    // EXACT PRESERVED MATH LOGIC
    final updatedShadows = lab.shadows.map((pair) {
      if (pair.id != shadowId) return pair;

      ShadowPair updatedPair = ShadowPair(
        id: pair.id,
        light: pair.light,
        dark: pair.dark,
        light2: pair.light2,
        dark2: pair.dark2,
        isLinked: pair.isLinked,
        mainText: pair.mainText,
        subText: pair.subText,
      );

      if (isEditingLightMode) {
        if (layerIndex == 1) updatedPair.light = newSettings;
        if (layerIndex == 2) updatedPair.light2 = newSettings;

        if (updatedPair.isLinked) {
          if (layerIndex == 1)
            updatedPair.dark = newSettings.copyWith(
              colorValue: updatedPair.dark.colorValue,
            );
          if (layerIndex == 2)
            updatedPair.dark2 = newSettings.copyWith(
              colorValue: updatedPair.dark2.colorValue,
            );
        }
      } else {
        if (layerIndex == 1) updatedPair.dark = newSettings;
        if (layerIndex == 2) updatedPair.dark2 = newSettings;
        updatedPair.isLinked = false;
      }
      return updatedPair;
    }).toList();

    labNotifier.updateLabShadows(labId, updatedShadows);
  }

  void reLink(String labId, String shadowId, bool currentViewIsLight) {
    final labNotifier = ref.read(labProvider.notifier);
    final lab = labNotifier.getLabById(labId);
    if (lab == null) return;

    // EXACT PRESERVED RELINK LOGIC
    final updatedShadows = lab.shadows.map((pair) {
      if (pair.id != shadowId) return pair;

      ShadowPair updatedPair = ShadowPair(
        id: pair.id,
        light: pair.light,
        dark: pair.dark,
        light2: pair.light2,
        dark2: pair.dark2,
        isLinked: true,
        mainText: pair.mainText,
        subText: pair.subText,
      );

      if (currentViewIsLight) {
        updatedPair.dark = updatedPair.light.copyWith(
          colorValue: updatedPair.dark.colorValue,
        );
        updatedPair.dark2 = updatedPair.light2.copyWith(
          colorValue: updatedPair.dark2.colorValue,
        );
      } else {
        updatedPair.light = updatedPair.dark.copyWith(
          colorValue: updatedPair.light.colorValue,
        );
        updatedPair.light2 = updatedPair.dark2.copyWith(
          colorValue: updatedPair.light2.colorValue,
        );
      }
      return updatedPair;
    }).toList();

    labNotifier.updateLabShadows(labId, updatedShadows);
  }

  void updateText(
    String labId,
    String shadowId,
    String newMainText,
    String newSubText,
  ) {
    final labNotifier = ref.read(labProvider.notifier);
    final lab = labNotifier.getLabById(labId);
    if (lab == null) return;

    final updatedShadows = lab.shadows.map((pair) {
      if (pair.id != shadowId) return pair;
      return ShadowPair(
        id: pair.id,
        light: pair.light,
        dark: pair.dark,
        light2: pair.light2,
        dark2: pair.dark2,
        isLinked: pair.isLinked,
        mainText: newMainText,
        subText: newSubText,
      );
    }).toList();

    labNotifier.updateLabShadows(labId, updatedShadows);
  }
}

// Provide the controller so the UI can use it
final shadowControllerProvider = Provider((ref) => ShadowController(ref));

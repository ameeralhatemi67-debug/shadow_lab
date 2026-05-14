// lib/providers/shadow_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shadow_pair.dart';

// --- UPGRADED THEME PROVIDER ---
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

// --- EXISTING SHADOW PROVIDER ---
class ShadowListNotifier extends Notifier<List<ShadowPair>> {
  @override
  List<ShadowPair> build() {
    return [];
  }

  void addShadowPair(String tokenName) {
    final newPair = ShadowPair(
      id: tokenName,
      // Layer 1 Defaults
      light: ShadowSettings(
        blur: 10,
        distance: 4,
        angle: 45,
        colorValue: 0x33000000,
        size: 0,
        isVisible: true, // NEW: Added size property
      ),
      dark: ShadowSettings(
        blur: 10,
        distance: 4,
        angle: 45,
        colorValue: 0x99000000,
        size: 0,
        isVisible: true, // NEW: Added size property
      ),
      // Layer 2 Defaults
      // FIX: Changed colorValue from 0x00000000 so it actually has opacity!
      light2: ShadowSettings(
        blur: 0,
        distance: 0,
        angle: 45,
        colorValue: 0x22000000, // Roughly 13% opacity black
        size: 0,
        isVisible: true, // NEW: Added size property
      ),
      dark2: ShadowSettings(
        blur: 0,
        distance: 0,
        angle: 45,
        colorValue: 0x66000000, // Roughly 40% opacity black
        size: 0,
        isVisible: true, // NEW: Added size property
      ),
      isLinked: true,
      mainText: "Text",
      subText: "text",
    );

    state = [...state, newPair];
  }

  void updateShadow(
    String id,
    bool isEditingLightMode,
    int layerIndex,
    ShadowSettings newSettings,
  ) {
    state = state.map((pair) {
      if (pair.id != id) return pair;

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
          if (layerIndex == 1) {
            updatedPair.dark = newSettings.copyWith(
              colorValue: updatedPair.dark.colorValue,
            );
          }
          if (layerIndex == 2) {
            updatedPair.dark2 = newSettings.copyWith(
              colorValue: updatedPair.dark2.colorValue,
            );
          }
        }
      } else {
        if (layerIndex == 1) updatedPair.dark = newSettings;
        if (layerIndex == 2) updatedPair.dark2 = newSettings;
        updatedPair.isLinked = false;
      }

      return updatedPair;
    }).toList();
  }

  void reLink(String id, bool currentViewIsLight) {
    state = state.map((pair) {
      if (pair.id != id) return pair;

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
  }

  void updateText(String id, String newMainText, String newSubText) {
    state = state.map((pair) {
      if (pair.id != id) return pair;

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
  }
}

final shadowProvider = NotifierProvider<ShadowListNotifier, List<ShadowPair>>(
  () {
    return ShadowListNotifier();
  },
);

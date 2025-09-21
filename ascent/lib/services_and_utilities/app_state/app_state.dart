import 'package:flutter/foundation.dart';

import 'package:ascent/models/fitness_plan/plan.dart';
import 'package:ascent/models/fitness_profile_model/fitness_profile.dart';
import 'package:ascent/services_and_utilities/local_storage/local_storage_service.dart';
import 'package:ascent/services_and_utilities/exercises/exercise_service.dart';

/// Central application state that persists and exposes the user's
/// FitnessProfile and Plan while providing ChangeNotifier semantics
/// for the widget tree.
class AppState extends ChangeNotifier {
  AppState();

  List<String> _featureOrder = const [];

  FitnessProfile? _profile;
  Plan? _plan;
  bool _initialized = false;
  bool _isLoading = false;

  List<String> get featureOrder => List<String>.unmodifiable(_featureOrder);
  bool get hasFeatureOrder => _featureOrder.isNotEmpty;
  FitnessProfile? get profile => _profile;
  Plan? get plan => _plan;
  bool get hasProfile => _profile != null;
  bool get hasPlan => _plan != null;
  bool get isInitialized => _initialized;
  bool get isLoading => _isLoading;

  /// Loads persisted profile/plan. If a profile exists but no plan,
  /// a new plan is generated from that profile.
  Future<void> initialize() async {
    if (_initialized) return;

    final loadingChanged = _setLoading(true);
    if (loadingChanged) {
      notifyListeners();
    }
    try {
      _featureOrder = await ExerciseService.loadFeatureOrder();
      _profile = hasFeatureOrder
          ? await FitnessProfile.loadFromStorage(_featureOrder)
          : null;
      _plan = await Plan.loadFromStorage();

      if (_plan == null && _profile != null) {
        _plan = Plan.generateFromFitnessProfile(_profile!);
        await _plan!.saveToStorage();
      }

      _initialized = true;
    } finally {
      final loadingReset = _setLoading(false);
      if (loadingReset || _initialized) {
        notifyListeners();
      }
    }
  }

  /// Persist a new profile and optionally regenerate the plan.
  Future<void> setProfile(
    FitnessProfile profile, {
    bool regeneratePlan = true,
  }) async {
    if (_featureOrder.isEmpty) {
      _featureOrder = await ExerciseService.loadFeatureOrder();
    }
    _profile = profile;
    await profile.saveToStorage();

    if (regeneratePlan) {
      await generatePlan();
    } else {
      notifyListeners();
    }
  }

  /// Persist a provided plan instance.
  Future<void> setPlan(Plan plan) async {
    _plan = plan;
    await plan.saveToStorage();
    notifyListeners();
  }

  /// Generate a new plan from the current profile and persist it.
  Future<void> generatePlan() async {
    final profile = _profile;
    if (profile == null) {
      throw StateError('Cannot generate plan without a fitness profile');
    }

    _plan = Plan.generateFromFitnessProfile(profile);
    await _plan!.saveToStorage();
    notifyListeners();
  }

  /// Clear only the persisted plan (retains profile).
  Future<void> clearPlan() async {
    _plan = null;
    await LocalStorageService.deletePlan();
    notifyListeners();
  }

  /// Clear both profile and plan from memory and storage.
  Future<void> clearAll() async {
    _profile = null;
    _plan = null;
    await LocalStorageService.deleteFitnessProfile();
    await LocalStorageService.deletePlan();
    notifyListeners();
  }

  /// Override the current feature order (used when upstream layers provide it).
  void setFeatureOrder(List<String> featureOrder) {
    _featureOrder = List<String>.from(featureOrder);
    notifyListeners();
  }

  bool _setLoading(bool value) {
    if (_isLoading == value) {
      return false;
    }
    _isLoading = value;
    return true;
  }
}

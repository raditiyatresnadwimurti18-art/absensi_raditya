import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/attendance_stats.dart';
import '../../data/models/user_model.dart';
import '../../data/services/api_client.dart';
import '../../data/services/attendance_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/profile_service.dart';

class AppState extends ChangeNotifier {
  AppState()
      : _authService = AuthService(ApiClient()),
        _attendanceService = AttendanceService(ApiClient()),
        _profileService = ProfileService(ApiClient()),
        _locationService = LocationService();

  final AuthService _authService;
  final AttendanceService _attendanceService;
  final ProfileService _profileService;
  final LocationService _locationService;

  SharedPreferences? _prefs;
  String? _token;
  UserModel? _user;
  List<AttendanceModel> _history = [];
  bool _isReady = false;
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.light;
  String? _errorMessage;

  bool get isReady => _isReady;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  ThemeMode get themeMode => _themeMode;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  List<AttendanceModel> get history => List.unmodifiable(_history);
  AttendanceStats get stats => AttendanceStats.fromHistory(_history);

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _token = _prefs?.getString(AppConstants.tokenKey);

    final storedTheme = _prefs?.getString(AppConstants.themeKey);
    _themeMode = storedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    if (isLoggedIn) {
      try {
        await refreshAll();
      } catch (_) {
        await logout(notify: false);
      }
    }

    _isReady = true;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _run(() async {
      final response = await _authService.login(email: email, password: password);
      _token = response.token;
      _user = response.user;
      await _prefs?.setString(AppConstants.tokenKey, response.token);
      await refreshAll();
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String batch,
    required int trainingId,
    required String password,
  }) async {
    await _run(() async {
      final response = await _authService.register(
        name: name,
        email: email,
        batch: batch,
        trainingId: trainingId,
        password: password,
      );
      _token = response.token;
      _user = response.user;
      await _prefs?.setString(AppConstants.tokenKey, response.token);
      await refreshAll();
    });
  }

  Future<void> refreshAll() async {
    if (!isLoggedIn) {
      return;
    }

    final token = _token!;
    _user = await _profileService.fetchProfile(token) ?? _user;
    _history = await _attendanceService.fetchHistory(token);
    notifyListeners();
  }

  Future<void> submitCheckIn() async {
    await _run(() async {
      final token = _requireToken();
      final location = await _locationService.getCurrentLocation();
      await _attendanceService.checkIn(token: token, location: location);
      await refreshAll();
    });
  }

  Future<void> submitCheckOut() async {
    await _run(() async {
      final token = _requireToken();
      final location = await _locationService.getCurrentLocation();
      await _attendanceService.checkOut(token: token, location: location);
      await refreshAll();
    });
  }

  Future<void> deleteAttendance(int id) async {
    await _run(() async {
      await _attendanceService.deleteAttendance(
        token: _requireToken(),
        attendanceId: id,
      );
      await refreshAll();
    });
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    await _run(() async {
      final updatedUser = await _profileService.updateProfile(
        token: _requireToken(),
        name: name,
        email: email,
      );
      _user = updatedUser ?? _user;
    });
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _prefs?.setString(
      AppConstants.themeKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> logout({bool notify = true}) async {
    _token = null;
    _user = null;
    _history = [];
    await _prefs?.remove(AppConstants.tokenKey);
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _requireToken() {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login sudah berakhir.');
    }
    return token;
  }
}

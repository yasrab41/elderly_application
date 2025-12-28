import 'package:flutter/material.dart';

/// Model for individual water intake records
class WaterLog {
  final int? id;
  final String userId;
  final int amount; // in ml
  final DateTime timestamp;

  WaterLog({
    this.id,
    required this.userId,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'],
      userId: map['userId'] ?? '',
      amount: map['amount'] ?? 0,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }
}

/// Model for water reminder preferences
class WaterSettings {
  final String userId;
  final int dailyGoal;
  final int intervalHours; // 1, 2, 3, or 4
  final String startTime; // "08:00"
  final String endTime; // "20:00"
  final bool isEnabled;
  final bool isVibration;
  final String soundType; // "normal" or "loud"

  WaterSettings({
    required this.userId,
    this.dailyGoal = 2000,
    this.intervalHours = 2,
    this.startTime = "08:00",
    this.endTime = "20:00",
    this.isEnabled = true,
    this.isVibration = true,
    this.soundType = "normal",
  });

  /// Essential for Riverpod state updates
  WaterSettings copyWith({
    String? userId,
    int? dailyGoal,
    int? intervalHours,
    String? startTime,
    String? endTime,
    bool? isEnabled,
    bool? isVibration,
    String? soundType,
  }) {
    return WaterSettings(
      userId: userId ?? this.userId,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      intervalHours: intervalHours ?? this.intervalHours,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isEnabled: isEnabled ?? this.isEnabled,
      isVibration: isVibration ?? this.isVibration,
      soundType: soundType ?? this.soundType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dailyGoal': dailyGoal,
      'intervalHours': intervalHours,
      'startTime': startTime,
      'endTime': endTime,
      'isEnabled': isEnabled ? 1 : 0,
      'isVibration': isVibration ? 1 : 0,
      'soundType': soundType,
    };
  }

  factory WaterSettings.fromMap(Map<String, dynamic> map) {
    return WaterSettings(
      userId: map['userId'] ?? '',
      dailyGoal: map['dailyGoal'] ?? 2000,
      intervalHours: map['intervalHours'] ?? 2,
      startTime: map['startTime'] ?? "08:00",
      endTime: map['endTime'] ?? "20:00",
      isEnabled: (map['isEnabled'] ?? 1) == 1,
      isVibration: (map['isVibration'] ?? 1) == 1,
      soundType: map['soundType'] ?? "normal",
    );
  }

  // Helper to get TimeOfDay for UI Widgets
  TimeOfDay get startTOD {
    final parts = startTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  TimeOfDay get endTOD {
    final parts = endTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

/// A wrapper class to hold the entire state of the Water feature.
/// This makes your ConsumerWidget much cleaner.
class WaterState {
  final List<WaterLog> todayLogs;
  final WaterSettings settings;
  final bool isLoading;
  final int currentIntake;

  WaterState({
    required this.todayLogs,
    required this.settings,
    this.isLoading = false,
    this.currentIntake = 0,
  });

  double get progress {
    if (settings.dailyGoal <= 0) return 0.0;
    double p = currentIntake / settings.dailyGoal;
    return p > 1.0 ? 1.0 : p;
  }

  WaterState copyWith({
    List<WaterLog>? todayLogs,
    WaterSettings? settings,
    bool? isLoading,
    int? currentIntake,
  }) {
    return WaterState(
      todayLogs: todayLogs ?? this.todayLogs,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      currentIntake: currentIntake ?? this.currentIntake,
    );
  }
}

import 'package:flutter/material.dart';

class WaterLog {
  final int? id;
  final String userId;
  final int amount;
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

class WaterSettings {
  final String userId;
  final int dailyGoal;
  final int intervalMinutes; // CHANGED FROM HOURS TO MINUTES
  final String startTime;
  final String endTime;
  final bool isEnabled;
  final bool isVibration;
  final String soundType;

  WaterSettings({
    required this.userId,
    this.dailyGoal = 2000,
    this.intervalMinutes = 60, // Default 60 mins (1 hour)
    this.startTime = "08:00",
    this.endTime = "20:00",
    this.isEnabled = true,
    this.isVibration = true,
    this.soundType = "normal",
  });

  WaterSettings copyWith({
    String? userId,
    int? dailyGoal,
    int? intervalMinutes,
    String? startTime,
    String? endTime,
    bool? isEnabled,
    bool? isVibration,
    String? soundType,
  }) {
    return WaterSettings(
      userId: userId ?? this.userId,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
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
      'intervalMinutes': intervalMinutes, // Save minutes
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
      // Handle legacy data or new data
      intervalMinutes: map['intervalMinutes'] ??
          ((map['intervalHours'] != null) ? map['intervalHours'] * 60 : 60),

      startTime: map['startTime'] ?? "08:00",
      endTime: map['endTime'] ?? "20:00",
      isEnabled: (map['isEnabled'] ?? 1) == 1,
      isVibration: (map['isVibration'] ?? 1) == 1,
      soundType: map['soundType'] ?? "normal",
    );
  }

  TimeOfDay get startTOD {
    final parts = startTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  TimeOfDay get endTOD {
    final parts = endTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

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

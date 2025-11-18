// domain/entities/live/live.dart
import 'package:hive/hive.dart';

part 'live.g.dart';

@HiveType(typeId: 50)
class Live extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime scheduledDate; // Data/hora agendada

  @HiveField(4)
  final int goalAmount; // Meta em centavos (ex: 50000 = R$ 500,00)

  @HiveField(5)
  DateTime? startDate; // Quando começou (null se agendada)

  @HiveField(6)
  DateTime? endDate; // Quando terminou

  @HiveField(7)
  int achievedAmount = 0; // Valor já vendido (em centavos)

  Live({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.goalAmount,
    this.startDate,
    this.endDate,
    this.achievedAmount = 0,
  });

  LiveStatus get status {
    if (endDate != null) return LiveStatus.finished;
    if (startDate != null) return LiveStatus.inProgress;
    if (scheduledDate.isAfter(DateTime.now())) return LiveStatus.scheduled;
    return LiveStatus.scheduled;
  }

  bool get goalAchieved => achievedAmount >= goalAmount;

  int get missingAmount => goalAmount > achievedAmount ? goalAmount - achievedAmount : 0;

  String get formattedGoal => (goalAmount / 100).toStringAsFixed(2).replaceAll('.', ',');
  String get formattedAchieved => (achievedAmount / 100).toStringAsFixed(2).replaceAll('.', ',');

  Live copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledDate,
    int? goalAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? achievedAmount,
  }) {
    return Live(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      goalAmount: goalAmount ?? this.goalAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      achievedAmount: achievedAmount ?? this.achievedAmount,
    );
  }
}

enum LiveStatus { scheduled, inProgress, finished }
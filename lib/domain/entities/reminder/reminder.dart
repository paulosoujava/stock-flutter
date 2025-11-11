import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 7) // Use um typeId livre (ex: 7)
class Reminder extends HiveObject {
  @HiveField(0)  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final String createdBy;

  @HiveField(5)
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    required this.content,
    this.isCompleted = false,
    required this.createdBy,
    required this.createdAt,
  });

  Reminder copyWith({
    String? id,
    String? title,
    String? content,
    bool? isCompleted,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isCompleted: isCompleted ?? this.isCompleted,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

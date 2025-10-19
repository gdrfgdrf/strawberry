
import 'package:hive_ce/hive.dart';
import '../hives.dart';

@HiveType(typeId: HiveTypes.userHabitId)
class UserHabit {
  @HiveField(0)
  final String key;
  @HiveField(1)
  final String? value;

  const UserHabit(this.key, this.value);
}
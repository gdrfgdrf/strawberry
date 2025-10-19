import 'package:domain/entity/user_habit_entity.dart';
import 'package:domain/hives.dart';
import 'package:domain/repository/user_habit_repository.dart';
import 'package:hive_ce/hive.dart';

class UserHabitRepositoryImpl extends AbstractUserHabitRepository {
  @override
  Future<void> store(String key, String? value) {
    final box = Hive.box<UserHabit>(HiveBoxes.userHabit);
    return box.put(key, UserHabit(key, value));
  }

  @override
  String? habit(String key) {
    final box = Hive.box<UserHabit>(HiveBoxes.userHabit);
    final habit = box.get(key);
    return habit?.value;
  }
}
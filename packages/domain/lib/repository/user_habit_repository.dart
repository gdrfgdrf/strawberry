
abstract class AbstractUserHabitRepository {
  Future<void> store(String key, String? value);
  String? habit(String key);
}
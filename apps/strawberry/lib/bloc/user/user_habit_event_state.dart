
import 'package:strawberry/bloc/user/user_bloc.dart';

class AttemptGetUserHabitEvent extends UserEvent {
  final String key;

  AttemptGetUserHabitEvent(this.key);
}

class AttemptStoreUserHabitEvent extends UserEvent {
  final String key;
  final String? value;

  AttemptStoreUserHabitEvent(this.key, this.value);
}

class GetUserHabitSuccess extends UserState {
  final String key;
  final String? value;

  GetUserHabitSuccess(this.key, this.value);
}

class StoreUserHabitSuccess extends UserState {
  final String key;
  final String? value;

  StoreUserHabitSuccess(this.key, this.value);
}
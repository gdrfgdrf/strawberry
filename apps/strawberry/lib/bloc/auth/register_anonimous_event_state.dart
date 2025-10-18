
import 'package:domain/entity/anonimous_entity.dart';
import 'package:strawberry/bloc/auth/auth_bloc.dart';

class AttemptRegisterAnonimousEvent extends AuthEvent {
  final String deviceId;

  AttemptRegisterAnonimousEvent({required this.deviceId});
}

class RegisterAnonimousSuccess extends AuthState {
  final AnonimousEntity entity;

  RegisterAnonimousSuccess(this.entity);
}
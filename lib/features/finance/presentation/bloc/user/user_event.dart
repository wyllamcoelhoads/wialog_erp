import 'package:equatable/equatable.dart';
import 'package:wialog_erp/features/finance/domain/entities/user_entity.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {
  final bool includeInactive;
  const LoadUsers({this.includeInactive = false});
  @override
  List<Object?> get props => [includeInactive];
}

class AddUser extends UserEvent {
  final UserEntity user;
  const AddUser(this.user);
  @override
  List<Object?> get props => [user];
}

class UpdateUser extends UserEvent {
  final UserEntity user;
  const UpdateUser(this.user);
  @override
  List<Object?> get props => [user];
}

class DeleteUser extends UserEvent {
  final int id;
  const DeleteUser(this.id);
  @override
  List<Object?> get props => [id];
}

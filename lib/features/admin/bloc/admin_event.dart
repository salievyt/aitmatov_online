part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class AdminLoadRequested extends AdminEvent {
  final String? roleFilter;

  const AdminLoadRequested({this.roleFilter});

  @override
  List<Object?> get props => [roleFilter];
}

import 'package:crumb/modules/home/domain/entities/crumb_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class UserLocationLoaded extends HomeState {
  final Position position;

  UserLocationLoaded({required this.position});

  @override
  List<Object> get props => [position];
}

class HomeLoaded extends HomeState {
  final List<CrumbEntity> crumbs;

  const HomeLoaded(this.crumbs);

  @override
  List<Object> get props => [crumbs];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

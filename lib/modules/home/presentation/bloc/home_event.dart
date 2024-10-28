import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class GetNearbyCrumbsEvent extends HomeEvent {
  final double latitude;
  final double longitude;

  const GetNearbyCrumbsEvent({required this.latitude, required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}

class GetUserLocationEvent extends HomeEvent {}

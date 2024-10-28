import 'package:crumb/modules/home/presentation/bloc/home_event.dart';
import 'package:crumb/modules/home/presentation/bloc/home_state.dart';
import 'package:crumb/modules/location/domain/usecases/get_current_location_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/usecases/get_nearby_crumbs_usecase.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCurrentLocation getCurrentLocation;
  final GetNearbyCrumbsUsecase getNearbyCrumbs;

  HomeBloc({
    required this.getCurrentLocation,
    required this.getNearbyCrumbs,
  }) : super(HomeInitial()) {
    on<GetUserLocationEvent>(_onGetUserLocation);
    on<GetNearbyCrumbsEvent>(_onGetNearbyCrumbs);
  }

  Future<void> _onGetUserLocation(
      GetUserLocationEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      // Obtém a localização atual do usuário
      final Position position = await getCurrentLocation();
      emit(UserLocationLoaded(position: position));

      // Busca os crumbs próximos com a posição obtida
      await _fetchNearbyCrumbs(position, emit);
    } catch (e) {
      emit(HomeError('Erro ao obter a localização: ${e.toString()}'));
    }
  }

  Future<void> _onGetNearbyCrumbs(
      GetNearbyCrumbsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      // Use valores padrão ou obtenha os valores adequados para os parâmetros obrigatórios
      final userPosition = Position(
        latitude: event.latitude,
        longitude: event.longitude,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      // Busca os crumbs próximos com a posição fornecida
      await _fetchNearbyCrumbs(userPosition, emit);
    } catch (e) {
      emit(HomeError('Erro ao carregar os crumbs: ${e.toString()}'));
    }
  }

  /// Método auxiliar para buscar crumbs próximos a partir da posição do usuário
  Future<void> _fetchNearbyCrumbs(
      Position position, Emitter<HomeState> emit) async {
    try {
      final crumbs = await getNearbyCrumbs(position);
      emit(HomeLoaded(crumbs));
    } catch (e) {
      emit(HomeError('Erro ao obter os crumbs: ${e.toString()}'));
    }
  }
}

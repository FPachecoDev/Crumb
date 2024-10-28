// lib/modules/location/domain/usecases/get_current_location.dart
import 'package:geolocator/geolocator.dart';
import '../../data/datasources/location_service_remote_data_source.dart';

class GetCurrentLocation {
  final LocationService locationService;

  GetCurrentLocation(this.locationService);

  Future<Position> call() async {
    return await locationService.getCurrentLocation();
  }
}

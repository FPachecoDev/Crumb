import 'package:crumb/modules/home/domain/entities/crumb_entity.dart';
import 'package:geolocator/geolocator.dart';

abstract class CrumbRepository {
  Future<List<CrumbEntity>> getNearbyCrumbs(Position userPosition);
}

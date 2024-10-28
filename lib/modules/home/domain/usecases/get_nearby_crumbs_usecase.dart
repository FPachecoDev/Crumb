import 'package:crumb/modules/home/domain/entities/crumb_entity.dart';
import 'package:crumb/modules/home/domain/repositories/crumb_repository.dart';
import 'package:geolocator/geolocator.dart';

class GetNearbyCrumbsUsecase {
  final CrumbRepository crumbRepository;

  GetNearbyCrumbsUsecase({required this.crumbRepository});

  Future<List<CrumbEntity>> call(Position position) async {
    // Sua lógica para buscar crumbs próximos
    return await crumbRepository.getNearbyCrumbs(position);
  }
}

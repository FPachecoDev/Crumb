import 'package:crumb/modules/home/domain/entities/crumb_entity.dart';
import 'package:crumb/modules/home/domain/repositories/crumb_repository.dart';
import 'package:geolocator/geolocator.dart';

class GetNearbyCrumbsUsecase {
  final CrumbRepository crumbRepository;

  GetNearbyCrumbsUsecase({required this.crumbRepository});

  Future<List<CrumbEntity>> call(Position position) async {
    // Verifica se a posição é válida
    if (position == null) {
      throw ArgumentError('A posição não pode ser nula.');
    }

    try {
      // Chama o repositório para buscar crumbs próximos
      return await crumbRepository.getNearbyCrumbs(position);
    } catch (e) {
      // Lida com erros que podem ocorrer durante a busca
      throw Exception('Erro ao obter crumbs próximos: $e');
    }
  }
}

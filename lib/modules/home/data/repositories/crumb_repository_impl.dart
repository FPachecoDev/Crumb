import 'package:crumb/modules/home/data/datasource/home_remote_data_source.dart';
import 'package:crumb/modules/home/domain/entities/crumb_entity.dart';
import 'package:crumb/modules/home/domain/repositories/crumb_repository.dart';
import 'package:geolocator/geolocator.dart';

class CrumbRepositoryImpl implements CrumbRepository {
  final HomeRemoteDataSource remoteDataSource;

  CrumbRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CrumbEntity>> getNearbyCrumbs(Position userPosition) async {
    return await remoteDataSource.getNearbyCrumbs(userPosition);
  }
}

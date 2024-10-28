import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crumb/modules/auth/data/datasource/auth_remote_data_source.dart';
import 'package:crumb/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:crumb/modules/auth/domain/repositories/auth_repository.dart';
import 'package:crumb/modules/auth/domain/usecases/login_usecase.dart';
import 'package:crumb/modules/auth/domain/usecases/logout_usecase.dart';
import 'package:crumb/modules/auth/domain/usecases/register_usecase.dart';
import 'package:crumb/modules/home/data/datasource/home_remote_data_source.dart';
import 'package:crumb/modules/home/data/repositories/crumb_repository_impl.dart';
import 'package:crumb/modules/home/domain/repositories/crumb_repository.dart';
import 'package:crumb/modules/home/domain/usecases/get_nearby_crumbs_usecase.dart';

import 'package:crumb/modules/location/data/datasources/location_service_remote_data_source.dart';

import 'package:crumb/modules/location/domain/usecases/get_current_location_usecase.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

void init() {
  // Registro do FirebaseFirestore
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Registro do HomeRemoteDataSource
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // Registro do CrumbRepository
  sl.registerLazySingleton<CrumbRepository>(
    () => CrumbRepositoryImpl(remoteDataSource: sl<HomeRemoteDataSource>()),
  );

  // Registro do GetNearbyCrumbsUsecase
  sl.registerLazySingleton<GetNearbyCrumbsUsecase>(
    () => GetNearbyCrumbsUsecase(crumbRepository: sl<CrumbRepository>()),
  );

  // Registro do AuthRemoteDataSource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(),
  );

  // Registro do AuthRepository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  // Registro do LoginUseCase
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(authRepository: sl<AuthRepository>()),
  );

  // Registro do RegisterUseCase
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(authRepository: sl<AuthRepository>()),
  );

  // Registro do LogoutUseCase
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(authRepository: sl<AuthRepository>()),
  );

  // Registro do LocationService
  sl.registerLazySingleton<LocationService>(
    () => LocationService(),
  );

  // Registro do GetCurrentLocation Use Case
  sl.registerLazySingleton<GetCurrentLocation>(
    () => GetCurrentLocation(sl<LocationService>()),
  );
}

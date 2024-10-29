import 'package:crumb/firebase_options.dart';
import 'package:crumb/modules/auth/domain/usecases/logout_usecase.dart';
import 'package:crumb/modules/auth/domain/usecases/register_usecase.dart';
import 'package:crumb/modules/auth/presentation/bloc/auth_event.dart';
import 'package:crumb/modules/home/domain/usecases/get_nearby_crumbs_usecase.dart';
import 'package:crumb/modules/home/presentation/bloc/home_bloc.dart';
import 'package:crumb/modules/location/domain/usecases/get_current_location_usecase.dart';
import 'package:crumb/modules/splashscreen/presentation/bloc/splash_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crumb/injection_container.dart' as di;
import 'modules/auth/presentation/bloc/auth_bloc.dart';
import 'modules/auth/domain/usecases/login_usecase.dart';
import 'modules/auth/presentation/pages/login_page.dart';
import 'modules/auth/presentation/pages/register_page.dart';
import 'modules/splashscreen/presentation/pages/splash_screen_page.dart';
import 'modules/home/presentation/pages/home_screen_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  di.init(); // Inicializa o GetIt com os módulos necessários
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: di.sl<LoginUseCase>(),
            registerUseCase: di.sl<RegisterUseCase>(),
            logoutUseCase: di.sl<LogoutUseCase>(),
          ),
        ),
        Provider<HomeBloc>(
          create: (_) => HomeBloc(
            getCurrentLocation: di.sl<GetCurrentLocation>(),
            getNearbyCrumbs: di.sl<GetNearbyCrumbsUsecase>(),
          ),
        ),
        Provider<SplashBloc>(
          create: (_) => SplashBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'My App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SplashScreenPage(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/home': (context) => HomeScreenPage(),
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
        },
      ),
    );
  }
}

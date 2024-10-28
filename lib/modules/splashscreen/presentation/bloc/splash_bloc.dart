import 'package:bloc/bloc.dart';
import 'package:crumb/modules/splashscreen/presentation/bloc/splash_event.dart';
import 'package:crumb/modules/splashscreen/presentation/bloc/splash_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<CheckLoginStatus>(_onCheckLoginStatus);
  }

  Future<void> _onCheckLoginStatus(
      CheckLoginStatus event, Emitter<SplashState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      emit(SplashLoggedIn());
    } else {
      emit(SplashLoggedOut());
    }
  }
}

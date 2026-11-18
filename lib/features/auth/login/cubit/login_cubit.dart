import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  void login(String email, String password) async {
    emit(LoadingLoginState());
    try {
      var userCredn = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredn.user != null) {
        emit(SuccessLoginState());
      } else {
        emit(FailureLoginState());
      }
    } catch (e) {
      emit(FailureLoginState());
    }
  }
}

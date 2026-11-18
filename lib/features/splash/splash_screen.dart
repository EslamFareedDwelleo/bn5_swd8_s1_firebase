import 'package:bn5_swd8_s1_firebase/core/app_extensions.dart';
import 'package:bn5_swd8_s1_firebase/features/auth/login/cubit/login_cubit.dart';
import 'package:bn5_swd8_s1_firebase/features/auth/login/view/login_screen.dart';
import 'package:bn5_swd8_s1_firebase/features/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  void checkLogin() {
    Future.delayed(Duration(seconds: 2), () {
      context.goOff(
        FirebaseAuth.instance.currentUser == null
            ? BlocProvider(
                create: (context) => LoginCubit(),
                child: LoginScreen(),
              )
            : HomeScreen(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

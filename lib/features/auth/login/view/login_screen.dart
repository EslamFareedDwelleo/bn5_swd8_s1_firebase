import 'package:bn5_swd8_s1_firebase/core/app_extensions.dart';
import 'package:bn5_swd8_s1_firebase/features/auth/login/cubit/login_cubit.dart';
import 'package:bn5_swd8_s1_firebase/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: SingleChildScrollView(
          child: Column(
            spacing: 24,
            children: [
              TextField(controller: emailController),
              TextField(controller: passController),
              BlocConsumer<LoginCubit, LoginState>(
                listener: (context, state) {
                  if (state is FailureLoginState) {
                    context.showErrorMessage("Login Error, Please try again");
                  } else if (state is SuccessLoginState) {
                    context.showSuccessMessage("Login Success");
                    context.goOff(HomeScreen());
                  }
                },
                builder: (context, state) {
                  if (state is LoadingLoginState ||
                      state is SuccessLoginState) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () {
                      context.read<LoginCubit>().login(
                        emailController.text,
                        passController.text,
                      );
                    },
                    child: Text("Login"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patient_management_app/blocs/authentication/authentication_bloc.dart';
import 'package:patient_management_app/blocs/base_state.dart';
import 'package:patient_management_app/utils/toastification.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _textfieldDecoration = const InputDecoration(
    enabledBorder: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(),
    errorBorder: OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return BlocProvider(
      create: (context) => AuthenticationBloc(),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          switch (state.status) {
            case Status.failure:
              ToastificationDialog.showToast(msg: state.message!, context: context, type: ToastificationType.error);

            default:
              null;
          }
        },
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.06),
            child: SizedBox(
              height: height - kToolbarHeight,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("بنك الدواء", style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 25 * 1.5),
                      TextField(controller: _usernameController, decoration: _textfieldDecoration.copyWith(hintText: "اسم المستخدم")),
                      const SizedBox(height: 25),
                      TextField(controller: _passwordController, decoration: _textfieldDecoration.copyWith(hintText: "كلمة المرور")),
                      const SizedBox(height: 25 * 1.5),
                      ElevatedButton(
                        onPressed: () {
                          if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                            context
                                .read<AuthenticationBloc>()
                                .add(LoginEvent(username: _usernameController.text, password: _passwordController.text));
                          } else {
                            ToastificationDialog.showToast(msg: "يرجى ملء جميع الحقول", context: context, type: ToastificationType.error);
                          }
                        },
                        child: Text("تسجيل الدخول", style: Theme.of(context).textTheme.bodyLarge),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

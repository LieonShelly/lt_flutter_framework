import 'package:flutter/material.dart';
import 'package:shop/shop.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/auth/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/login_dark.png',
                package: 'shop',
                fit: BoxFit.cover,
              ),

              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      "Log in with your data that you intered during your registration.",
                    ),
                    const SizedBox(height: defaultPadding),
                    LoginForm(formKey: _formKey),
                    Align(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            passwordRecoveryScreenRoute,
                          );
                        },
                        child: const Text('Forget password'),
                      ),
                    ),
                    SizedBox(
                      height: size.height > 700
                          ? size.height * 0.1
                          : defaultPadding,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          entryPointScreenRoute,
                          ModalRoute.withName(logInScreenRoute),
                        );
                      },
                      child: const Text('Login'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, signUpScreenRoute);
                          },
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

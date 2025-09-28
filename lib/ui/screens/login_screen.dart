import 'package:doto_manager/Data/services/api_caller.dart';
import 'package:doto_manager/Data/utils/urls.dart';
import 'package:doto_manager/ui/screens/forgot_password_verify_email_screen.dart';
import 'package:doto_manager/ui/screens/main_nav_bar_holder_screen.dart';
import 'package:doto_manager/ui/screens/sign_up_screen.dart';
import 'package:doto_manager/ui/widgets/centered_progress_indecator.dart';
import 'package:doto_manager/ui/widgets/screen_background.dart';
import 'package:doto_manager/ui/widgets/snak_bar_message.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String name = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _loginProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 82),
                  Text(
                    'Get Started With',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailTEController,
                    decoration: InputDecoration(hintText: 'Email'),
                    validator: (String? value) {
                      String InputText = value ?? '';
                      if (EmailValidator.validate(InputText) == false) {
                        return 'Enter a valid Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordTEController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: 'Password'),
                    validator: (String? value) {
                      if ((value?.length ?? 0) <= 6) {
                        return 'Password shuld more than 6 letter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Visibility(
                    visible: _loginProgress == false,
                    replacement: CenteredProgressIndecator(),
                    child: FilledButton(
                      onPressed: _onTapLoginButton,
                      child: Icon(Icons.arrow_circle_right_outlined),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: _onTapForgotPasswordButton,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            text: "Don't have an account? ",
                            children: [
                              TextSpan(
                                text: 'Sign up',
                                style: TextStyle(color: Colors.green),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _onTapSignUpButton,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapSignUpButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  void _onTapForgotPasswordButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordVerifyEmailScreen(),
      ),
    );
  }

  void _onTapLoginButton() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      MainNavBarHolderScreen.name,
      (predicate) => false,
    );
  }

  Future<void> _login() async {
    _loginProgress = true;
    setState(() {});
    Map<String, dynamic> requestBody = {
      'email': _emailTEController.text.trim(),
      'password': _passwordTEController.text,
    };
    final ApiResponse response = await ApiCaller.postRequest(
      url: Urls.loginUrl,
      body: requestBody,
    );
    if (response.isSuccess && response.responseData['status'] == 'success') {
      UserModel model = UserModel.fromJson(response.responseData['data']);
      String token = response.responseData['token'];

      await AuthController.saveUserData(model, token);

      await Navigator.pushNamedAndRemoveUntil(
        context,
        MainNavBarHolderScreen.name,
        (predicate) => false,
      );
    } else {
      _loginProgress = false;
      setState(() {});
      showSnackBarMessage(context, response.errorMessage!);
    }
  }

  @override
  void dispose() {
    _emailTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }
}

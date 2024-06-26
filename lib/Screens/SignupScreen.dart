import 'package:ebooks/Screens/NavBottomBar.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/CustomSnackBar.dart';
import '../CustomWidgets/CustomTextField.dart';
import '../Functions/DBandAuth/database.dart';
import '../Functions/DBandAuth/firebaseAuth.dart';
import '../Functions/DBandAuth/sharedPrefs.dart';
import '../Providers/SignProvider.dart';
import 'SigninScreen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);
  static const String id = 'SignupScreen';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => SignProvider(), child: Signup());
  }
}

class Signup extends StatelessWidget {
  Signup({Key? key}) : super(key: key);
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Provider.of<SignProvider>(context).isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome!',
                        style: TextStyle(
                            color: Color(0xff053d5d),
                            fontSize: 50,
                            fontWeight: FontWeight.w700),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(30),
                          child: Image.asset('assets/1.jpg')),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _userName,
                              validator: MultiValidator(
                                  [RequiredValidator(errorText: "Required")]),
                              icon: Icons.person,
                              labelText: 'Username',
                            ),
                            CustomTextField(
                              controller: _email,
                              validator: MultiValidator([
                                RequiredValidator(errorText: "Required"),
                                EmailValidator(
                                    errorText:
                                        "Please enter a valid email address"),
                              ]),
                              icon: Icons.email,
                              labelText: 'Email',
                            ),
                            CustomTextField(
                                icon: Icons.phone,
                                labelText: 'phone number',
                                validator:
                                    RequiredValidator(errorText: 'Required'),
                                controller: _phone),
                            CustomTextField(
                              controller: _password,
                              validator: MultiValidator([
                                RequiredValidator(errorText: "Required"),
                                MinLengthValidator(6,
                                    errorText:
                                        "Password must contain at least 6 characters"),
                                MaxLengthValidator(15,
                                    errorText:
                                        "Password cannot be more 15 characters"),
                                PatternValidator(r'(?=.*?[#?!@$%^&*-])',
                                    errorText:
                                        "Password must have at least one special character"),
                              ]),
                              icon: Icons.lock,
                              labelText: 'Password',
                              obscure: true,
                              prefix: Icons.remove_red_eye_outlined,
                            ),
                          ],
                        ),
                      ),
                      Consumer<SignProvider>(builder: (_, value, child) {
                        return CustomButton(
                            text: 'Sign Up',
                            function: () async {
                              await checkUsersName(_userName.text);
                              await checkEmail(_email.text);

                              ///check user or email is exist or not
                              if (resultOfUserName != 0 && resultOfEmail != 0) {
                                buildSnackBar(context,
                                    'Email and username are not available');
                              } else if (resultOfUserName != 0) {
                                buildSnackBar(
                                    context, 'Username is not available');
                              } else if (resultOfEmail != 0) {
                                buildSnackBar(
                                    context, 'Email is not available');
                              } else if (_formKey.currentState!.validate()) {
                                Provider.of<SignProvider>(context,
                                        listen: false)
                                    .loading();
                                await signUp(_email.text, _password.text);

                                Map<String, dynamic> userInfo = {
                                  'email': _email.text,
                                  'username': _userName.text,
                                  'phone': _phone.text
                                };

                                ///store data in FireStore
                                upLoadProfile(userInfo, _userName.text);
                                await setLoggedInUser(_userName.text);
                                await getLoggedInUser();

                                Navigator.pushReplacementNamed(
                                    context, NavBottomBar.id);
                                Provider.of<SignProvider>(context,
                                        listen: false)
                                    .signed();
                              }
                            });
                      }),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, SigninScreen.id);
                        },
                        child: const Text(
                          "Sign in instead",
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

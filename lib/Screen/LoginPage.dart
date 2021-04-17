import 'package:flutter/material.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:get/get.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Screen/SignupPage.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/UserController.dart';




class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();

  }


  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: h * 0.9,
        padding: EdgeInsets.only(top: h * 0.1, left: w * 0.1, right: w * 0.1),
        child: LoginForm(
            w: w,
            h: h,
        ),
      ),
      persistentFooterButtons: <Widget>[
        Container(
            height: h * 0.05,
            width: w * 1.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Don't Have an Account?"),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => SignupPage()));
                  },
                  child: Text(
                    "  SignUp",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                )
              ],
            ))
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key key,
    @required this.w,
    @required this.h,
  }) : super(key: key);

  final double w;
  final double h;

//
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode usernameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool success;
  String userEmail;
  String password;
//  bool google_login;


  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    final AppUserController _userController = Get.put(AppUserController());
    return SingleChildScrollView(

      child: Container(
        height: widget.h*1.3,
        padding: EdgeInsets.only(bottom: bottom),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                width: widget.w,
                alignment: Alignment.center,
                child: Image.asset('assets/logo.png'),
              ),
              SizedBox(
                height: widget.h * 0.05,
              ),
              TextFormField(
                focusNode: usernameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term) {
                  usernameFocus.unfocus();
                  FocusScope.of(context)
                      .requestFocus(passwordFocus);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "This is required field";
                  }
                  return null;
                },
                controller: _usernameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintText: "username"),
              ),
              SizedBox(
                height: widget.h * 0.03,
              ),
              PasswordFormField(
                controller: _passwordController,
                focus: passwordFocus,
              ),
              Container(
                  padding: EdgeInsets.only(
                      top: widget.h * 0.04, left: widget.w * 0.45),
                  child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Forget Password?",
                        style: TextStyle(color: Colors.blue),
                      ))),
              SizedBox(
                height: widget.h * 0.05,
              ),
              Container(
                padding: EdgeInsets.all(10),
                width: widget.w ,
                height: widget.h * 0.12,
                child: RaisedButton(
                  onPressed: () async {
                    setState(() {
                      userEmail = _usernameController.text;
                      password = _passwordController.text;
                    });
                    if (_formKey.currentState.validate()) {
                      print(userEmail + password);
                      _userController.login(userEmail, password, context);



                    }
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "Log in",
                    style: TextStyle(
                        color: Colors.white, letterSpacing: 2, fontSize: 25),
                  ),
                  color: royalblue,
                  highlightElevation: 0,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focus;

  const PasswordFormField({Key key, @required this.controller,this.focus})
      : assert(controller != null),
        super(key: key);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "This is required field";
        }
        return null;
      },
      focusNode: widget.focus,
      controller: widget.controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        hintText: "password",
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
          child: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
        ),
        focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      ),
      obscureText: !_showPassword,
    );
  }
} //ec
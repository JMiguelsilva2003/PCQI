import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/models/validation_result.dart';
import 'package:pcqi_app/services/request_methods.dart';
import 'package:pcqi_app/utils/validators.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formKeyLogin = GlobalKey<FormState>();
  final TextEditingController inputControllerEmail = TextEditingController();
  final TextEditingController inputControllerPassword = TextEditingController();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  bool passwordVisibility = true; // toggle password visibility
  bool showFormValidationError = false;
  late RequestMethods requestMethods;

  @override
  void initState() {
    super.initState();
    requestMethods = RequestMethods(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text("Entrar", style: AppStyles.textStyleTitulo),

                  // Gap
                  const SizedBox(height: 40),

                  // Form
                  Form(
                    key: formKeyLogin,
                    child: Column(
                      children: [
                        // Email widget
                        buildEmailFormField(),

                        // Gap
                        const SizedBox(height: 15),

                        // Password widget
                        buildPasswordFormField(),

                        // Gap
                        const SizedBox(height: 15),

                        // Login button widget
                        buildLoginButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Go back arrow
          buildGoBackButton(),
        ],
      ),
    );
  }

  Widget buildEmailFormField() => TextFormField(
    controller: inputControllerEmail,
    focusNode: focusNodeEmail,
    autofillHints: [AutofillHints.email],
    keyboardType: TextInputType.emailAddress,
    buildCounter:
        (
          BuildContext context, {
          int? currentLength,
          int? maxLength,
          bool? isFocused,
        }) => null,
    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
    style: AppStyles.textFieldTextStyle,
    decoration: AppStyles.textFieldDecoration(
      "Endereço de e-mail",
    ).copyWith(prefixIcon: Icon(Icons.mail, color: AppColors.cinza)),
    textInputAction: TextInputAction.next,
    validator: (value) {
      ValidationResult emailValidation = Validators.checkEmailField(value);
      if (emailValidation.shouldThrowValidationError &&
          !showFormValidationError) {
        setState(() {
          showFormValidationError = true;
        });
      }
      return emailValidation.message;
    },
    onChanged: onChangedForm,
    onFieldSubmitted: (_) {
      FocusScope.of(context).requestFocus(focusNodePassword);
    },
  );

  Widget buildPasswordFormField() => TextFormField(
    controller: inputControllerPassword,
    focusNode: focusNodePassword,
    obscureText: passwordVisibility,
    autofillHints: [AutofillHints.password],
    keyboardType: TextInputType.visiblePassword,
    buildCounter:
        (
          BuildContext context, {
          int? currentLength,
          int? maxLength,
          bool? isFocused,
        }) => null,
    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
    maxLength: 20,
    decoration: AppStyles.textFieldDecoration('Senha').copyWith(
      prefixIcon: Icon(Icons.lock, color: AppColors.cinza),

      // Exibe/oculta senha
      suffixIcon: IconButton(
        icon: passwordVisibility
            ? Icon(Icons.visibility_off)
            : Icon(Icons.visibility),
        onPressed: () =>
            setState(() => passwordVisibility = !passwordVisibility),
      ),
    ),
    style: AppStyles.textFieldTextStyle,
    textInputAction: TextInputAction.done,
    validator: (value) {
      ValidationResult passwordValidation = Validators.checkPasswordField(
        value,
      );
      if (passwordValidation.shouldThrowValidationError &&
          !showFormValidationError) {
        setState(() {
          showFormValidationError = true;
        });
      }
      return passwordValidation.message;
    },
    onChanged: onChangedForm,
    onFieldSubmitted: (_) {},
  );

  Widget buildLoginButton() => SizedBox(
    width: double.infinity,
    child: LoadingButton(
      type: ButtonType.elevated,
      onPressed: () async {
        if (checkFormFieldValidation(formKeyLogin)) {
          await sendLoginRequest(
            inputControllerEmail.text.trim(),
            inputControllerPassword.text.trim(),
          );
        }
      },
      successDuration: Duration(seconds: 0),
      style: AppStyles.loadingButtonStyle,
      child: Text("Entrar", style: AppStyles.loadingButtonTextStyle),
    ),
  );

  Widget buildGoBackButton() => Align(
    alignment: Alignment.topLeft,
    child: Padding(
      padding: const EdgeInsets.only(top: 35, left: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back_ios_rounded),
      ),
    ),
  );

  bool checkFormFieldValidation(formKey) {
    return formKey.currentState!.validate();
  }

  void onChangedForm(String value) {
    if (showFormValidationError) {
      formKeyLogin.currentState!.validate();
    }
  }

  Future<void> sendLoginRequest(String email, String password) async {
    await requestMethods.login(email, password);
  }
}

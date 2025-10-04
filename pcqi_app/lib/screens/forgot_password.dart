import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/validation_result.dart';
import 'package:pcqi_app/services/request_methods.dart';
import 'package:pcqi_app/utils/validators.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> formKeyPasswordReset = GlobalKey<FormState>();
  final TextEditingController inputControllerEmail = TextEditingController();
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
                  Text("Redefinir senha", style: AppStyles.textStyleTitulo),

                  // Gap
                  const SizedBox(height: 10),

                  // Description
                  Text(
                    "Enviaremos um link de redefinição de senha ao endereço de e-mail",
                    style: AppStyles.textStyleTituloSecundario,
                  ),

                  // Gap
                  const SizedBox(height: 40),

                  Form(
                    key: formKeyPasswordReset,
                    child: Column(
                      children: [
                        buildEmailFormField(),
                        SizedBox(height: 15),
                        buildPasswordResetButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          buildGoBackButton(),
        ],
      ),
    );
  }

  Widget buildEmailFormField() => TextFormField(
    controller: inputControllerEmail,
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
    onFieldSubmitted: (_) {},
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

  Widget buildPasswordResetButton() => SizedBox(
    width: double.infinity,
    child: LoadingButton(
      type: ButtonType.elevated,
      onPressed: () async {
        if (checkFormFieldValidation(formKeyPasswordReset)) {
          await sendPasswordResetRequest(inputControllerEmail.text.trim());
        }
      },
      successDuration: Duration(seconds: 0),
      style: AppStyles.loadingButtonStyle,
      child: Text("Enviar link", style: AppStyles.loadingButtonTextStyle),
    ),
  );

  bool checkFormFieldValidation(formKey) {
    return formKey.currentState!.validate();
  }

  void onChangedForm(String value) {
    if (showFormValidationError) {
      formKeyPasswordReset.currentState!.validate();
    }
  }

  Future<void> sendPasswordResetRequest(String email) async {
    await requestMethods.forgotPasswordRequest(email);
  }
}

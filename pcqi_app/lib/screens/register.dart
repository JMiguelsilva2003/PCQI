import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/services/request_methods.dart';
import 'package:pcqi_app/utils/validators.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> formKeyRegister = GlobalKey<FormState>();
  final TextEditingController inputControllerName = TextEditingController();
  final TextEditingController inputControllerEmail = TextEditingController();
  final TextEditingController inputControllerPassword = TextEditingController();
  final TextEditingController inputControllerPasswordConfirmation =
      TextEditingController();
  final FocusNode focusNodeNome = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodePassword = FocusNode();
  final FocusNode focusNodePasswordConfirmation = FocusNode();
  bool passwordVisibility = true; // toggles password visibility
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
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top gap
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.top + 150,
                      ),

                      // Title
                      Text("Cadastre-se", style: AppStyles.textStyleTitulo),

                      // Gap
                      const SizedBox(height: 40),

                      // Form
                      Form(
                        key: formKeyRegister,
                        child: Column(
                          children: [
                            // Name widget
                            buildNameFormField(),

                            // Gap
                            const SizedBox(height: 15),

                            // Email widget
                            buildEmailFormField(),

                            // Gap
                            const SizedBox(height: 15),

                            // Password widget
                            buildPasswordFormField(),

                            // Gap
                            const SizedBox(height: 15),

                            // Password confirmation widget
                            buildPasswordConfirmationFormField(),

                            // Gap
                            const SizedBox(height: 15),

                            // Register button widget
                            buildRegisterButton(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Go back arrow
          buildGoBackButton(),
        ],
      ),
    );
  }

  Widget buildNameFormField() => TextFormField(
    controller: inputControllerName,
    focusNode: focusNodeNome,
    autofillHints: [AutofillHints.name],
    buildCounter:
        (
          BuildContext context, {
          int? currentLength,
          int? maxLength,
          bool? isFocused,
        }) => null,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ ]+')),
    ],
    maxLength: 80,
    decoration: AppStyles.textFieldDecoration(
      'Nome',
    ).copyWith(prefixIcon: Icon(Icons.person, color: AppColors.cinza)),
    validator: (value) {
      final nameValidation = Validators.checkNameField(value);
      if (nameValidation.shouldThrowValidationError &&
          !showFormValidationError) {
        setState(() {
          showFormValidationError = true;
        });
      }
      return nameValidation.message;
    },
    onChanged: onChangedForm,
    style: AppStyles.textFieldTextStyle,
    textInputAction: TextInputAction.next,
    onFieldSubmitted: (_) {
      FocusScope.of(context).requestFocus(focusNodeEmail);
    },
  );

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
      final emailValidation = Validators.checkEmailField(value);
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
    textInputAction: TextInputAction.next,
    validator: (value) {
      final passwordValidation = Validators.checkPasswordField(value);
      if (passwordValidation.shouldThrowValidationError &&
          !showFormValidationError) {
        setState(() {
          showFormValidationError = true;
        });
      }
      return passwordValidation.message;
    },
    onChanged: onChangedForm,
    onFieldSubmitted: (_) {
      FocusScope.of(context).requestFocus(focusNodePasswordConfirmation);
    },
  );

  Widget buildPasswordConfirmationFormField() => TextFormField(
    controller: inputControllerPasswordConfirmation,
    focusNode: focusNodePasswordConfirmation,
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
    decoration: AppStyles.textFieldDecoration(
      'Confirme sua senha',
    ).copyWith(prefixIcon: Icon(Icons.lock, color: AppColors.cinza)),
    textInputAction: TextInputAction.done,
    style: AppStyles.textFieldTextStyle,
    validator: (value) {
      final passwordConfirmationValidation =
          Validators.checkPasswordConfirmationField(
            value,
            inputControllerPassword.text,
            inputControllerPasswordConfirmation.text,
          );
      if (passwordConfirmationValidation.shouldThrowValidationError &&
          !showFormValidationError) {
        setState(() {
          showFormValidationError = true;
        });
      }
      return passwordConfirmationValidation.message;
    },
    onChanged: onChangedForm,
  );

  Widget buildRegisterButton() => SizedBox(
    width: double.infinity,
    child: LoadingButton(
      type: ButtonType.elevated,
      onPressed: () async {
        if (checkFormValidation(formKeyRegister)) {
          await sendRegisterRequest(
            inputControllerName.text.trim(),
            inputControllerEmail.text.trim(),
            inputControllerPassword.text.trim(),
          );
        }
      },
      successDuration: Duration(milliseconds: 0),
      style: AppStyles.loadingButtonStyle,
      child: Text("Cadastrar", style: AppStyles.loadingButtonTextStyle),
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

  bool checkFormValidation(formKey) {
    return formKey.currentState!.validate();
  }

  void onChangedForm(String value) {
    if (showFormValidationError) {
      formKeyRegister.currentState!.validate();
    }
  }

  Future<void> sendRegisterRequest(
    String name,
    String email,
    String password,
  ) async {
    await requestMethods.register(name, email, password);
  }
}

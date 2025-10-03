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
  final TextEditingController inputControllerSenha = TextEditingController();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodeSenha = FocusNode();
  bool visibilidadeSenha = true; // utilizado para trocar exibir/ocultar a senha
  bool mostrarErroFormInput = false; // exibe o erro de validação de input
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
                  // Título
                  Text("Entrar", style: AppStyles.textStyleTitulo),

                  // Espaço
                  const SizedBox(height: 40),

                  // Formulário
                  Form(
                    key: formKeyLogin,
                    child: Column(
                      children: [
                        // Email widget
                        TextFormField(
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
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          style: AppStyles.textFieldTextStyle,
                          decoration:
                              AppStyles.textFieldDecoration(
                                "Endereço de e-mail",
                              ).copyWith(
                                prefixIcon: Icon(
                                  Icons.mail,
                                  color: AppColors.cinza,
                                ),
                              ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            ValidationResult emailValidation =
                                Validators.checkEmailField(value);
                            if (emailValidation.shouldThrowValidationError &&
                                !mostrarErroFormInput) {
                              setState(() {
                                mostrarErroFormInput = true;
                              });
                            }
                            return emailValidation.message;
                          },
                          onChanged: onChangedForm,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(focusNodeSenha);
                          },
                        ),

                        // Espaço
                        const SizedBox(height: 15),

                        // Widget de senha
                        TextFormField(
                          controller: inputControllerSenha,
                          focusNode: focusNodeSenha,
                          obscureText: visibilidadeSenha,
                          autofillHints: [AutofillHints.password],
                          keyboardType: TextInputType.visiblePassword,
                          buildCounter:
                              (
                                BuildContext context, {
                                int? currentLength,
                                int? maxLength,
                                bool? isFocused,
                              }) => null,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          maxLength: 20,
                          decoration: AppStyles.textFieldDecoration('Senha')
                              .copyWith(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: AppColors.cinza,
                                ),

                                // Exibe/oculta senha
                                suffixIcon: IconButton(
                                  icon: visibilidadeSenha
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                  onPressed: () => setState(
                                    () =>
                                        visibilidadeSenha = !visibilidadeSenha,
                                  ),
                                ),
                              ),
                          style: AppStyles.textFieldTextStyle,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            ValidationResult passwordValidation =
                                Validators.checkPasswordField(value);
                            if (passwordValidation.shouldThrowValidationError &&
                                !mostrarErroFormInput) {
                              setState(() {
                                mostrarErroFormInput = true;
                              });
                            }
                            return passwordValidation.message;
                          },
                          onChanged: onChangedForm,
                          onFieldSubmitted: (_) {},
                        ),

                        // Espaço
                        const SizedBox(height: 15),

                        // Widget do botão de cadastro
                        construirBotaoEntrar(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Seta para voltar à tela anterior
          voltarTelaAnterior(),
        ],
      ),
    );
  }

  // Widget do botão de cadastro
  Widget construirBotaoEntrar() => SizedBox(
    width: double.infinity,
    child: LoadingButton(
      type: ButtonType.elevated,
      onPressed: () async {
        // método para enviar login aqui
        if (verificaCamposValidos(formKeyLogin)) {
          await sendLoginRequest(
            inputControllerEmail.text.trim(),
            inputControllerSenha.text.trim(),
          );
        }
      },
      successDuration: Duration(seconds: 0),
      style: AppStyles.loadingButtonStyle,
      child: Text("Entrar", style: AppStyles.loadingButtonTextStyle),
    ),
  );

  // Widget de seta para voltar à tela anterior
  Widget voltarTelaAnterior() => Align(
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

  // Verifica se todos os campos de texto necessários para o cadastro estão preenchidos
  bool verificaCamposValidos(formKey) {
    return formKey.currentState!.validate();
  }

  void onChangedForm(String value) {
    if (mostrarErroFormInput) {
      formKeyLogin.currentState!.validate();
    }
  }

  Future<void> sendLoginRequest(String email, String password) async {
    await requestMethods.login(email, password);
  }
}

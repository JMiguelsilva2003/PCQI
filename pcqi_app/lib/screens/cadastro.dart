import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/services/request_methods.dart';
import 'package:pcqi_app/utils/validators.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final GlobalKey<FormState> formKeyCadastro = GlobalKey<FormState>();
  final TextEditingController inputControllerNome = TextEditingController();
  final TextEditingController inputControllerEmail = TextEditingController();
  final TextEditingController inputControllerSenha = TextEditingController();
  final TextEditingController inputControllerSenhaConfirmacao =
      TextEditingController();
  final FocusNode focusNodeNome = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodeSenha = FocusNode();
  final FocusNode focusNodeSenhaConfirmacao = FocusNode();
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
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.top + 150,
                      ),
                      // Título
                      Text("Cadastre-se", style: AppStyles.textStyleTitulo),

                      // Espaço
                      const SizedBox(height: 40),

                      // Formulário
                      Form(
                        key: formKeyCadastro,
                        child: Column(
                          children: [
                            // Widget de nome
                            TextFormField(
                              controller: inputControllerNome,
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
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[A-Za-zÀ-ÖØ-öø-ÿ ]+'),
                                ),
                              ],
                              maxLength: 80,
                              decoration: AppStyles.textFieldDecoration('Nome')
                                  .copyWith(
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: AppColors.cinza,
                                    ),
                                  ),
                              validator: (value) {
                                final nameValidation =
                                    Validators.checkNameField(value);
                                if (nameValidation.shouldThrowValidationError &&
                                    !mostrarErroFormInput) {
                                  setState(() {
                                    mostrarErroFormInput = true;
                                  });
                                }
                                return nameValidation.message;
                              },
                              onChanged: onChangedForm,
                              style: AppStyles.textFieldTextStyle,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(focusNodeEmail);
                              },
                            ),

                            // Espaço
                            const SizedBox(height: 15),

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
                                final emailValidation =
                                    Validators.checkEmailField(value);
                                if (emailValidation
                                        .shouldThrowValidationError &&
                                    !mostrarErroFormInput) {
                                  setState(() {
                                    mostrarErroFormInput = true;
                                  });
                                }
                                return emailValidation.message;
                              },
                              onChanged: onChangedForm,
                              onFieldSubmitted: (_) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(focusNodeSenha);
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
                                        () => visibilidadeSenha =
                                            !visibilidadeSenha,
                                      ),
                                    ),
                                  ),
                              style: AppStyles.textFieldTextStyle,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                final passwordValidation =
                                    Validators.checkPasswordField(value);
                                if (passwordValidation
                                        .shouldThrowValidationError &&
                                    !mostrarErroFormInput) {
                                  setState(() {
                                    mostrarErroFormInput = true;
                                  });
                                }
                                return passwordValidation.message;
                              },
                              onChanged: onChangedForm,
                              onFieldSubmitted: (_) {
                                FocusScope.of(
                                  context,
                                ).requestFocus(focusNodeSenhaConfirmacao);
                              },
                            ),

                            // Espaço
                            const SizedBox(height: 15),

                            // Widget de confirmação de senha
                            TextFormField(
                              controller: inputControllerSenhaConfirmacao,
                              focusNode: focusNodeSenhaConfirmacao,
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
                              decoration:
                                  AppStyles.textFieldDecoration(
                                    'Confirme sua senha',
                                  ).copyWith(
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: AppColors.cinza,
                                    ),
                                  ),
                              textInputAction: TextInputAction.done,
                              style: AppStyles.textFieldTextStyle,
                              validator: (value) {
                                final passwordConfirmationValidation =
                                    Validators.checkPasswordConfirmationField(
                                      value,
                                      inputControllerSenha.text,
                                      inputControllerSenhaConfirmacao.text,
                                    );
                                if (passwordConfirmationValidation
                                        .shouldThrowValidationError &&
                                    !mostrarErroFormInput) {
                                  setState(() {
                                    mostrarErroFormInput = true;
                                  });
                                }
                                return passwordConfirmationValidation.message;
                              },
                              onChanged: onChangedForm,
                            ),

                            // Espaço
                            const SizedBox(height: 15),

                            // Widget do botão de cadastro
                            construirBotaoCadastro(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Seta para voltar à tela anterior
          voltarTelaAnterior(),
        ],
      ),
    );
  }

  // Widget do botão de cadastro
  Widget construirBotaoCadastro() => SizedBox(
    width: double.infinity,
    child: LoadingButton(
      type: ButtonType.elevated,
      onPressed: () async {
        // método para enviar cadastro aqui
        if (verificaCamposValidos(formKeyCadastro)) {
          await sendRegisterRequest(
            inputControllerNome.text.trim(),
            inputControllerEmail.text.trim(),
            inputControllerSenha.text.trim(),
          );
        }
      },
      successDuration: Duration(milliseconds: 0),
      style: AppStyles.loadingButtonStyle,
      child: Text("Cadastrar", style: AppStyles.loadingButtonTextStyle),
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
      formKeyCadastro.currentState!.validate();
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

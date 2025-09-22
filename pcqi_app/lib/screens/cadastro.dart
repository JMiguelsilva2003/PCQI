import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/config/app_colors.dart';

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
                              maxLength: 80,
                              decoration: AppStyles.textFieldDecoration('Nome')
                                  .copyWith(
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: AppColors.cinza,
                                    ),
                                  ),
                              validator: verificarCampoNome,
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
                              validator: verificarCampoEmail,
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
                              validator: verificarCampoSenha,
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
                              validator: verificarCampoSenhaConfirmacao,
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
        verificaCamposValidos(formKeyCadastro);
      },
      successDuration: Duration(seconds: 0),
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

  String? verificarCampoNome(String? value) {
    // Verifica se o campo não está vazio
    if (value!.isEmpty) {
      mostrarErroFormInput = true;
      return "O campo não deve estar vazio";
    }
    return null;
  }

  String? verificarCampoEmail(String? value) {
    final pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$';
    final emailRegExp = RegExp(pattern);
    // Verifica se o campo não está vazio
    if (value!.isEmpty) {
      mostrarErroFormInput = true;
      return "O campo não deve estar vazio";
    }
    // Se não está vazio, verifica se o e-mail é válido
    else if (!emailRegExp.hasMatch(value)) {
      mostrarErroFormInput = true;
      return "Insira um endereço de e-mail válido";
    } else {
      return null;
    }
  }

  String? verificarCampoSenha(String? value) {
    // Verifica se o campo não está vazio
    if (value!.isEmpty) {
      mostrarErroFormInput = true;
      return "O campo não pode estar vazio";
    }
    // Verifica se a senha possui ao menos 8 caracteres
    else if (value.length < 8) {
      mostrarErroFormInput = true;
      return "A senha deve possuir ao menos 8 caracteres";
    }
    // Verifica se a senha e a senha de confirmação coincidem
    else if (!senhasCoincidem(
      inputControllerSenha.text,
      inputControllerSenhaConfirmacao.text,
    )) {
      mostrarErroFormInput = true;
      return "As senhas não coincidem";
    } else {
      return null;
    }
  }

  String? verificarCampoSenhaConfirmacao(String? value) {
    // Verifica se o campo não está vazio
    if (value!.isEmpty) {
      mostrarErroFormInput = true;
      return "O campo não deve estar vazio";
    }
    // Verifica se a senha e a senha de confirmação coincidem
    else if (!senhasCoincidem(
      inputControllerSenha.text,
      inputControllerSenhaConfirmacao.text,
    )) {
      return "As senhas não coincidem";
    } else {
      return null;
    }
  }

  bool senhasCoincidem(String senha, String senhaConfirmacao) {
    return senha == senhaConfirmacao;
  }

  // Verifica se todos os campos de texto necessários para o cadastro estão preenchidos
  bool verificaCamposValidos(formKey) {
    return formKey.currentState!.validate();
  }

  void onChangedForm(String value) {
    if (mostrarErroFormInput) {
      formKeyCadastro.currentState!.validate();
    }
  }
}

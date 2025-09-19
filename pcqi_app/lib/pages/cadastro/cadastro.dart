import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:pcqi_app/styles/app_colors.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final GlobalKey<FormState> formKeyCadastro = GlobalKey<FormState>();
  final TextEditingController inputControllerEmail = TextEditingController();
  final TextEditingController inputControllerSenha = TextEditingController();
  final TextEditingController inputControllerSenhaConfirmacao =
      TextEditingController();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodeSenha = FocusNode();
  final FocusNode focusNodeSenhaConfirmacao = FocusNode();
  bool mostrarErroFormInput = false; // exibe o erro de validação de input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
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
                  Text("Cadastre-se"),

                  // Espaço
                  const SizedBox(height: 40),

                  // Formulário
                  Form(
                    key: formKeyCadastro,
                    child: Column(
                      children: [
                        // Widget de email
                        construirEmail(),

                        // Espaço
                        const SizedBox(height: 15),

                        // Widget de senha
                        construirSenha(),

                        // Espaço
                        const SizedBox(height: 15),

                        // Widget de confirmação de senha
                        construirConfirmacaoSenha(),

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
          // Seta para voltar à tela anterior
          voltarTelaAnterior(),
        ],
      ),
    );
  }

  /* ----- Widgets ----- */

  Widget construirEmail() => TextFormField(
    keyboardType: TextInputType.emailAddress,
    autofillHints: [AutofillHints.email],
    maxLength: 50,
    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
    buildCounter:
        (
          BuildContext context, {
          int? currentLength,
          int? maxLength,
          bool? isFocused,
        }) => null,
    controller: inputControllerEmail,
    focusNode: focusNodeEmail,
    textInputAction: TextInputAction.next,
    onFieldSubmitted: (_) {
      FocusScope.of(context).requestFocus(focusNodeSenha);
    },
    validator: (value) {
      return verificarCampoEmail(value);
    },
    onChanged: (value) {
      if (mostrarErroFormInput) {
        formKeyCadastro.currentState!.validate();
      }
    },
  );

  Widget construirSenha() => TextFormField(
    keyboardType: TextInputType.visiblePassword,
    autofillHints: [AutofillHints.password],
    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
    controller: inputControllerSenha,
    focusNode: focusNodeSenha,
    textInputAction: TextInputAction.next,
    maxLength: 20,
    buildCounter:
        (
          BuildContext context, {
          int? currentLength,
          int? maxLength,
          bool? isFocused,
        }) => null,
    onFieldSubmitted: (_) {
      FocusScope.of(context).requestFocus(focusNodeSenhaConfirmacao);
    },
    validator: (value) {
      return verificarCampoSenha(value);
    },
    onChanged: (value) {
      if (mostrarErroFormInput) {
        formKeyCadastro.currentState!.validate();
      }
    },
  );

  Widget construirConfirmacaoSenha() => TextFormField(
    keyboardType: TextInputType.visiblePassword,
    autofillHints: [AutofillHints.password],
    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
    controller: inputControllerSenhaConfirmacao,
    focusNode: focusNodeSenhaConfirmacao,
    textInputAction: TextInputAction.done,
    maxLength: 20,
    buildCounter:
        (
          BuildContext context, {
          int? currentLength,
          int? maxLength,
          bool? isFocused,
        }) => null,
    onFieldSubmitted: (_) {
      ();
    },
    validator: (value) {
      return verificarCampoSenhaConfirmacao(value);
    },
    onChanged: (value) {
      if (mostrarErroFormInput) {
        formKeyCadastro.currentState!.validate();
      }
    },
  );

  Widget construirBotaoCadastro() => SizedBox(
    width: double.infinity,
    child: LoadingButton(
      type: ButtonType.elevated,
      onPressed: () async {
        verificaCamposValidos();
        // (método para enviar cadastro vai aqui)
      },
      successDuration: Duration(seconds: 0),
      child: Text("Cadastrar"),
    ),
  );

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

  /* ----- Métodos para verificar se os campos de texto estão corretamente preenchidos ----- */

  verificarCampoEmail(value) {
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

  verificarCampoSenha(value) {
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

  verificarCampoSenhaConfirmacao(value) {
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
  bool verificaCamposValidos() {
    return formKeyCadastro.currentState!.validate();
  }
}

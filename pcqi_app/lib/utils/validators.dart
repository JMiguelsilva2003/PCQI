import 'package:pcqi_app/models/validation_result.dart';

class Validators {
  /* This class is used for validating text form fields */
  static ValidationResult checkNameField(String? value) {
    final pattern = r'^[A-Za-zÀ-ÖØ-öø-ÿ]+( [A-Za-zÀ-ÖØ-öø-ÿ]+)*$';
    final passwordRegEx = RegExp(pattern);
    // Checks if the field is not empty
    if (value!.trim().isEmpty) {
      return ValidationResult(message: "O campo não deve estar vazio");
    }
    // Checks for extra spaces in between names
    else if (!passwordRegEx.hasMatch(value.trim())) {
      return ValidationResult(message: "Remova espaços extras em seu nome");
    }
    return ValidationResult(shouldThrowValidationError: false, message: null);
  }

  static ValidationResult checkEmailField(String? value) {
    final pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$';
    final emailRegExp = RegExp(pattern);
    // Checks if the field is not empty
    if (value!.isEmpty) {
      return ValidationResult(message: "O campo não deve estar vazio");
    }
    // If it is not empty, checks if the email is valid
    else if (!emailRegExp.hasMatch(value)) {
      return ValidationResult(message: "Insira um endereço de e-mail válido");
    }
    return ValidationResult(shouldThrowValidationError: false, message: null);
  }

  static ValidationResult checkPasswordField(String? value) {
    // Checks if the field is not empty
    if (value!.isEmpty) {
      return ValidationResult(message: "O campo não pode estar vazio");
    }
    // Checks if the password is at least 8 characters long
    else if (value.length < 8) {
      return ValidationResult(
        message: "Sua senha deve possuir ao menos 8 caracteres",
      );
    }
    return ValidationResult(shouldThrowValidationError: false, message: null);
  }

  static ValidationResult checkPasswordConfirmationField(
    String? value,
    String password,
    String confirmationPassword,
  ) {
    // Checks if the field is not empty
    if (value!.isEmpty) {
      return ValidationResult(message: "O campo não deve estar vazio");
    }
    // Checks if the password and password confirmation match
    else if (password != confirmationPassword) {
      return ValidationResult(message: "As senhas não coincidem");
    }
    return ValidationResult(shouldThrowValidationError: false, message: null);
  }

  static ValidationResult checkServerAddressField(String? value) {
    // Checks if the field is not empty
    if (value!.isEmpty) {
      return ValidationResult(message: "O campo não pode estar vazio");
    }
    // Checks if thw fields starts with http:// or https://
    else if (!value.startsWith("http://") && !value.startsWith("https://")) {
      return ValidationResult(
        message: "Deve começar com \"http://\" ou \"https://\"",
      );
    }
    return ValidationResult(shouldThrowValidationError: false, message: null);
  }
}

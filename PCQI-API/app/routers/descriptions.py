REGISTER_USER_DESCRIPTION = """
Cria um novo usuário no banco de dados.

- **Recebe**: um email e uma senha.
- **Retorna**: os dados do usuário criado (sem a senha).
- **Regra**: O email não pode já existir no sistema.
"""

LOGIN_TOKEN_DESCRIPTION = """
Verifica as credenciais do usuário. Se estiverem corretas, gera e retorna um token de acesso (JWT) para ser usado em futuras requisições a rotas protegidas.

- **Recebe**: um formulário com `username` (que é o email) e `password`.
- **Retorna**: um `access_token` e o `token_type`.
- **Como usar**: O frontend deve salvar este token e enviá-lo no cabeçalho `Authorization` de requisições futuras (ex: `Authorization: Bearer <token>`).
"""
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

# --- Descrições para o Módulo de Máquinas

CREATE_MACHINE_DESCRIPTION = """
Cria uma nova máquina para o usuário atualmente autenticado.

- **Segurança**: Rota protegida. Requer um token JWT válido.
- **Recebe**: O nome da nova máquina.
- **Retorna**: Os detalhes da máquina recém-criada.
"""

READ_USER_MACHINES_DESCRIPTION = """
Retorna uma lista de todas as máquinas pertencentes ao usuário autenticado.

- **Segurança**: Rota protegida. Requer um token JWT válido.
- **Retorna**: Uma lista contendo os detalhes de cada máquina do usuário.
"""

READ_SPECIFIC_MACHINE_DESCRIPTION = """
Retorna os detalhes de uma máquina específica pelo seu ID.

- **Segurança**: Rota protegida. Requer um token JWT válido.
- A API verifica se a máquina solicitada pertence de fato ao usuário autenticado antes de retornar os dados, prevenindo que um usuário acesse os dados de outro.
"""
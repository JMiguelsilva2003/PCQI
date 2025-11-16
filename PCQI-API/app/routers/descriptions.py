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

CREATE_MACHINE_DESCRIPTION = """
Cria uma nova máquina e a associa a um setor específico.

- **Segurança**: Rota protegida. O usuário deve ser membro do setor informado.
- **Recebe**: O nome da nova máquina e o ID do setor.
- **Retorna**: Os detalhes da máquina recém-criada.
"""

READ_USER_MACHINES_DESCRIPTION = """
Retorna uma lista de todas as máquinas de todos os setores dos quais o usuário é membro.

- **Segurança**: Rota protegida. Requer um token JWT válido.
- **Retorna**: Uma lista contendo os detalhes de cada máquina.
"""

READ_SPECIFIC_MACHINE_DESCRIPTION = """
Retorna os detalhes de uma máquina específica pelo seu ID.

- **Segurança**: Rota protegida. Requer um token JWT válido.
- A API verifica se o usuário é membro do setor ao qual a máquina pertence antes de retornar os dados.
"""

UPDATE_MACHINE_DESCRIPTION = """
Atualiza o nome de uma máquina existente.

- **Segurança**: Rota protegida por login (JWT).
- Apenas o **criador** da máquina ou um **admin** pode realizar esta operação.
"""

HEARTBEAT_DESCRIPTION = """
Usado pelo 'gateway_hardware.py' para reportar que a máquina está online.

- **Segurança**: Rota protegida por **X-API-Key**.
- Atualiza o campo 'last_heartbeat' da máquina no banco de dados.
"""
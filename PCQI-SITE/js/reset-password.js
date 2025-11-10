document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('formResetPassword');
    const submitButton = form.querySelector('.submit-btn');
    const tituloDiv = document.getElementById('titulo');
    const mensagemDiv = document.getElementById('mensagem');

    const params = new URLSearchParams(window.location.search);
    const token = params.get('token');

    if (!token) {
        tituloDiv.textContent = 'Erro de Verificação';
        mensagemDiv.textContent = 'Token inválido ou ausente. Por favor, solicite um novo link.';
        mensagemDiv.className = 'mensagem erro';
        submitButton.disabled = true;
        return;
    }

    const showButtonLoader = (button) => {
        button.disabled = true;
        button.classList.add('loading');
    };
    const hideButtonLoader = (button) => {
        button.disabled = false;
        button.classList.remove('loading');
    };

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        showButtonLoader(submitButton);

        const newPassword = document.getElementById('newPassword').value;
        const confirmNewPassword = document.getElementById('confirmNewPassword').value;

        if (newPassword !== confirmNewPassword) {
            mensagemDiv.textContent = 'As novas senhas não coincidem!';
            mensagemDiv.className = 'mensagem erro';
            hideButtonLoader(submitButton);
            return;
        }

        try {
            const result = await resetPassword(token, newPassword);
            
            tituloDiv.textContent = 'Sucesso!';
            mensagemDiv.textContent = result.message;
            mensagemDiv.className = 'mensagem sucesso';

            submitButton.disabled = true;
            setTimeout(() => {
                window.location.href = '/screens/index.html';
            }, 3000);

        } catch (error) {
            tituloDiv.textContent = 'Falha na Redefinição';
            mensagemDiv.textContent = error.message;
            mensagemDiv.className = 'mensagem erro';
        } finally {
            hideButtonLoader(submitButton);
        }
    });
});
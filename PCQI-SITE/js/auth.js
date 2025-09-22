document.addEventListener('DOMContentLoaded', async () => {
    await Promise.all([
        loadHTML('../components/loginForm.html', 'login-container'),
        loadHTML('../components/registerForm.html', 'register-container'),
        loadHTML('../components/pager.html', 'pager-container')
    ]);

    const pager = document.getElementById('pager');
    const pagerBtn = document.getElementById('pagerBtn');
    const pagerTitulo = document.getElementById('pagerTitulo');
    const formLogin = document.getElementById('formLogin');
    const formCadastro = document.getElementById('formCadastro');
    const botoesVisualizar = document.querySelectorAll('.eye-button');

    const showButtonLoader = (button) => {
        button.disabled = true;
        button.classList.add('loading');
    };
    const hideButtonLoader = (button) => {
        button.disabled = false;
        button.classList.remove('loading');
    };

    const trocarMetodo = () => {
        pager.classList.toggle('cadastro');
        if (pager.classList.contains('cadastro')) {
            pagerTitulo.textContent = 'Já possui uma conta?';
            pagerBtn.textContent = 'Faça login agora!';
        } else {
            pagerTitulo.textContent = 'Ainda não tem uma conta?';
            pagerBtn.textContent = 'Crie uma conta agora!';
        }
    };

    botoesVisualizar.forEach(botao => {
        const campoSenha = botao.previousElementSibling;
        const icon = botao.querySelector('i');

        botao.addEventListener('click', function() {
            if (campoSenha.type === 'password') {
            campoSenha.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
            } else {
            campoSenha.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
            }
        });
    });

    pagerBtn.addEventListener('click', trocarMetodo);

    formCadastro.addEventListener('submit', async (e) => {
        e.preventDefault();
        const submitButton = formCadastro.querySelector('.submit-btn');
        showButtonLoader(submitButton);
        
        const nome = document.getElementById('nomeCadastro').value;
        const email = document.getElementById('emailCadastro').value;
        const senha = document.getElementById('senhaCadastro').value;
        const confirmSenha = document.getElementById('confirmSenhaCadastro').value;

        if (senha !== confirmSenha) {
            showNotification('As senhas não coincidem!', true);
            hideButtonLoader(submitButton);
            return;
        }

        try {
            await registerUser(nome, email, senha);
            showNotification('Cadastro realizado com sucesso! Verifique seu email.');
            trocarMetodo();
            formCadastro.reset();
        } catch (error) {
            showNotification(error.message, true);
        } finally {
            hideButtonLoader(submitButton);
        }
    });

    formLogin.addEventListener('submit', async (e) => {
        e.preventDefault();
        const submitButton = formLogin.querySelector('.submit-btn');
        showButtonLoader(submitButton);

        const email = document.getElementById('emailLogin').value;
        const senha = document.getElementById('senhaLogin').value;

        try {
            const data = await loginUser(email, senha);
            showNotification('Login realizado com sucesso!');
            localStorage.setItem('accessToken', data.access_token);
            localStorage.setItem('refreshToken', data.refresh_token);
            window.location.href = '/dashboard.html';
        } catch (error) {
            showNotification(error.message, true);
        } finally {
            hideButtonLoader(submitButton);
        }
    });
});
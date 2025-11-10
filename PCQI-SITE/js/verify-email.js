window.onload = async () => {
    const tituloDiv = document.getElementById('titulo');
    const mensagemDiv = document.getElementById('mensagem');

    const params = new URLSearchParams(window.location.search);
    const token = params.get('token');

    if (!token) {
        tituloDiv.textContent = 'Erro!';
        mensagemDiv.textContent = 'Nenhum token de verificação encontrado. Por favor, tente novamente.';
        mensagemDiv.className = 'mensagem erro';
        return;
    }

    try {
        const resultado = await verifyEmailToken(token);

        tituloDiv.textContent = 'Email Verificado!';
        mensagemDiv.textContent = resultado.message;
        mensagemDiv.className = 'mensagem sucesso';
        
        const linkLogin = document.createElement('a');
        linkLogin.href = '/screens/index.html';
        linkLogin.textContent = 'Ir para o Login';
        linkLogin.className = 'link-login';
        mensagemDiv.after(linkLogin);

    } catch (error) {
        tituloDiv.textContent = 'Falha na Verificação';
        mensagemDiv.textContent = error.message;
        mensagemDiv.className = 'mensagem erro';
    }
};
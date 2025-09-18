// Primeiro, a gente pega o formulario do nosso HTML usando o id
const form = document.getElementById('formCadastro');

/* Padronizar os headers para requisicao da API
const header = new Headers();
header.append("Content-Type", "application/json");
*/

// Depois, a gente adiciona um ouvinte para o evento 'submit'
form.addEventListener('submit', async function(event) {
    // cancela o tratamento padrao do evento
    event.preventDefault();

    // pega os dados do formulario
    const nome = document.getElementById('nome').value;
    const senha = document.getElementById('senha').value;

    // Validação simples
    if (!nome || !senha) {
      mostrarNotificacao("Preencha todos os campos!");
      return;
    }

    // prepara os dados para envio
    const data = {
        nome : nome,
        senha : senha
    }
    const JSONdata = JSON.stringify(data);
    
    try {
        // monta e faz a requisicao
        const response = await fetch("<url da requisicao>", {
            method: "POST",
            headers: { "Content-Type": "application/json" }, // aqui mudaria para header se fosse padronizado
            body: JSONdata
        });

        // pega a resposta da API em json
        const APIresponse = await response.json();
        if (response.ok) {
            // pega e salva o token no localstorage
            const token = APIresponse.token;
            localStorage.setItem("authentication-token", token)
            
            // redireciona
            window.location.href = 'index.html';
        } else {
            // mensagem de erro
            mostrarNotificacao(APIresponse.message || "Erro no cadastro. Tente novamente.");
        }
    } catch (error) {
      mostrarNotificacao("Erro de conexão com o servidor.");
      console.error("Erro de rede:", error);
    }

});

function mostrarNotificacao(mensagem, sucesso = false) {
    notificacao.textContent = mensagem;
    notificacao.style.color = sucesso ? "green" : "red";
    notificacao.style.display = "block";
}
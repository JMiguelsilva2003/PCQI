// Primeiro, a gente pega o formulario do nosso HTML usando o id
const form = document.getElementById("formCadastro");

/* Padronizar os headers para requisicao da API
const header = new Headers();
header.append("Content-Type", "application/json");
*/

// Depois, a gente adiciona um ouvinte para o evento 'submit'
form.addEventListener("submit", async function (event) {
  // cancela o tratamento padrao do evento
  event.preventDefault();

  // pega os dados do formulario
  const nome = document.getElementById("nomeCadastro").value;
  const senha = document.getElementById("senhaCadastro").value;

  // Validação simples
  if (!nome || !senha) {
    mostrarNotificacao("Preencha todos os campos!");
    return;
  }

  // prepara os dados para envio
  const data = {
    nome: nome,
    senha: senha,
  };
  const JSONdata = JSON.stringify(data);

  try {
    // monta e faz a requisicao
    const response = await fetch("https://jsonplaceholder.typicode.com/posts", {
      method: "POST",
      headers: { "Content-Type": "application/json" }, // aqui mudaria para header se fosse padronizado
      body: JSONdata,
    });

    // pega a resposta da API em json
    const APIresponse = await response.json();
    if (response.ok) {
      // popa notificacao de sucesso
      // mostrarNotificacao(APIresponse.message, true);
      trocarMetodo();
      mostrarNotificacao("teste", true);
    } else {
      // mensagem de erro
      mostrarNotificacao(
        APIresponse.message || "Erro no cadastro. Tente novamente."
      );
    }
  } catch (error) {
    mostrarNotificacao("Erro de conexão com o servidor.");
    console.error("Erro de rede:", error);
  }
});

function mostrarNotificacao(mensagem, sucess = false) {
  const notificacao = document.getElementById("notificacao");
  notificacao.textContent = mensagem;

  if (sucess) {
    notificacao.style.backgroundColor = "green";
  } else {
    notificacao.style.backgroundColor = "red";
  }

  // Mostra
  notificacao.classList.add("show");

  // Esconde depois de 3 segundos
  setTimeout(() => {
    notificacao.classList.remove("show");
  }, 3000);
}

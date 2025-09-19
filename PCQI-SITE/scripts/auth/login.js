// Pegamos o formulário desejado pelo seu id no HTML de cadastro.
const form2 = document.getElementById("formLogin");

// Adicionamos um ouvinte pro evento 'submit' do formulário.
form2.addEventListener("submit", async function (event) {
  event.preventDefault(); //Cancela o tratamento padrão do evento.

  // Pega os dados do formulário
  const nome = document.getElementById("nomeLogin").value;
  const senha = document.getElementById("senhaLogin").value;

  // Validação simples
  if (!nome || !senha) {
    //caso ou o campo de nome ou de senha estejam vazios (retornar
    // none), a notificação é lançada.
    mostrarNotificacao("Preencha todos os campos!");

    return;
  }

  // Prepara os dados para envio.
  const data = {
    nome: nome,
    senha: senha,
  };
  const JSONdata = JSON.stringify(data);

  try {
    // Monta a requisição e entrega.
    const response = await fetch("https://jsonplaceholder.typicode.com/posts", {
      method: "POST",
      // A linha abaixo mudaria para "header" se fosse personalizado.
      headers: { "Content-Type": "application/json" },
      body: JSONdata,
    });

    // Pega a resposta da API em json.
    const APIresponse = await response.json();
    if (response.ok) {
      // Uma notificação de sucesso aparece.
      mostrarNotificacao("teste", true);
    } else {
      // Mensagem de erro.
      mostrarNotificacao(
        APIresponse.message || "Erro no cadastro. Tente novamente."
      );
    }
  } catch (error) {
    mostrarNotificacao("Erro de conexão com o servidor!");
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

  // Esconde a  otificação após 3 segundos
  setTimeout(() => {
    notificacao.classList.remove("show");
  }, 3000);
}

function trocarMetodo() {
  const pager = document.getElementById("pager");
  pager.classList.toggle("cadastro");
  const titulo = document.getElementById("pagerTitulo");
  const btn = document.getElementById("pagerBtn");
  if (pager.classList.contains("cadastro")) {
    titulo.textContent = "Já está cadastrado?";
    btn.textContent = "Faça login aqui!";
  } else {
    titulo.textContent = "Ainda não tem uma conta?";
    btn.textContent = "Crie uma conta agora!";
  }
}

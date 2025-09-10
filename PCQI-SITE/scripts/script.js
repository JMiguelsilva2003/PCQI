document.addEventListener("DOMContentLoaded", () => {
  const btnChamar = document.getElementById("btnChamar");
  const resultadoDiv = document.getElementById("resultado");

  btnChamar.addEventListener("click", () => {
    // funcao esta em configf.js
    callApi()
      .then(data => {
        // mensagem de sucesso
        resultadoDiv.textContent = "DADOS DA API:\n" + JSON.stringify(data, null, 2);
      })
      .catch(error => {
        // mensagem de erro
        resultadoDiv.innerHTML = "<span style='color:red'> ERRO: " + error.message + "</span>";
      });
  });
});
document.addEventListener("DOMContentLoaded", () => {
  const btnChamar = document.getElementById("btnChamar");
  const resultadoDiv = document.getElementById("resultado");

  btnChamar.addEventListener("click", () => {
    // chama a função que está no config.js
    callApi()
      .then(data => {
        // mostra os dados no HTML
        resultadoDiv.textContent = "DADOS DA API:\n" + JSON.stringify(data, null, 2);
      })
      .catch(error => {
        resultadoDiv.innerHTML = "<span style='color:red'> ERRO: " + error.message + "</span>";
      });
  });
});
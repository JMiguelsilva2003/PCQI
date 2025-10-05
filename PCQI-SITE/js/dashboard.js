document.addEventListener("DOMContentLoaded", async () => {
  await Promise.all([
    loadHTML("../components/dashboardHeader.html", "header-dashboard"),
    loadHTML("../components/dashboardList.html", "list-dashboard"),
    loadHTML("../components/dashboardComponent.html", "component-dashboard"),
  ]);

  const screen = document.querySelector(".screen");
  const newTabBtn = document.getElementById("newtab");
  const tabsContainer = document.querySelector(".tabs");

  const homeLogo = document.getElementById("homeLogo");
  const perfilDisplay = document.getElementById("perfil-display");

  let tabCount = 0;

  newTabBtn.addEventListener("click", () => {
    tabCount++;

    // Cria uma nova aba a partir daqui
    const tab = document.createElement("div");
    tab.classList.add("tab");
    tab.textContent = `Aba ${tabCount}`;

    // Insere ela antes do botão
    tabsContainer.insertBefore(tab, newTabBtn);

    // Função de clique para trocar conteúdo
    function activateTab() {
      document
        .querySelectorAll(".tab")
        .forEach((t) => t.classList.remove("active"));
      tab.classList.add("active");
      screen.innerHTML = `<p>Você abriu a <strong>${tab.textContent}</strong></p>`;
    }

    // Clicar na aba ativa ela
    tab.addEventListener("click", activateTab);

    // Ativa a aba automaticamente ao criá-la
    activateTab();
  });
  
document.addEventListener("DOMContentLoaded", async () => {
  try {
    const homeLogo = document.getElementById("homeLogo");
    const perfilDisplay = document.getElementById("perfil-display");

    if (homeLogo) {
      homeLogo.addEventListener("click", () => {
        window.location.href = "../screens/dashboard.html";
      });
    }

    if (!perfilDisplay) return;

    const userName = localStorage.getItem("userName");
    const accessToken = localStorage.getItem("accessToken");

    if (userName) {
      perfilDisplay.textContent = userName;
      perfilDisplay.style.cursor = "pointer";
      perfilDisplay.addEventListener("click", () => {
        window.location.href = "../screens/user-board.html";
      });

    } else if (accessToken) {
      perfilDisplay.textContent = "Carregando perfil...";
      perfilDisplay.style.cursor = "wait";

      try {
        const userData = await getUserData(accessToken);
        const newUserName = userData.name;
        localStorage.setItem("userName", newUserName);

        perfilDisplay.textContent = newUserName;
        perfilDisplay.style.cursor = "pointer";
        perfilDisplay.addEventListener("click", () => {
          window.location.href = "../screens/user-board.html";
        });

      } catch (error) {
        alert("Sua sessão expirou. Faça login novamente.");
        localStorage.clear();
        window.location.href = "../screens/login.html";
      }

    } else {
      window.location.href = "../screens/login.html";
    }
  } catch (err) {
    console.error("Erro no header:", err);
  }
});

});

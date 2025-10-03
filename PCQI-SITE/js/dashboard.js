document.addEventListener("DOMContentLoaded", async () => {
  await Promise.all([
    loadHTML("../components/dashboardHeader.html", "header-dashboard"),
    loadHTML("../components/dashboardList.html", "list-dashboard"),
    loadHTML("../components/dashboardComponent.html", "component-dashboard"),
  ]);

  const screen = document.querySelector(".screen");
  const newTabBtn = document.getElementById("newtab");
  const tabsContainer = document.querySelector(".tabs");

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
});

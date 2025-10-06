document.addEventListener("DOMContentLoaded", async () => {
  // Simulação: busca os dados do usuário logado (pode vir de API ou localStorage)
  const user = await getLoggedUser();

  await Promise.all([
    loadHTML("../components/userInfo.html", "info-user")
  ]);

  // Preenche as informações na tela
  if (user) {
    document.getElementById("user-name").textContent = user.name;
    document.getElementById("user-email").textContent = user.email;
    document.getElementById("user-created").textContent = formatDate(user.created_at);
    document.getElementById("user-role").textContent = user.role;
  }

  const logoutBtn = document.getElementById("logout-btn");
  logoutBtn.addEventListener("click", handleLogout);
});

async function getLoggedUser() {
  try {
    return {
      name: "Nome do Usuário",
      email: "usuario.logado@exemplo.com",
      created_at: "2025-10-04T15:30:00.123Z",
      role: "user"
    };
  } catch (err) {
    console.error("Falha ao carregar usuário:", err);
    return null;
  }
}

function formatDate(isoString) {
  const date = new Date(isoString);
  return date.toLocaleString("pt-BR", { dateStyle: "short", timeStyle: "short" });
}

function handleLogout() {
  localStorage.clear();
  window.location.href = "/index.html";
}
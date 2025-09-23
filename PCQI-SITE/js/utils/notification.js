function showNotification(message, isError = false) {
    const notificacaoDiv = document.getElementById('notificacao');
    notificacaoDiv.textContent = message;
    
    if (isError) {
        notificacaoDiv.classList.add('error');
    } else {
        notificacaoDiv.classList.remove('error');
    }

    notificacaoDiv.classList.add('show');

    setTimeout(() => {
        notificacaoDiv.classList.remove('show');
    }, 5000);
}
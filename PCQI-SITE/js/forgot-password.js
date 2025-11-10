document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('formForgotPassword');
    const submitButton = form.querySelector('.submit-btn');

    const showButtonLoader = (button) => {
        button.disabled = true;
        button.classList.add('loading');
    };
    const hideButtonLoader = (button) => {
        button.disabled = false;
        button.classList.remove('loading');
    };

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        showButtonLoader(submitButton);

        const email = document.getElementById('emailForgot').value;

        try {
            const result = await requestPasswordReset(email);
            showNotification(result.message);
            submitButton.querySelector('.button-text').textContent = 'Enviado!';
        } catch (error) {
            showNotification(error.message, true);
        } finally {
            hideButtonLoader(submitButton);
        }
    });
});
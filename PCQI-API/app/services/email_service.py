import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from app.security import create_access_token

def send_verification_email(email: str):
    verification_token = create_access_token(data={"sub": email})
    
    verification_url = f"https://pcqi.onrender.com/verify-email?token={verification_token}"

    message = Mail(
        from_email='email@pcqi.com',
        to_emails=email,
        subject='PCQI - Verifique seu endereço de email',
        html_content=f"""
        <h1>Bem-vindo ao PCQI!</h1>
        <p>Obrigado por se registrar. Por favor, clique no link abaixo para verificar seu email:</p>
        <a href="{verification_url}">Verificar Email</a>
        <p>Se você não se registrou, por favor ignore este email.</p>
        """
    )
    try:
        sg = SendGridAPIClient(os.environ.get('SENDGRID_API_KEY'))
        response = sg.send(message)
        print(f"Email enviado para {email}, Status: {response.status_code}")
    except Exception as e:
        print(f"Erro ao enviar email para {email}: {e}")
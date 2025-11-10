import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail
from app.security import create_access_token

SENDER_EMAIL = os.environ.get('MAIL_FROM_EMAIL')

def send_verification_email(email: str):
    verification_token = create_access_token(data={"sub": email})
    verification_url = f"https://pcqi.onrender.com/verify-email?token={verification_token}"

    message = Mail(
        from_email=SENDER_EMAIL,
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

def send_password_reset_email(email: str):
    reset_token = create_access_token(data={"sub": email})
    
    reset_url = f"https://pcqi.onrender.com/reset-password?token={reset_token}" 

    message = Mail(
        from_email=SENDER_EMAIL,
        to_emails=email,
        subject='PCQI - Redefinição de Senha',
        html_content=f"""
        <h1>Redefinição de Senha</h1>
        <p>Você solicitou uma redefinição de senha. Clique no link abaixo para criar uma nova senha:</p>
        <a href="{reset_url}">Redefinir Senha</a>
        <p>Este link expirará em 15 minutos.</p>
        <p>Se você não solicitou isso, por favor ignore este email.</p>
        """
    )
    try:
        sg = SendGridAPIClient(os.environ.get('SENDGRID_API_KEY'))
        response = sg.send(message)
        print(f"Email de redefinição enviado para {email}, Status: {response.status_code}")
    except Exception as e:
        print(f"Erro ao enviar email de redefinição para {email}: {e}")
        raise e 
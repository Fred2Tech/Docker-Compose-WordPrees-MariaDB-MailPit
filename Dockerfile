FROM wordpress:latest

# SSL (self-signed certificate) + msmtp to send mails to Mailpit
RUN apt-get update \
 && apt-get install -y --no-install-recommends msmtp msmtp-mta openssl \
 && rm -rf /var/lib/apt/lists/* \
 && a2enmod ssl \
 && a2ensite default-ssl \
 && openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
      -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
      -out /etc/ssl/certs/ssl-cert-snakeoil.pem \
      -subj "/CN=localhost" \
      -addext "subjectAltName=DNS:localhost,IP:127.0.0.1" \
 && printf 'defaults\naccount default\nhost mailpit\nport 1025\nauto_from on\nmaildomain localhost\ntls off\nlogfile -\n' > /etc/msmtprc \
 && printf 'sendmail_path = "/usr/bin/msmtp -t"\n' > /usr/local/etc/php/conf.d/mail.ini

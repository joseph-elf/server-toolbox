
# HTTPS

sudo apt install certbot python3-certbot-nginx -y

sudo certbot --nginx -d josephelf.fr -d www.josephelf.fr

sudo certbot renew --dry-run

sudo systemctl reload nginx

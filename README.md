# Script to Create and Configure APIs in Nginx

This Bash script allows you to automatically create the directory for a new Laravel API, configure Nginx and assign the necessary permissions on a server running Multipass.

---

## Configuration Script

Save the following script as `configure_api.sh` and give it execution permissions.

### Script `configure_api.sh`

```bash
#!/bin/bash

# Request the API name and domain or subdomain
read -p "Enter the API name (e.g. MyApi): " API_NAME
read -p "Enter the domain or subdomain for the API (e.g. api.local): " API_DOMAIN

# Define the base directory for APIs
API_PATH="/var/www/$API_NAME"
NGINX_CONF="/etc/nginx/sites-available/$API_NAME"

# Create the project directory
if [ ! -d "$API_PATH" ]; then
sudo mkdir -p "$API_PATH/public"
echo "Directory $API_PATH created."
else
echo "Directory $API_PATH already exists."
fi # Create the Nginx configuration sudo tee "$NGINX_CONF" > /dev/null <<EOL server { listen 80;
 server_name $API_DOMAIN;
 root $API_PATH/public;

 index index.php index.html index.htm;

 location / { try_files \$uri \$uri/ /index.php?\$query_string;
 } location ~ \.php\$ { include snippets/fastcgi-php.conf;
 fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
 } } EOL echo "Nginx configuration created for $API_DOMAIN in $NGINX_CONF."

# Bind the configuration in sites-enabled if [ ! -L "/etc/nginx/sites-enabled/$API_NAME" ]; then
sudo ln -s "$NGINX_CONF" /etc/nginx/sites-enabled/
echo "Configuration bound in sites-enabled."
fi

# Assign user permissions to www-data
sudo chown -R www-data:www-data "$API_PATH"
sudo chmod -R 755 "$API_PATH"

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

echo "API configured in $API_DOMAIN and Nginx reloaded successfully."
echo "Visit http://$API_DOMAIN to verify configuration."
```

---

## Steps to Run the Script

1. Give the script execution permissions after saving it:

```bash
chmod +x configure_api.sh
```

2. Run the script:

```bash
sudo ./configure_api.sh
```

3. Enter the API name and domain when the script prompts you.

The script will take care of creating the API directory, generating the Nginx configuration, binding it to `sites-enabled`, assigning permissions, and reloading Nginx. With this, your new API should be accessible on the domain you configured.

---

This script simplifies the creation and configuration of new APIs on your server, allowing you to deploy multiple APIs efficiently.
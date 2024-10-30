#!/bin/bash

# Request the API name and domain or subdomain
read -p "Enter the API name (e.x., MyApi): " API_NAME
read -p "Enter the domain or subdomain for the API (e.g., api.local): " API_DOMAIN

# Define the base directory for APIs
API_PATH="/var/www/$API_NAME"
NGINX_CONF="/etc/nginx/sites-available/$API_NAME"

# Create the project directory
if [ ! -d "$API_PATH" ]; then
    sudo mkdir -p "$API_PATH/public"
    echo "Directory $API_PATH created."
else
    echo "Directory $API_PATH already exists."
fi

# Create the Nginx configuration
sudo tee "$NGINX_CONF" > /dev/null <<EOL
server {
    listen 80;
    server_name $API_DOMAIN;
    root $API_PATH/public;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
EOL

echo "Nginx configuration created for $API_DOMAIN at $NGINX_CONF."

# Link the configuration in sites-enabled
if [ ! -L "/etc/nginx/sites-enabled/$API_NAME" ]; then
    sudo ln -s "$NGINX_CONF" /etc/nginx/sites-enabled/
    echo "Configuration linked in sites-enabled."
fi

# Assign user permissions to www-data
sudo chown -R www-data:www-data "$API_PATH"
sudo chmod -R 755 "$API_PATH"

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

echo "API configured on $API_DOMAIN and Nginx successfully reloaded."
echo "Visit http://$API_DOMAIN to verify the configuration."

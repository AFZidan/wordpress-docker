# .env
WORDPRESS_DOMAIN=wordpress.example.com
PMA_DOMAIN=pma.wordpress.example.com
EMAIL=your-email@example.com
MYSQL_DB_HOST=db
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=your_password
PMA_USER=wordpress_user
PMA_PASSWORD=your_password
PMA_DOMAIN=pma.wordpress.example.com
HTTPS_METHOD=redirect
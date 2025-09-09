<?php

/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', getenv('MYSQL_DATABASE') ?: 'wordpress');

/** Database username */
define('DB_USER', getenv('MYSQL_USER') ?: 'wpuser');

/** Database password */
define('DB_PASSWORD', getenv('MYSQL_PASSWORD') ?: 'wpP@ssword123');

/** Database hostname */
define('DB_HOST', getenv('MYSQL_DB_HOST') ?: 'db');

/** Database charset to use in creating database tables. */
define('DB_CHARSET', 'utf8mb4');

/** The database collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '~Z+^{AI__MchXMeFviD<Nj?_KNyzns@_4*wWIi,&B:y#g>:Zxxm9 $._t~#V`2aR');
define('SECURE_AUTH_KEY',  '({^L@6!Gn5pu*fDou]A 8*%Yzaw^<#Y<D0sKv20gC8ZPkGalW Du=7aE_QFo-<;_');
define('LOGGED_IN_KEY',    'ATh@^,_[>EYI[]E!+Jh2Eiy@/ZvTh6EGd@m~8vd>C?VGPjz]@QK;1 l:wa9?okM`');
define('NONCE_KEY',        'SxZy=lsy=`U[0Skmw9XHW*e#J<wPN$ss(Xs@dl3oS1nD2Pa>2ba))1Q4uFNy6G$3');
define('AUTH_SALT',        '=v/W:e[^J*vqG-V^9kdNnErTb7h.r1SapMWeqk7UG~}7FDOwv/f<B.?eNPh;%rNd');
define('SECURE_AUTH_SALT', 'D~bvtb1i`2+e#1:H+1Xlq4F!jM,a)CSez:{FZZKYnR$[_G`DI>)57Y~&~I#BT[M7');
define('LOGGED_IN_SALT',   '[l8Gzz`#<eZCz8anW=Z(/opNMw&6g>+pHgMy! _:r}=lX0D8CAl1zc-hcdH,V9#!');
define('NONCE_SALT',       '?^TS$VS8*k!$[caKV}<I rm[}y})_dg0wKS1Y:w~S-q%w]Xd-t}o/S(8ED=J3<jw');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define('WP_DEBUG', true);
/* Add any custom values between this line and the "stop editing" line. */

define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);
@ini_set('display_errors', 0);

// Disable WP-Cron if environment variable is set (we use real cron instead)
if (getenv('DISABLE_WP_CRON') === 'true') {
    define('DISABLE_WP_CRON', true);
}



/* That's all, stop editing! Happy pu       blishing. */

/** Absolute path to the WordPress directory. */
if (! defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

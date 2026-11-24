<?php
/**
 * Plugin Name: Mailpit (dev)
 * Description: Sends all WordPress mails to Mailpit (SMTP mailpit:1025).
 */

add_action('phpmailer_init', function ($phpmailer) {
    $phpmailer->isSMTP();
    $phpmailer->Host        = 'mailpit';
    $phpmailer->Port        = 1025;
    $phpmailer->SMTPAuth    = false;
    $phpmailer->SMTPSecure  = '';
    $phpmailer->SMTPAutoTLS = false;
});

// "wordpress@localhost" is rejected by PHPMailer (domain without a dot).
add_filter('wp_mail_from', fn() => 'wordpress@wordpress.local');
add_filter('wp_mail_from_name', fn() => 'WordPress');

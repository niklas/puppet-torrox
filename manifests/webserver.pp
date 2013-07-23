# Module:: rails
# Manifest:: webserver.pp
#
# Author:: Matthias Viehweger (<kronn@kronn.de>)
# Date:: Fri Oct 12 14:45:26 +0200 2012
#
# Basic Usage:
#
#     rails::webserver { 'example.com':
#       app_name     => 'example',
#       deploy_to    => '/tmp',
#       rails_env    => 'production',
#       ruby_version => 'ruby-1.9.3-p286'
#     }
#
# Further Parameters:
#
#     $http_basic_auth      = { 'user1' => 'pass1', 'user2' => 'pass2' }
#     $server_aliases       = 'example.org example.net',
#     $server_name          = $name,
#     $server_ssl_port      = '443',
#     $server_web_port      = '80',
#     $server_prefix        = '',
#     $ssl_cert_bundle_path = false,
#     $ssl_cert_key_path    = '/etc/ssl/private/ssl-cert-snakeoil.key',
#     $ssl_cert_path        = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
#     $vhost_template       = "${app_name}/apache.site.erb"
#
# Intention:
#
#     This type should be called from your own application-specific module.
#
#     The following variables are available in the $vhost_template:
#
#     $server_name
#     $server_web_port
#     $server_ssl_port
#     $document_root
#     $ssl_cert_path
#     $ssl_cert_key_path
#     $ssl_cert_bundle_path
#     $listen_web
#     $listen_ssl
#
# ToDo:
#
#  - make the passenger-variable configurable
#
define rails::webserver(
    $app_name,
    $deploy_to,
    $rails_env,
    $ruby_version,
    $user,

    $document_root        = "$deploy_to/current/public",
    $http_basic_auth      = false,
    $server_aliases       = false,
    $server_name          = $name,
    $server_ssl_port      = '443',
    $server_web_port      = '80',
    $server_prefix        = '',
    $ssl_cert_bundle_path = false,
    $ssl_cert_key_path    = '/etc/ssl/private/ssl-cert-snakeoil.key',
    $ssl_cert_path        = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    $vhost_template       = "${app_name}/apache.site.erb"
) {
  include rails::webserver::ssl
  include rails::webserver::base

  $prefixed_app_name = "${server_prefix}${app_name}"

  file {
    $ssl_cert_path:
      ensure  => file,
      replace => false;

    $ssl_cert_key_path:
      ensure  => file,
      replace => false;
  }

  if $ssl_cert_bundle_path {
    file { $ssl_cert_bundle_path:
      ensure  => file,
      replace => false;
    }
  }

  # TODO this will not yet work as intended
  if is_hash($http_basic_auth) {
    $users = keys($http_basic_auth)
    rails::webserver::basic_auth { "${app_name} at ${server_name}":
      credentials => $http_basic_auth
    }
  }

  $server_alias = $server_aliases ? {
    false   => '',
    default => $server_aliases
  }
  $listen_web = $server_web_port ? {
    80      => '',
    default => "Listen $server_web_port",
  }
  $listen_ssl = $server_ssl_port ? {
    443     => '',
    default => "Listen $server_ssl_port",
  }

  if $prefixed_app_name != $app_name {
    file { "/etc/apache2/sites-available/$app_name":
      ensure => absent;
    }
    exec { "a2dissite $app_name":
      onlyif  => "test -L /etc/apache2/sites-enabled/$app_name",
      require => Package['apache2'],
      notify  => Service['apache2']
    }
  }
  file { "/etc/apache2/sites-available/$prefixed_app_name":
    ensure  => file,
    content => template($vhost_template),
    require => [ File[$ssl_cert_path], File[$ssl_cert_key_path] ],
    notify  => Service['apache2']
  }

  if $::rvm_installed == 'true' {
    exec { "a2ensite $prefixed_app_name":
      creates => "/etc/apache2/sites-enabled/$prefixed_app_name",
      require => [
        File["/etc/apache2/sites-available/$prefixed_app_name"],
        Package['apache2'],
        Rvm_system_ruby[$ruby_version],
        Class['rvm::passenger::apache'],
        File[$document_root]
      ],
      notify  => Service['apache2']
    }
  }
}

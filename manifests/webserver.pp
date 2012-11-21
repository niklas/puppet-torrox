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
#  - make the passenger_version configurable
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
    $ssl_cert_bundle_path = false,
    $ssl_cert_key_path    = '/etc/ssl/private/ssl-cert-snakeoil.key',
    $ssl_cert_path        = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    $vhost_template       = "${app_name}/apache.site.erb"
) {
  include packages::apache
  include rails::webserver::ssl
  include rails::webserver::base

  $passenger_version = '3.0.11'

  include rvm::passenger::apache::ubuntu::pre
  if $::rvm_installed == "true" {
    if !defined(Class['rvm::passenger::apache::ubuntu::post']) {
      class { 'rvm::passenger::apache::ubuntu::post':
        version      => $passenger_version,
        ruby_version => $ruby_version,
        gempath      => "/usr/local/rvm/gems/${ruby_version}/gems",
        binpath      => '/usr/local/rvm/bin/'
      }
    }

    if !defined(Class['rvm::passenger::apache']) {
      class { 'rvm::passenger::apache':
        version            => $passenger_version,
        ruby_version       => $ruby_version,
        require            => [ Rvm_system_ruby[$ruby_version], Service['apache2'] ],
        mininstances       => '1',
        maxinstancesperapp => '5',
        maxpoolsize        => '10',
        poolidletime       => '300',
        spawnmethod        => 'smart-lv2';
      }
    }
  }

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

  file { "/etc/apache2/sites-available/$app_name":
    ensure  => file,
    content => template($vhost_template),
    require => [ File[$ssl_cert_path], File[$ssl_cert_key_path] ],
    notify  => Service['apache2']
  }

  if $::rvm_installed == "true" {
    exec { "a2ensite $app_name":
      creates => "/etc/apache2/sites-enabled/$app_name",
      require => [
        File["/etc/apache2/sites-available/$app_name"],
        Package['apache2'],
        Rvm_system_ruby[$ruby_version],
        File[$document_root]
      ],
      notify  => Service['apache2']
    }
  }
}

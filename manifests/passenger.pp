# Class:: rails::passenger
#
#
define rails::passenger(
  $ruby_version = $title,
  $passenger_version = $rails::params::passenger_version
) {
  include rvm::dependencies::ubuntu
  include rvm::passenger::apache::ubuntu::pre

  if $::rvm_installed == 'true' {
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

  # have this present if needed
  if !defined(Service['apache2']) {
    service {
      'apache2':
        ensure     => running,
        require    => Package['apache2'],
        enable     => true,
        hasrestart => true,
        hasstatus  => true;
    }
  }
}

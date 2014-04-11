# Class:: rails::passenger
#
#
define rails::passenger(
  $ruby_version       = $title,
  $passenger_version  = $rails::params::passenger_version,
  $mininstances       = '1',
  $maxinstancesperapp = '5',
  $maxpoolsize        = '10',
  $poolidletime       = '300',
) {
  if "$::rvm_installed" == 'true' {
    class { 'rvm::passenger::apache':
      version            => $passenger_version,
      ruby_version       => $ruby_version,
      require            => [ Rvm_system_ruby[$ruby_version], Service['apache2'] ],
      mininstances       => $mininstances,
      maxinstancesperapp => $maxinstancesperapp,
      maxpoolsize        => $maxpoolsize,
      poolidletime       => $poolidletime,
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
  if !defined(Package['apache2'])              { package { 'apache2':              ensure => present } }
  if !defined(Package['libcurl4-openssl-dev']) { package { 'libcurl4-openssl-dev': ensure => present } }
}

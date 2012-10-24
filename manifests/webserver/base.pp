class rails::webserver::base {
  # untested
  exec { 'a2dissite default':
    onlyif  => 'test -L /etc/apache2/sites-enabled/000-default',
    require => Package['apache2'],
    notify  => Service['apache2']
  }
}

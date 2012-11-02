class rails::webserver::rewrite {
  # untested
  exec { 'a2enmod rewrite':
    unless  => 'test -L /etc/apache2/mods-enabled/rewrite.load',
    require => Package['apache2'],
    notify  => Service['apache2']
  }
}

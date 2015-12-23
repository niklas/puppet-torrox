class rails::webserver::headers {
  # untested
  exec { 'a2enmod headers':
    unless  => 'test -L /etc/apache2/mods-enabled/headers.load',
    require => Package['apache2'],
    notify  => Service['apache2']
  }
}

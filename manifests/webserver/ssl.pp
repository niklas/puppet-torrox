class rails::webserver::ssl {
  # untested
  exec { 'a2enmod ssl':
    unless  => 'test -L /etc/apache2/mods-enabled/ssl.conf',
    require => Package['apache2'],
    notify  => Service['apache2']
  }
}

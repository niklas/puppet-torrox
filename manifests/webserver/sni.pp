class rails::webserver::sni {
  # this disables the default site which is not made for this config
  include rails::webserver::base

  file { '/etc/apache2/conf.d/sni':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('rails/sni.erb');
  }
}

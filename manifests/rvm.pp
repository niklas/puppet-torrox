define rails::rvm($user, $ruby_version, $default_use = true) {
  include rails::rvm_latest

  if "$::rvm_installed" == 'true' {
    rvm_system_ruby { $ruby_version:
      ensure      => 'present',
      default_use => $default_use;
    }

    if $default_use {
      file { 'set default rvm ruby':
        ensure  => file,
        require => Rvm_system_ruby[$ruby_version],
        path    => '/usr/local/rvm/config/alias',
        owner   => 'root',
        group   => 'rvm',
        mode    => '0664',
        content => "default=$ruby_version",
      }
    }
  }
}

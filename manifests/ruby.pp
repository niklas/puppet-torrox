define rails::ruby(
  $user,
  $ruby_version    = $name,
  $gemset          = false,
  $bundler_version = '1.1.5',
  $default_use     = true
) {
  if $gemset == 'false' or $gemset == false {
    $ruby_full = $ruby_version
  } else {
    $ruby_full = "$ruby_version@$gemset"
  }

  # if !defined(Rvm_system_ruby[$ruby_version]) {
  if !defined(Rails::Rvm[$ruby_version]) {
    rails::rvm { $ruby_version:
      ruby_version => $ruby_version,
      user         => $user,
      default_use  => $default_use
    }
  }

  if !defined(Rvm::System_user[$user]) {
    rvm::system_user { $user: }
  }

  if "$::rvm_installed" == 'true' {
    if $ruby_full == $ruby_version {
      rvm_gem { "$ruby_version/bundler":
        ensure  => $bundler_version,
        require => Rvm_system_ruby[$ruby_version];
      }
    } else {
      rvm_gemset { $ruby_full:
        ensure  => present,
        require => Rvm_system_ruby[$ruby_version];
      }
      rvm_gem { "$ruby_full/bundler":
        ensure  => $bundler_version,
        require => Rvm_gemset[$ruby_full];
      }
    }
  }
}

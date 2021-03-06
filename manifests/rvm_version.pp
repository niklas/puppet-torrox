class rails::rvm_version (
  $version = latest,
) {
  class { 'rvm':
    version     => $version,
    install_rvm => true,
    require     => File['/etc/rvmrc'],
  }

  # we want to use application specific rvmrcs
  file { '/etc/rvmrc':
    path    => '/etc/rvmrc',
    mode    => '0644',
    content => "umask g+w
rvm_trust_rvmrcs_flag=1
rvm_auto_reload_flag=2",
  }

  # generate no docs for gems
  file { '/etc/gemrc':
    path    => '/etc/gemrc',
    mode    => '0644',
    content => 'gem: --no-rdoc --no-ri',
  }
}

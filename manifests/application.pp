define rails::application(
  $user,
  $rails_env,
  $database_adapter,
  $database_host,
  $database_port,
  $database_user,
  $database_password,

  $app_name          = $name,
  $database          = "${app_name}_${rails_env}"
) {
  $app_dir    = "/home/$user/projects/$app_name"
  $env_dir    = "$app_dir/$rails_env"
  $shared_dir = "$env_dir/shared"

  include packages::cron
  include packages::logrotate

  file { "/etc/logrotate.d/${app_name}-${rails_env}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['logrotate'],
    content => template('rails/logrotate.erb');
  }

  exec {
    "mkdir environment for ${app_name}-${rails_env}":
      command => "mkdir -p $env_dir",
      require => User[$user],
      path    => '/bin:/usr/bin',
      group   => $user,
      user    => $user,
      creates => $env_dir;
  }

  file {
    $shared_dir:
      ensure  => directory,
      require => Exec["mkdir environment for ${app_name}-${rails_env}"],
      group   => $user,
      mode    => '0755',
      owner   => $user;

    "$shared_dir/config":
      ensure  => directory,
      require => File[$shared_dir],
      group   => $user,
      mode    => '0755',
      owner   => $user;

    "$shared_dir/system":
      ensure  => directory,
      require => File[$shared_dir],
      group   => $user,
      mode    => '0755',
      owner   => $user;

    "$env_dir/releases":
      ensure  => directory,
      require => Exec["mkdir environment for ${app_name}-${rails_env}"],
      group   => $user,
      mode    => '0755',
      owner   => $user;

    "$shared_dir/log":
      ensure  => directory,
      require => File[$shared_dir],
      group   => $user,
      mode    => '0755',
      owner   => $user;

    "$shared_dir/log/rotated":
      ensure  => directory,
      require => File[$shared_dir],
      group   => $user,
      mode    => '0755',
      owner   => $user;

    "$shared_dir/log/$rails_env.log":
      ensure  => file,
      require => File["$shared_dir/log"],
      group   => $user,
      mode    => '0666',
      owner   => $user;

    "$shared_dir/config/database.yml":
      ensure  => file,
      require => File["$shared_dir/config"],
      content => template('rails/database.yml.erb'),
      group   => $user,
      mode    => '0644',
      replace => false,
      owner   => $user;

    "run-dir for $user of $app_name":
      ensure  => directory,
      path    => "$shared_dir/pids",
      owner   => $user,
      group   => 'root',
      mode    => '0755',
      require => [ Package['cron'], Exec["mkdir environment for ${app_name}-${rails_env}"] ];
  }
}
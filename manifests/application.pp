define rails::application(
  $user,
  $rails_env,
  $database_adapter,
  $database_host,
  $database_port,
  $database_user,
  $database_password,

  $create_uploads    = true,

  $app_name          = $name,
  $database          = "${name}_${rails_env}"
) {
  $app_dir    = "/home/$user/projects/$app_name"
  $env_dir    = "$app_dir/$rails_env"
  $shared_dir = "$env_dir/shared"

  include packages::cron

  logrotate::rule { "${app_name}-${rails_env}":
    path          => "/home/${user}/projects/${app_name}/${rails_env}/shared/log/*.log",
    rotate        => 99,
    rotate_every  => 'day',
    compress      => true,
    copytruncate  => true,
    dateext       => true,
    delaycompress => true,
    missingok     => true,
    ifempty       => false,
    olddir        => "/home/${user}/projects/${app_name}/${rails_env}/shared/log/rotated",
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
    $env_dir:
      ensure  => directory,
      require => Exec["mkdir environment for ${app_name}-${rails_env}"],
      group   => $user,
      mode    => '0755',
      owner   => $user;

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

    # create a dummy release so we can symlink it as document root for apache
    "$env_dir/releases/00000000000000":
      ensure  => directory,
      require => File["$env_dir/releases"],
      group   => $user,
      mode    => '0755',
      owner   => $user;

    "$env_dir/current":
      ensure  => link,
      group   => $user,
      owner   => $user,
      target  => "$env_dir/releases/00000000000000",
      require => File["$env_dir/releases/00000000000000"],
      replace => false;

    "$env_dir/current/public":
      ensure  => directory,
      require => File["$env_dir/current"],
      group   => $user,
      mode    => '0755',
      replace => false,
      owner   => $user;

  }

  if ($create_uploads) {
    file {
      "$shared_dir/uploads":
        ensure  => directory,
        require => File[$shared_dir],
        group   => $user,
        mode    => '0755',
        owner   => $user;
    }
  }
}

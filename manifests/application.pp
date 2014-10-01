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
  $database          = "${name}_${rails_env}",
  $deploy_to         = "/home/$user/projects/$name/$rails_env"
) {
  $shared_dir = "$deploy_to/shared"

  include packages::cron

  logrotate::rule { "${app_name}-${rails_env}":
    path          => "${deploy_to}/shared/log/*.log",
    rotate        => 99,
    rotate_every  => 'day',
    compress      => true,
    copytruncate  => true,
    dateext       => true,
    delaycompress => true,
    missingok     => true,
    ifempty       => false,
    olddir        => "${deploy_to}/shared/log/rotated",
  }

  exec {
    "mkdir environment for ${app_name}-${rails_env}":
      command => "mkdir -p $deploy_to",
      require => User[$user],
      path    => '/bin:/usr/bin',
      group   => $user,
      user    => $user,
      creates => $deploy_to;
  }

  file {
    $deploy_to:
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

    "$deploy_to/releases":
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
    "$deploy_to/releases/00000000000000":
      ensure  => directory,
      require => File["$deploy_to/releases"],
      group   => $user,
      mode    => '0755',
      owner   => $user;

    "$deploy_to/current":
      ensure  => link,
      group   => $user,
      owner   => $user,
      target  => "$deploy_to/releases/00000000000000",
      require => File["$deploy_to/releases/00000000000000"],
      replace => false;

    "$deploy_to/current/public":
      ensure  => directory,
      require => File["$deploy_to/current"],
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

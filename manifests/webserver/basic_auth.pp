define rails::webserver::basic_auth($user, $credentials = {}) {
  $password = $credentials[$user]

  apache::auth::htpasswd { "${user} on ${app_name} at ${server_name}":
    ensure           => 'present',
    userFileLocation => $shared_path,
    userFileName     => '.htpasswd',
    username         => $user,
    clearPassword    => $password,
    require          => File["${current_path}/public/.htaccess"]
  }

  # <Location <%= location %>>
  #   AuthName "<%= _authname %>"
  #   AuthType Basic
  #   AuthBasicProvider file
  #   AuthUserFile <%= _authUserFile %>
  #   Require <%= _users %>
  # </Location>
  $location      = '/'
  $_authname      = 'Protected Area'
  $_authUserFile = "${shared_path}/.htpasswd"
  $_users        = 'valid-user'

  file { "${shared_path}/.htpasswd":
    ensure  => present,
    require => File[$shared_path]
  }

  file { "${current_path}/public/.htaccess":
    ensure  => present,
    content => template('rails/auth-basic-file-user.erb'),
    notify  => Service['apache2']
  }
}

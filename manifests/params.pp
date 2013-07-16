class rails::params {
  $random_password   = inline_template('<%= c=[("a".."z"),("A".."Z"),("0".."9"),%w(# % & * + - : = ? @ ^ _)].map(&:to_a).flatten;25.times.map{c[rand(c.length)]}.join%>')

  $user              = 'application'
  $rails_env         = 'production'
  $database_adapter  = 'mysql'
  $database_host     = 'localhost'
  $database_port     = '3306'
  $database_user     = 'root'
  $database_password = ''
  $ruby_version      = 'ruby-1.9.3-p0'
  $gemset            = 'rails'
  $passenger_version = '4.0.8'

  # the deploy_to here does not work always due to variable scoping
  # it is, however, an example of our standard deploy_to
  #
  # $deploy_to         = "/home/$user/projects/$app_name/$rails_env"
}


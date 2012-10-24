Puppet Torrox
=============

Deploy Rails applications the stachenblocken way.

Examples
--------


    node 'app1.pigstuf.fr' inherits default {
      rails::ruby { 'ree-1.7.01':
        user            => 'bert',
        gemset          => 'nasa',
        default_use     => false,
        bundler_version => '1.2.3.4.5'
      }
      rails::ruby { 'ree-1.7.02':
        user         => 'wally',
        ruby_version => 'ree-1.7.01',
        default_use  => false
      }
      rails::ruby { 'ruby-1.9.3-p194':
        gemset => 'pigstuffr',
        user   => 'application'
      }

      rails::webserver { 'pigstuffr':
        app_name          => 'pigstuffr',
        deploy_to         => '/tmp/',
        rails_env         => 'production',
        ruby_version      => 'ruby-1.9.3-p194',
        server_name       => 'pigstuf.fr',
        server_aliases    => 'www.pigstuf.fr pigstuf.fr pigstuffr.net',
        server_ssl_port   => '443',
        server_web_port   => '80',
        ssl_cert_key_path => '/tmp/shared/pigstuf.fr.key',
        ssl_cert_path     => '/tmp/shared/star.pigstuf.fr.cert',
        user              => 'application'
      }

      include rails::params
      rails::application { 'right_angles':
        user              => 'holgi',
        rails_env         => 'production',
        database_adapter  => $rails::params::database_adapter,
        database_host     => $rails::params::database_host,
        database_port     => $rails::params::database_port,
        database_user     => $rails::params::database_user,
        database_password => $rails::params::database_password,
      }
    }


FAQ
---

What the frak is 'torrox'? -- it is the next big town next to capistrano.

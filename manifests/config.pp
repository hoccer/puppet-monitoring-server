class monitoring-server::config {

  file { '/etc/riemann.config':
    owner  => root,
    group  => root,
    mode   => 644,
    source => 'puppet:///modules/monitoring-server/riemann/riemann.config',
  }

  file { '/var/log/riemann':
    ensure => directory,
    owner  => riemann,
    group  => riemann,
    mode   => 755,
  }

  file { '/var/lib/riemann-dash':
    ensure => directory,
    owner  => riemann-dash,
    group  => riemann-dash,
    mode   => 755,
  }

  file { '/var/lib/riemann-dash/layout.json':
    owner  => root,
    group  => root,
    mode   => 644,
    source => 'puppet:///modules/monitoring-server/riemann-dash/layout.json',
    require => File['/var/lib/riemann-dash']
  }


  nginx::resource::upstream { 'fcgiwrap':
    members => [
      'unix:/var/run/fcgiwrap.socket',
    ],
  }

  nginx::resource::upstream { 'php':
    members => [
      'unix:/var/run/php5-fpm.socket',
    ],
  }

  nginx::resource::vhost { 'nagios.hoccer.de':
    listen_port          => 443,
    ssl                  => true,
    ssl_cert             => '/etc/ssl/certs/star.hoccer.de.crt',
    ssl_key              => '/etc/ssl/private/star.hoccer.de.key',
    ssl_port             => 443,
    ssl_protocols        => 'TLSv1 TLSv1.1 TLSv1.2',
    auth_basic           => 'Nagios',
    auth_basic_user_file => '/etc/nagios3/nagios.htpasswd',
    index_files          => ['index.php', 'index.html'],
    www_root             => '/usr/share/nagios3/htdocs',
    use_default_location => false,
  }

  nginx::resource::location { 'stylesheets_loc':
    location       => '/stylesheets',
    vhost          => 'nagios.hoccer.de',
    location_alias => '/etc/nagios3/stylesheets',
    ssl            => true,
    ssl_only       => true,
  }

  nginx::resource::location { 'cgi_loc':
    location                   => '~ \.cgi$',
    vhost                      => 'nagios.hoccer.de',
    www_root                   => '/usr/lib/cgi-bin/nagios3',
    fastcgi                    => 'fcgiwrap',
    fastcgi_script             => '/usr/lib/cgi-bin/nagios3$fastcgi_script_name',
    ssl                        => true,
    ssl_only                   => true,
    location_custom_cfg_append => [
      'fastcgi_param AUTH_USER $remote_user;',
      'fastcgi_param REMOTE_USER $remote_user;',
      'rewrite ^/cgi-bin/nagios3/(.*)$ /$1;',
    ],
  }

  nginx::resource::location { 'php_loc':
    location                   => '~ \.php$',
    vhost                      => 'nagios.hoccer.de',
    fastcgi                    => 'php',
    fastcgi_script             => '$document_root$fastcgi_script_name',
    ssl                        => true,
    ssl_only                   => true,
    try_files                  => [
      '$uri =404',
    ],
    location_custom_cfg_append => [
      'fastcgi_index index.php;',
    ],
  }

  nginx::resource::location { 'pnp4nagios_loc':
    location                   => '/pnp4nagios',
    vhost                      => 'nagios.hoccer.de',
    location_alias             => '/usr/share/pnp4nagios/html',
    ssl                        => true,
    ssl_only                   => true,
  }

  nginx::resource::location { 'pnp4nagios_php_loc':
    location                   => '~ ^(/pnp4nagios.*\.php)(.*)$',
    vhost                      => 'nagios.hoccer.de',
    www_root                   => '/usr/share/pnp4nagios/html',
    fastcgi                    => 'php',
    fastcgi_script             => '$document_root/index.php',
    ssl                        => true,
    ssl_only                   => true,
    location_custom_cfg_append => [
      'fastcgi_split_path_info ^(.+\.php)(.*)$;',
      'fastcgi_param PATH_INFO $fastcgi_path_info;',
    ],
  }


  nginx::resource::upstream { 'ntop':
    members => [
      'localhost:3000',
    ],
  }

  nginx::resource::vhost { 'ntop.hoccer.de':
    proxy                => 'http://ntop',
    listen_port          => 443,
    ssl                  => true,
    ssl_cert             => '/etc/ssl/certs/star.hoccer.de.crt',
    ssl_key              => '/etc/ssl/private/star.hoccer.de.key',
    ssl_port             => 443,
    ssl_protocols        => 'TLSv1 TLSv1.1 TLSv1.2',
    auth_basic           => 'NTOP',
    auth_basic_user_file => '/etc/ntop/ntop.htpasswd',
    proxy_set_header     => [
      'X-Real-IP $remote_addr',
      'Host $host',
      'X-Forwarded-For $remote_addr',
    ],
  }

  nginx::resource::location { 'ntop_images_loc':
    location       => '/images',
    vhost          => 'ntop.hoccer.de',
    location_alias => '/usr/share/pnp4nagios/html/media/css/ui-smoothness/images',
    ssl            => true,
    ssl_only       => true,
  }


  nginx::resource::upstream { 'riemann-dash':
    members => [
      'localhost:4567',
    ],
  }

  nginx::resource::upstream { 'riemann-websocket':
    members => [
      'localhost:5556',
    ],
  }

  nginx::resource::upstream { 'riemann-sse':
    members => [
      'localhost:5558',
    ],
  }
  
  nginx::resource::map { 'ws_sse':
    expression => '$http_upgrade$http_accept',
    variable   => '$my_upstream',
    map => {
      'default'           => 'riemann-dash', 
      '~websocket'         => 'riemann-websocket', 
      '~text/event-stream' => 'riemann-sse' 
    }
  }

  nginx::resource::vhost { 'riemann-dash.hoccer.de':
    proxy                => 'http://$my_upstream',
    listen_port          => 443,
    ssl                  => true,
    ssl_cert             => '/etc/ssl/certs/star.hoccer.de.crt',
    ssl_key              => '/etc/ssl/private/star.hoccer.de.key',
    ssl_port             => 443,
    ssl_protocols        => 'TLSv1 TLSv1.1 TLSv1.2',
    auth_basic           => 'Riemann-Dash',
    auth_basic_user_file => '/etc/riemann-dash.htpasswd',
    proxy_set_header     => [
      'Upgrade $http_upgrade',
      'Connection "upgrade"',
      'X-Real-IP $remote_addr',
      'Host $host',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
    ],
    vhost_cfg_append     => {
      'proxy_http_version' => '1.1',
      'proxy_buffering'    => 'off',
      'satisfy'            => 'any',
    },
    location_allow       => [
      '10.1.0.0/22',
      '10.1.5.0/24',
      '10.1.8.0/24',
    ],
  }


}

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


  nginx::resource::upstream { 'nagios':
    members => [
      'localhost:8443',
    ],
  }

  nginx::resource::vhost { 'nagios.hoccer.de':
    proxy => 'http://nagios',
    listen_port          => 443,
    ssl                  => true,
    ssl_cert             => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    ssl_key              => '/etc/ssl/private/ssl-cert-snakeoil.key',
    ssl_port             => 443,
  }

  nginx::resource::upstream { 'ntop':
    members => [
      'localhost:3000',
    ],
  }

  nginx::resource::vhost { 'ntop.hoccer.de':
    proxy => 'http://ntop',
    listen_port          => 443,
    ssl                  => true,
    ssl_cert             => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    ssl_key              => '/etc/ssl/private/ssl-cert-snakeoil.key',
    ssl_port             => 443,
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

  nginx::resource::vhost { 'riemann-dash.hoccer.de':
    proxy => 'http://riemann-websocket',
    listen_port          => 443,
    ssl                  => true,
    ssl_cert             => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    ssl_key              => '/etc/ssl/private/ssl-cert-snakeoil.key',
    ssl_port             => 443,
    proxy_set_header     => [
      'Upgrade $http_upgrade',
      'Connection "upgrade"',
      'X-Real-IP $remote_addr',
      'Host $host',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
    ],
    location_conditions  => [
      'if ($http_upgrade = "websocket") {
          proxy_pass http://riemann-websocket;
      }',
      'if ($http_upgrade != "websocket") {
          proxy_pass http://riemann-dash;
      }',
    ],
    vhost_cfg_append     => {
      'proxy_http_version' => '1.1',
    },
  }


}

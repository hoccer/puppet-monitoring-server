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


}

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

}

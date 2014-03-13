class monitoring-server::config {

  file { '/etc/riemann.config':
    owner  => root,
    group  => root,
    mode   => 440,
    source => 'puppet:///modules/monitoring-server/riemann/riemann.config',
  }

}

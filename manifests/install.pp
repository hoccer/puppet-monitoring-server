class monitoring-server::install {

  class { 'riemann':
    config_file => '/etc/riemann.config',
    version     => '0.2.4'
  }

  include riemann
  include riemann::dash
  include riemann::tools

}


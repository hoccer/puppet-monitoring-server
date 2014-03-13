class monitoring-server::install {

  class { 'riemann':
    config_file => '/etc/riemann.config'
  }

  include riemann
  include riemann::dash
  include riemann::tools

}


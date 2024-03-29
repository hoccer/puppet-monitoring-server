class monitoring-server::install {

  class { 'riemann':
    config_file => '/etc/riemann.config',
    version     => '0.2.4',
  }

  class { 'riemann::dash':
    rvm_ruby_string => 'ruby-2.0.0-p353'
  }

  class { 'riemann::tools':
    rvm_ruby_string => 'ruby-2.0.0-p353'
  }


  class { 'nginx': }


  include riemann
  include riemann::dash
  include riemann::tools
  include nginx

}


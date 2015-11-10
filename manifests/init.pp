class facette (
  Optional[Hash] $config = undef,
  Optional[Hash[String, Hash]] $providers = undef,
  Optional[Hash] $state = undef,
) inherits facette::params {

  apt::ppa { 'ppa:facette/ppa': }

  $_config = merge($::facette::config_defaults, $config)
  $_state = merge($::facette::state_defaults, $state)
  $_file_opts = { 'owner' => 'root', 'group' => 'root', 'mode' => '0644' }

  package { 'facette':
    ensure  => $_state['package'],
    notify  => Service['facette'],
    require => Apt::Ppa['ppa:facette/ppa'],
  }

  shellvar { 'enable facette':
    ensure   => present,
    target   => '/etc/default/facette',
    variable => 'ENABLED',
    value    => 'true', # lint:ignore:quoted_booleans
    require  => Package['facette'],
    notify   => Service['facette'],
  }

  service { 'facette':
    ensure => $_state['service'],
    enable => true,
  }

  file { 'facette.json':
    ensure  => file,
    path    => '/etc/facette/facette.json',
    content => template('facette/facette.json.erb'),
    require => Package['facette'],
    notify  => Service['facette'],
    *       => $_file_opts,
  }

  if $providers {
    $providers.each |$provider, $conf| {
      file { "facette-${provider}.json":
        ensure  => file,
        path    => "/etc/facette/providers/${provider}.json",
        content => template('facette/provider.json.erb'),
        require => Package['facette'],
        notify  => Service['facette'],
        *       => $_file_opts,
      }
    }
  }
}

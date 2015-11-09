class facette (
  Optional[Hash] $config = undef,
  Optional[Hash[String, Hash]] $providers = undef,
) inherits facette::params {

  apt::ppa { 'ppa:facette/ppa': }

  $_config = merge($::facette::config_defaults, $config)
  $_file_opts = { 'owner' => 'root', 'group' => 'root', 'mode' => '0644' }

  package { 'facette':
    ensure => latest,
    notify => Service['facette'],
  }

  shellvar { 'enable facette':
    ensure   => present,
    target   => '/etc/default/facette',
    variable => 'ENABLED',
    value    => 'true',
    require  => Package['facette'],
    notify   => Service['facette'],
  }

  service { 'facette':
    ensure => running,
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

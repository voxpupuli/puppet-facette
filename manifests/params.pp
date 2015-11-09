class facette::params {
  if $::lsbdistid != 'Ubuntu' {
    fail('This module only supports Ubuntu')
  }

  $config_defaults = {
    'bind'          => ':12003',
    'base_dir'      => '/usr/share/facette',
    'providers_dir' => '/etc/facette/providers',
    'data_dir'      => '/var/lib/facette',
    'pid_file'      => '/var/run/facette/facette.pid',
  }
}

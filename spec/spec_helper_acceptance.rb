require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

hosts.each do |_host|
  # Install Puppet
  install_puppet({
      version: '4.2.3',
      puppet_agent_version: '1.2.7'
  })
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(source: proj_root, module_name: 'facette')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0]
      on host, puppet('module', 'install', 'puppetlabs-apt'), acceptable_exit_codes: [0]
      on host, puppet('module', 'install', 'herculesteam-augeasproviders_shellvar'), acceptable_exit_codes: [0]
    end
  end
end

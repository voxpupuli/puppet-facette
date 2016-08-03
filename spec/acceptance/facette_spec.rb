require 'spec_helper_acceptance'

describe 'facette class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
        package { 'software-properties-common': ensure => latest }
        include apt
        include facette
        Package['software-properties-common'] -> Class['apt']
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('facette') do
      it { should be_installed }
    end

    describe service('facette') do
      it { should be_running }
    end

    describe port(12003) do
      it { should be_listening }
    end
  end
end

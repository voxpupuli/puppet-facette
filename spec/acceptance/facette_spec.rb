require 'spec_helper_acceptance'

describe 'facette class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
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
      it { is_expected.to be_installed }
    end

    describe service('facette') do
      it { is_expected.to be_running }
    end

    describe port(12_003) do
      it { is_expected.to be_listening }
    end
  end
end

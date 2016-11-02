require 'spec_helper'

describe 'facette' do
  let :pre_condition do
    'include apt'
  end

  describe 'on Ubuntu' do
    let(:facts) do
      {
        lsbdistcodename:     'trusty',
        lsbdistrelease:      '14.04',
        lsbmajdistrelease:   '14.04',
        lsbdistdescription:  'Ubuntu 14.04.3 LTS',
        lsbdistid:           'Ubuntu',
        osfamily:            'Debian',
        operatingsystem:     'Ubuntu'
      }
    end

    context 'defaults' do
      it { is_expected.to contain_apt__ppa('ppa:facette/ppa') }
      it { is_expected.to contain_class('facette') }
      it { is_expected.to contain_class('facette::params') }
      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_package('facette').with(
          ensure: 'installed',
          notify: 'Service[facette]',
          require: 'Apt::Ppa[ppa:facette/ppa]'
        )
      end

      it do
        is_expected.to contain_shellvar('enable facette').with(
          ensure: 'present',
          target: '/etc/default/facette',
          variable: 'ENABLED',
          value: 'true',
          require: 'Package[facette]',
          notify: 'Service[facette]'
        )
      end

      it do
        is_expected.to contain_service('facette').with(
          ensure: 'running',
          enable: true
        )
      end

      it do
        is_expected.to contain_file('facette.json').with(
          ensure: 'file',
          path: '/etc/facette/facette.json',
          require: 'Package[facette]',
          notify: 'Service[facette]',
          owner: 'root',
          group: 'root',
          mode: '0644'
        ).with_content(
          %r{"bind": ".+"}
        ).with_content(
          %r{"base_dir": ".+"}
        ).with_content(
          %r{"providers_dir": ".+"}
        ).with_content(
          %r{"data_dir": ".+"}
        ).with_content(
          %r{"pid_file": ".+"}
        )
      end
    end

    context 'with package state set to purged' do
      let(:params) { { state: { 'package' => 'purged' } } }
      it { is_expected.to contain_package('facette').with_ensure('purged') }
    end

    context 'with service state set to stopped' do
      let(:params) { { state: { 'service' => 'stopped' } } }
      it { is_expected.to contain_service('facette').with_ensure('stopped') }
    end

    context 'with config where base_dir is set to var' do
      let(:params) { { config: { 'base_dir' => '/var' } } }
      it do
        is_expected.to contain_file('facette.json').with_content(
          %r{"bind": ".+"}
        ).with_content(
          %r{"base_dir": "/var"}
        ).with_content(
          %r{"providers_dir": ".+"}
        ).with_content(
          %r{"data_dir": ".+"}
        ).with_content(
          %r{"pid_file": ".+"}
        )
      end
    end

    context 'with single provider' do
      let(:params) do
        {
          providers:
          {
            'collectd' =>
            {
              'connector' =>
              {
                'path' => '/var/lib/collectd/rrd',
                'type' => 'rrd'
              }
            }
          }
        }
      end
      it do
        is_expected.to contain_file('facette-collectd.json').with(
          ensure: 'file',
          path: '/etc/facette/providers/collectd.json',
          require: 'Package[facette]',
          notify: 'Service[facette]',
          owner: 'root',
          group: 'root',
          mode: '0644'
        ).with_content(
          %r{"connector":}
        ).with_content(
          %r{"path": "/var/lib/collectd/rrd"}
        ).with_content(
          %r{"type": "rrd"}
        )
      end
    end

    context 'with multiple providers' do
      let(:params) do
        {
          providers:
          {
            'collectd' =>
            {
              'connector' =>
              {
                'path' => '/var/lib/collectd/rrd',
                'type' => 'rrd'
              }
            },
            'influxdb' =>
            {
              'connector' =>
              {
                'type' => 'influxdb',
                'database' => 'webapps'
              }
            }
          }
        }
      end
      it do
        is_expected.to contain_file('facette-collectd.json').with(
          ensure: 'file',
          path: '/etc/facette/providers/collectd.json',
          require: 'Package[facette]',
          notify: 'Service[facette]',
          owner: 'root',
          group: 'root',
          mode: '0644'
        ).with_content(
          %r{"connector":}
        ).with_content(
          %r{"path": "/var/lib/collectd/rrd"}
        ).with_content(
          %r{"type": "rrd"}
        )
      end
      it do
        is_expected.to contain_file('facette-influxdb.json').with(
          ensure: 'file',
          path: '/etc/facette/providers/influxdb.json',
          require: 'Package[facette]',
          notify: 'Service[facette]',
          owner: 'root',
          group: 'root',
          mode: '0644'
        ).with_content(
          %r{"connector":}
        ).with_content(
          %r{"database": "webapps"}
        ).with_content(
          %r{"type": "influxdb"}
        )
      end
    end
  end

  describe 'on unsupported' do
    let(:facts) do
      {
        lsbdistcodename:    'trusty',
        lsbdistrelease:     '14.04',
        lsbmajdistrelease:  '14.04',
        lsbdistdescription: 'Ubuntu 14.04.3 LTS',
        lsbdistid:          'Banana',
        osfamily:           'Debian',
        operatingsystem:    'Ubuntu'
      }
    end
    it do
      expect { subject.call }.to raise_error(Puppet::Error, %r{This module only supports Ubuntu})
    end
  end
end

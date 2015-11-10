# Facette

## Module description
[Facette.io][1] is time series data visualization and graphing software. This
module installs and manages Facette for you.

## Setup

### What facette affects

* Facette APT PPA
* Configuration files
* Package/service/configuration for Facette
* Provider configuration

### Beginning with facette

To have Facette installed and configured out of the box simply include the
facette module:

```puppet
include facette
```

This will set up [Facette][1] but not configure any providers meaning it will
not be able to read any metrics just yet.

## Usage

### Adding providers

Defining [providers][2] registers data origins in Facette, i.e. where to find
sources and their metrics, and how to add them to the catalog.

This is done by passing a hash to the `providers` parameter. The key is the
name you want the configuration file to get on disk and the value should be
another hash with all the configuration options.

In order to get access to RRD data outputted by collectd:

```puppet
class { 'facette':
    providers => { 'collectd' => {
                    'connector' => {
                        'path' => '/var/lib/collectd/rrd',
                        'type' => 'rrd',
                 }}},
}
```

Instead of passing it in through Puppet you can use Hiera instead:

```yaml
facette::providers:
  collectd:
    connector:
      path: '/var/lib/collectd/rrd'
      type: 'rrd'
```

This will result in `/etc/facette/providers/collectd.json` to be created with
the following content:

```json
{
    "connector": {
        "path": "/var/lib/collectd/rrd",
        "type": "rrd"
    }
}
```

### Overriding facette configuration

By default a `/etc/facette/facette.json` will be created with a number of
settings. If you wish to override one of these settings simply pass a hash
to the `config` parameter.

```puppet
class { 'facette':
    config => { 'base_dir' => '/var' },
}
```

```yaml
facette::config:
  base_dir: '/var'
```

The available configuration options for Facette can be found in their
[documentation][3].

### Controlling package and service state

This module will ensure the package is installed and that the Facette service
is running. You can however tweak this behaviour by alteering the `state`
parameter.

```puppet
class { 'facette':
    state => { 'package' => 'latest', 'service' => 'stopped' }
}
```

```yaml
facette::state:
  package: 'latest'
  service: 'stopped'
```

[1]: https://facette.io
[2]: http://docs.facette.io/configuration/connectors/
[3]: http://docs.facette.io/configuration

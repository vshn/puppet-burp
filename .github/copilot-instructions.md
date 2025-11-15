# Copilot Instructions for puppet-burp

## Project Overview

This is a Puppet module for managing BURP (BackUp and Restore Program) backup software, supporting both client and server configurations. The module uses **exported resources** pattern for client-server coordination and follows traditional Puppet 3.x/4.x conventions.

## Architecture & Key Components

### Module Structure
- **`manifests/init.pp`**: Entry point, handles package installation only. Use `burp::server` or `burp::client` for actual configuration.
- **`manifests/server.pp`**: Server configuration class - manages service, CA, clientconfigs directory, and collects exported `burp::clientconfig` resources
- **`manifests/client.pp`**: Defined type for client configs (can have multiple clients on same host, e.g., `burp`, `burp-production`)
- **`manifests/clientconfig.pp`**: Defined type for server-side client configs (typically exported by clients, collected by server)
- **`manifests/extraconfig.pp`**: Allows adding extra config snippets to clients using `concat::fragment`

### Critical Design Patterns

**1. Dual Configuration Files**
BURP binary behaves differently based on config:
- Server: `/etc/burp/burp-server.conf` (passed with `-c` to service)
- Clients: `/etc/burp/${name}.conf` (default name is `burp` for easy CLI use without `-c`)

**2. Exported Resources Workflow**
Clients export `@@burp::clientconfig` resources tagged with server FQDN:
```puppet
# On client node:
burp::client { 'burp':
  server => 'backup.example.com',  # becomes tag for collection
}

# On server node:
class { 'burp::server':
  clientconfig_tag => $::fqdn,  # collects matching exports
}
```
Server collects: `::Burp::Clientconfig <<| tag == $clientconfig_tag |>>`

**3. Configuration Hash Merging**
All classes use `merge()` to combine defaults with user params:
```puppet
$_default_configuration = { ... }
$_configuration = merge($_default_configuration, $configuration)
```
User-provided keys override defaults. Arrays/hashes are replaced, not merged.

**4. Separate Data Directories**
- Config: `/etc/burp/` (controlled by `$config_dir`)
- Server data: `/var/lib/burp/` (controlled by `$user_home`)
- Client data: `/var/lib/burp-${name}/` (controlled by `$working_dir`)
- Each client has own SSL cert directory: `${working_dir}/ssl`

**5. Template Pattern**
Single template `burp.conf.erb` iterates over configuration hash:
```erb
<%- @_configuration.each do |k,v| -%>
  <%- if v.is_a?(Array) then v.each do |vv| -%>
    <%= k %> = <%= vv %>
  <%- end else -%>
    <%= k %> = <%= v %>
  <%- end end -%>
```
Array values generate multiple lines with same key.

## Development Workflows

### Testing
```bash
# Install dependencies
bundle install

# Run all tests (syntax, lint, spec, metadata)
bundle exec rake test

# Individual test suites
bundle exec rake syntax       # Puppet syntax validation
bundle exec rake lint         # puppet-lint checks
bundle exec rake spec         # rspec-puppet unit tests
bundle exec rake metadata     # metadata.json validation
```

### Puppet-lint Configuration
- 80-char limit disabled
- `class_parameter_defaults` check disabled (modern Puppet pattern)
- `class_inherits_from_params_class` disabled (params pattern deprecated)
- Warnings are treated as failures

### Writing Specs
Use `rspec-puppet` patterns with fact injection:
```ruby
describe 'burp::client' do
  let(:title) { 'burp' }
  let(:params) {{ server: 'backup.example.com' }}
  let(:facts) {{ osfamily: 'Debian' }}

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_file('/etc/burp/burp.conf') }
end
```

## Conventions & Patterns

### Parameter Validation (Modern Puppet 4+)
Use type annotations in parameter definitions instead of validate_* functions:
```puppet
define burp::client (
  Enum['present', 'absent'] $ensure = 'present',
  Stdlib::Absolutepath $working_dir = "/var/lib/burp-${name}",
  Optional[String[1]] $clientconfig_tag = undef,
  Hash $configuration = {},
  Boolean $manage_cron = true,
  Integer $cron_randomise = 850,
) {
  # No validate_* calls needed - types enforce validation
}
```

Common type patterns:
- `Boolean` for true/false values
- `String[1]` for non-empty strings
- `Stdlib::Absolutepath` for absolute file paths
- `Enum['value1', 'value2']` for restricted string values
- `Optional[Type]` for parameters that can be undef
- `Variant[Type1, Type2]` for parameters accepting multiple types
- `Integer` for numeric values
- `Hash` for configuration hashes

### Facts Access
Use modern facts hash instead of top-scope variables:
```puppet
# Modern (Puppet 4+)
$fqdn = $facts['networking']['fqdn']
$osfamily = $facts['os']['family']

# Legacy (avoid)
$fqdn = $::fqdn
$osfamily = $::osfamily
```

### File Modes & Ownership
- Config files: `$config_file_mode` (default `0600`)
- Data directories: `$homedir_file_mode` (default `0750`)
- Always set `owner`/`group` to `$user`/`$group` variables
- Scripts in `/usr/local/bin`: mode `0755`, owner `root`

### Ensure Parameter Pattern
Defined types support `ensure => absent` cleanup:
```puppet
if $ensure == present {
  $_file_ensure = file
  $_directory_ensure = directory
} else {
  $_file_ensure = absent
  $_directory_ensure = absent
}
```

### OS-Specific Handling
```puppet
case downcase($::osfamily) {
  'debian': { $_nologin = '/usr/sbin/nologin' }
  'redhat': { $_nologin = '/sbin/nologin' }
}
```
Module supports Debian, Ubuntu, RedHat, CentOS per `metadata.json`.

## Common Tasks

### Adding New Configuration Options
1. Add to `$_default_configuration` hash in relevant class
2. Document in parameter comments (users override via `$configuration` param)
3. No code changes needed - template auto-renders hash

### Adding Client Extra Config
Use `burp::extraconfig` to inject snippets via concat:
```puppet
burp::extraconfig { 'backup_opt':
  client        => 'burp',
  configuration => { 'include' => ['/opt/'] },
}
```
Writes to `/etc/burp/${client}-extra.conf`, included in main config.

### Multi-Client Setup
Create multiple named clients on one host:
```puppet
burp::client { 'prod-backup':
  server        => 'prod.backup.com',
  working_dir   => '/var/lib/burp-prod',
  configuration => { cname => $::hostname },
}
burp::client { 'dev-backup':
  server        => 'dev.backup.com',
  working_dir   => '/var/lib/burp-dev',
}
```

## Dependencies
- `puppetlabs/stdlib` (4.x) - validation functions, `fqdn_rand_string()`
- `puppetlabs/concat` (>=1.0.0) - for extraconfig fragments
- `rodjek/logrotate` (>=1.1.1) - server log rotation

## Key Files to Reference
- `examples/client.md` - Real-world profile class pattern
- `examples/server.md` - Server setup with firewall rules
- `manifests/client.pp` lines 106-142 - Default client config structure
- `manifests/server.pp` lines 162-195 - Default server config structure

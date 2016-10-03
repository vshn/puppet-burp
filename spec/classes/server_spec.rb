require 'spec_helper'

describe 'burp::server' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "server class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('burp') }
        it { is_expected.to contain_class('burp::server') }
        it { is_expected.to contain_user('burp').with_ensure('present') }
        it { is_expected.to contain_file('/etc/burp/burp-server.conf').with_ensure('file') }
        it { is_expected.to contain_file('/etc/burp/CA.cnf').with_ensure('file') }
        it { is_expected.to contain_file('/etc/burp/clients').with_ensure('directory') }
        it { is_expected.to contain_file('/etc/logrotate.d/burp').with_ensure('present') }
        it { is_expected.to contain_file('/etc/rsyslog.d/21-burp.conf').with_ensure('file') }
        it { is_expected.to contain_file('/usr/local/bin/burp_notify_script').with_ensure('file') }
        it { is_expected.to contain_file('/usr/local/bin/burp_timer_script').with_ensure('file') }
        it { is_expected.to contain_file('/usr/local/bin/burp_summary_script').with_ensure('file') }
        it { is_expected.to contain_file('/usr/local/bin/burp_ssl_extra_checks_script').with_ensure('file') }
        it { is_expected.to contain_file('/var/lib/burp').with_ensure('directory') }
        it { is_expected.to contain_augeas('/etc/default/burp') }
        it { is_expected.to contain_service('burp').with_ensure('running') }

      end
    end
  end
end

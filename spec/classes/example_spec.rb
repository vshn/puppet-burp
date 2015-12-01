require 'spec_helper'

describe 'burp' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "burp class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('burp::params') }
        it { is_expected.to contain_class('burp::install').that_comes_before('burp::config') }
        it { is_expected.to contain_class('burp::config') }
        it { is_expected.to contain_class('burp::service').that_subscribes_to('burp::config') }

        it { is_expected.to contain_service('burp') }
        it { is_expected.to contain_package('burp').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'burp class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('burp') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end

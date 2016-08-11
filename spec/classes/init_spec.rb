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

        it { is_expected.to contain_class('burp::install').that_comes_before('Class[burp::config]') }
        it { is_expected.to contain_class('burp::config') }
        it { is_expected.to contain_class('burp') }

        it { is_expected.to contain_file('/etc/burp').with_ensure('directory') }
        it { is_expected.to contain_package('burp').with_ensure('installed') }
      end
    end
  end
end

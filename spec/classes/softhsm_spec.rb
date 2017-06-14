# frozen_string_literal: true

require 'spec_helper'

describe 'softhsm' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'softhsm.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      #:package => "softhsm2",
      #:conf_file => "/etc/softhsm/softhsm2.conf",
      #:tokendir => "/var/lib/softhsm/tokens/",
      #:objectstore => "file",
      #:log_level => "info",
      tokens: {
        'test_token' => {
          'pin'    => '1234',
          'so_pin' => '1234'
        }
      }
    }
  end

  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:lsbdistcodename]
      when 'trusty'
        let(:version)   { 1 }
        let(:package)   { 'softhsm' }
        let(:utils_cmd) { 'softhsm' }
        let(:conf_file) { '/etc/softhsm/softhsm.conf' }
      else
        let(:version)   { 2 }
        let(:package)   { 'softhsm2' }
        let(:utils_cmd) { 'softhsm2-util' }
        let(:conf_file) { '/etc/softhsm/softhsm2.conf' }
      end

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('softhsm') }
        it { is_expected.to contain_class('softhsm::params') }
        it { is_expected.to contain_package(package) }
        it do
          is_expected.to contain_file(
            '/var/lib/softhsm/tokens/'
          ).with_ensure('directory')
        end
        if facts[:lsbdistcodename] == 'xenial'
          it do
            is_expected.to contain_file(conf_file).with_ensure(
              'file'
            ).with_content(
              %r{directories.tokendir = /var/lib/softhsm/tokens/}
            ).with_content(
              %r{objectstore.backend = file}
            ).with_content(
              %r{log.level = INFO}
            )
          end
          it do
            is_expected.to contain_exec("#{utils_cmd} init test_token").with(
              'path' => ['/usr/bin', '/bin'],
              'command' => "#{utils_cmd} --init-token --free --pin 1234 --so-pin 1234 --label test_token"
            )
          end
        else
          it do
            is_expected.to contain_file(conf_file).with_ensure(
              'file'
            ).with_content(%r{0:/var/lib/softhsm/tokens/test_token.db})
          end
          it do
            is_expected.to contain_exec("#{utils_cmd} init test_token").with(
              'path' => ['/usr/bin', '/bin'],
              'command' => "#{utils_cmd} --init-token --slot 0 --pin 1234 --so-pin 1234 --label test_token"
            )
          end
        end
      end
      describe 'Change Defaults' do
        context 'package' do
          before { params.merge!(package: 'foobar') }
          it { is_expected.to compile }
          it { is_expected.to contain_package('foobar') }
        end
        context 'utils_cmd' do
          before { params.merge!(utils_cmd: 'foobar') }
          it { is_expected.to compile }
          if facts[:lsbdistcodename] == 'xenial'
            it do
              is_expected.to contain_exec('foobar init test_token').with(
                'path' => ['/usr/bin', '/bin'],
                'command' => 'foobar --init-token --free --pin 1234 --so-pin 1234 --label test_token'
              )
            end
          else
            it do
              is_expected.to contain_exec('foobar init test_token').with(
                'path' => ['/usr/bin', '/bin'],
                'command' => 'foobar --init-token --slot 0 --pin 1234 --so-pin 1234 --label test_token'
              )
            end
          end
        end
        context 'conf_file' do
          before { params.merge!(conf_file: '/foobar.conf') }
          it { is_expected.to compile }
          it { is_expected.to contain_file('/foobar.conf').with_ensure('file') }
        end
        context 'tokendir' do
          before { params.merge!(tokendir: '/foobar') }
          it { is_expected.to compile }
          it { is_expected.to contain_file('/foobar').with_ensure('directory') }
          if facts[:lsbdistcodename] == 'xenial'
            it do
              is_expected.to contain_file(conf_file).with_ensure(
                'file'
              ).with_content(
                %r{directories.tokendir = /foobar}
              )
            end
          end
        end
        context 'objectstore' do
          before { params.merge!(objectstore: 'db') }
          it { is_expected.to compile }
          if facts[:lsbdistcodename] == 'xenial'
            it do
              is_expected.to contain_file(conf_file).with_ensure(
                'file'
              ).with_content(
                %r{objectstore.backend = db}
              )
            end
          end
        end
        context 'tokens' do
          before do
            params.merge!(
              tokens: {
                'token0' => { 'pin' => '0000', 'so_pin' => '0000' },
                'token1' => { 'pin' => '1111', 'so_pin' => '1111' }
              }
            )
          end
          it { is_expected.to compile }
          if facts[:lsbdistcodename] == 'trusty'
            it do
              is_expected.to contain_file(conf_file).with_ensure(
                'file'
              ).with_content(
                %r{0:/var/lib/softhsm/tokens/token0.db}
              ).with_content(
                %r{1:/var/lib/softhsm/tokens/token1.db}
              )
            end
            it do
              is_expected.to contain_exec("#{utils_cmd} init token1").with(
                'path' => ['/usr/bin', '/bin'],
                'command' => "#{utils_cmd} --init-token --slot 1 --pin 1111 --so-pin 1111 --label token1"
              )
            end
            it do
              is_expected.to contain_exec("#{utils_cmd} init token0").with(
                'path' => ['/usr/bin', '/bin'],
                'command' => "#{utils_cmd} --init-token --slot 0 --pin 0000 --so-pin 0000 --label token0"
              )
            end
          else
            it do
              is_expected.to contain_exec("#{utils_cmd} init token1").with(
                'path' => ['/usr/bin', '/bin'],
                'command' => "#{utils_cmd} --init-token --free --pin 1111 --so-pin 1111 --label token1"
              )
            end
            it do
              is_expected.to contain_exec("#{utils_cmd} init token0").with(
                'path' => ['/usr/bin', '/bin'],
                'command' => "#{utils_cmd} --init-token --free --pin 0000 --so-pin 0000 --label token0"
              )
            end
          end
        end
        context 'log_level' do
          before { params.merge!(log_level: 'error') }
          it { is_expected.to compile }
          if facts[:lsbdistcodename] == 'xenial'
            it do
              is_expected.to contain_file(conf_file).with_ensure(
                'file'
              ).with_content(
                %r{log.level = ERROR}
              )
            end
          end
        end
      end
      describe 'check bad type' do
        context 'package' do
          before { params.merge!(package: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'conf_file' do
          before { params.merge!(conf_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tokendir' do
          before { params.merge!(tokendir: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'objectstore' do
          before { params.merge!(objectstore: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'log_level' do
          before { params.merge!(log_level: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'tokens' do
          before { params.merge!(tokens: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end

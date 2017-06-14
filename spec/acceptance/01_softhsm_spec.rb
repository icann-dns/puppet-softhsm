# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'softhsm class' do
  case fact('lsbdistcodename')
  when 'trusty'
    utils_cmd = 'softhsm'
    end_marker = %r{$}
  else
    utils_cmd = 'softhsm2-util'
    end_marker = %r{^Slot 1}
  end
  context 'defaults' do
    it 'work with no errors' do
      pp = <<EOS
      class {'::softhsm':
        tokens => {
          'test' => {
            'pin' => '1111',
            'so_pin' => '1111',
          },
        },
      }
EOS
      apply_manifest(pp, catch_failures: true)
      expect(apply_manifest(pp, catch_failures: true).exit_code).to eq 0
    end
    describe command("#{utils_cmd} --show-slots") do
      its(:stdout) do
        is_expected.to contain(
          %r{[iI]nitialized:\s+yes}
        ).from(%r{^Slot 0}).to(end_marker)
      end
      its(:stdout) do
        is_expected.to contain(
          %r{User PIN init(ialized|\.):\s+yes}
        ).from(%r{^Slot 0}).to(end_marker)
      end
      its(:stdout) do
        is_expected.to contain(
          %r{[Ll]abel:\s+test}
        ).from(%r{^Slot 0}).to(end_marker)
      end
    end
  end
end

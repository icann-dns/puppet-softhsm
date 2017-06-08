# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'opendnssec class' do
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
    describe command('softhsm2-util --show-slots') do
      its(:stdout) do
        is_expected.to contain(
          %r{Initialized:\s+yes}
        ).from(%r{^Slot 0}).to(%r{^Slot 1})
      end
      its(:stdout) do
        is_expected.to contain(
          %r{User PIN init\.:\s+yes}
        ).from(%r{^Slot 0}).to(%r{^Slot 1})
      end
      its(:stdout) do
        is_expected.to contain(
          %r{Label:\s+test}
        ).from(%r{^Slot 0}).to(%r{^Slot 1})
      end
    end
  end
end

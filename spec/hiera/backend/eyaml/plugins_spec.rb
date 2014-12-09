require 'spec/spec_helper'
require 'hiera/backend/eyaml/plugins'
require 'hiera/backend/eyaml/utils'


class Hiera
  module Backend
    module Eyaml

      class Plugins
        def self.clear_options
          @@options = []
        end
      end

      describe Plugins do

        let(:plugin_option_1) { {
            :option_1 => { :desc => 'Test option 1',
                           :type => :string,
                           :default => 'testing123' }
        } }

        describe '.register_options' do

          before(:each) do
            Plugins.clear_options
          end

          after(:each) do
            Plugins.clear_options
          end

          it 'adds option to options hash' do
            Plugins.register_options :options => plugin_option_1, :plugin => ''

            expect(Plugins.options.count).to be 1
          end

          it 'prefixes plugin name to option name' do
            Plugins.register_options :options => plugin_option_1, :plugin => 'testing'
            option = Plugins.options.first

            expect(option[:name]).to eq 'testing_option_1'
          end

          it 'merges properties into option' do
            Plugins.register_options :options => plugin_option_1, :plugin => ''
            option = Plugins.options.first

            expect(option[:desc]).to eq 'Test option 1'
            expect(option[:type]).to eq :string
            expect(option[:default]).to eq 'testing123'
          end

          it 'warns about duplicate options' do
            Hiera::Backend::Eyaml::Utils.expects(:warn).with('Duplicate option option_1 for tester plugin').once

            Plugins.register_options :options => plugin_option_1, :plugin => 'tester'
            Plugins.register_options :options => plugin_option_1, :plugin => 'tester'
          end

        end

      end

    end
  end
end

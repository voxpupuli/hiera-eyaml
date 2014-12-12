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
        def self.clear_plugins
          @@plugins = []
        end
      end

      describe Plugins do

        before(:each) do
          Plugins.clear_options
          Plugins.clear_plugins
        end

        after(:each) do
          Plugins.clear_options
          Plugins.clear_plugins
        end

        describe '.register_options' do

          let(:plugin_option_1) {
            { :option_1 => { :desc => 'Test option 1', :type => :string, :default => 'testing123' } }
          }

          let(:plugin_option_2) {
            { :option_2 => { :desc => 'Test option 2', :type => :string, :default => 'testing456' } }
          }

          def option_occurrences(options, name)
            options.select { |option| option[:name] == name }.count
          end

          it 'adds option to options array' do
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

          it 'adds multiple options to options array' do
            options = plugin_option_1.merge plugin_option_2
            Plugins.register_options :options => options, :plugin => 'tester'

            expect(Plugins.options.count).to eq 2
            expect(option_occurrences(Plugins.options, 'tester_option_1')).to eq 1
            expect(option_occurrences(Plugins.options, 'tester_option_2')).to eq 1
          end

          it 'warns about duplicate options' do
            Hiera::Backend::Eyaml::Utils.expects(:warn).with('Duplicate option option_1 for tester plugin').once

            Plugins.register_options :options => plugin_option_1, :plugin => 'tester'
            Plugins.register_options :options => plugin_option_1, :plugin => 'tester'
          end

        end

        describe '.find' do

          let(:gem_specs) { [] }
          let(:gem_spec_1) { mock('Gem::Specification') }
          let(:file_path) { '/path/to/plugin_file' }

          before(:each) do
            gem_spec_1.stubs(:name).returns('spec_1')
            gem_specs << gem_spec_1
            Hiera::Backend::Eyaml::Utils.stubs(:find_gem_specs).returns(gem_specs)
            Hiera::Backend::Eyaml::Utils.stubs(:find_file_in_gem).returns(nil)
            Hiera::Backend::Eyaml::Plugins.stubs(:load)
          end

          context 'when a gem does not contain plugin file' do
            it 'excludes gem_spec from plugins list' do
              Plugins.find
              expect(Plugins.plugins.count).to eq 0
            end
          end

          context 'when a gem contains plugin file' do
            before(:each) do
              Hiera::Backend::Eyaml::Utils.stubs(:find_file_in_gem).returns(file_path)
            end

            it 'adds gem_spec to plugins list' do
              Plugins.find
              expect(Plugins.plugins.count).to eq 1
              expect(Plugins.plugins.first.name).to eq gem_spec_1.name
            end

            it 'loads the plugin file' do
              Hiera::Backend::Eyaml::Plugins.expects(:load).with(file_path).once
              Plugins.find
            end
          end

          context 'when a plugin gem is listed more than once' do
            it 'only includes the gem once' do
              gem_specs << gem_spec_1
              Hiera::Backend::Eyaml::Utils.stubs(:find_file_in_gem).returns(file_path)
              Plugins.find
              expect(Plugins.plugins.count).to eq 1
            end
          end
        end

      end
    end
  end
end

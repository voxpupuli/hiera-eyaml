require 'spec/spec_helper'
require 'hiera/backend/eyaml/subcommands'

class Hiera
  module Backend
    module Eyaml

      module Subcommands
        def self.get_subcommands
          @@subcommands
        end
        def self.set_subcommands(subcommands)
          @@subcommands = subcommands
        end

        class Command1
        end
        class Command2
        end
        class Command3
        end
      end

      describe 'Subcommands' do

        let(:subcommand_hash) {
          {
              'command1' => Hiera::Backend::Eyaml::Subcommands::Command1,
              'command2' => Hiera::Backend::Eyaml::Subcommands::Command2,
          }
        }
        let(:subcommand_classes) {
          [
              Hiera::Backend::Eyaml::Subcommands::Command1,
              Hiera::Backend::Eyaml::Subcommands::Command2,
              Hiera::Backend::Eyaml::Subcommands::Command3,
          ]
        }

        describe '.names' do
          it 'returns the array of command names' do
            Subcommands.set_subcommands subcommand_hash
            subcommands = Subcommands.names
            expect(subcommands).to be_an Array
            expect(subcommands).to include('command1', 'command2')
          end
        end

        describe '.classes' do
          it 'returns the array of command classes' do
            Subcommands.set_subcommands subcommand_hash
            classes = Subcommands.classes
            expect(classes).to be_an Array
            expect(classes).to include(Hiera::Backend::Eyaml::Subcommands::Command1)
            expect(classes).to include(Hiera::Backend::Eyaml::Subcommands::Command2)
          end
        end

        describe '.class_for' do
          it 'returns the subcommand class' do
            Subcommands.set_subcommands subcommand_hash
            subcommand = Subcommands.class_for('command2')
            expect(subcommand).to eq Hiera::Backend::Eyaml::Subcommands::Command2
          end
        end

        describe '.parse' do

          before(:each) do
            Utils.stubs(:require_dir)
            Utils.stubs(:find_all_subclasses_of).returns subcommand_classes
          end

          it 'requires all subcommands' do
            Utils.expects(:require_dir).with('hiera/backend/eyaml/subcommands').once
            Subcommands.parse
          end

          it 'adds all subcommmands to list' do
            Subcommands.parse
            expect(Subcommands.get_subcommands.count).to eq subcommand_classes.count
          end

          it 'uses subcommand name as key' do
            Subcommands.parse
            expect(Subcommands.get_subcommands).to include('command1', 'command2', 'command3')
          end

          it 'uses subcommand class as value' do
            Subcommands.parse
            expect(Subcommands.get_subcommands['command1']).to eq Hiera::Backend::Eyaml::Subcommands::Command1
          end
        end

      end
    end
  end
end

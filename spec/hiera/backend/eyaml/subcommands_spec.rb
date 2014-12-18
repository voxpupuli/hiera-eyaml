require 'spec_helper'
require 'hiera/backend/eyaml/subcommands'
require 'hiera/backend/eyaml/subcommands/unknown_command'

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
        class CommandThree
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
              Hiera::Backend::Eyaml::Subcommands::CommandThree,
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

        describe '.find_all' do

          before(:each) do
            Utils.stubs(:require_dir)
            Utils.stubs(:find_all_subclasses_of).returns subcommand_classes
          end

          it 'requires all subcommands' do
            Utils.expects(:require_dir).with('hiera/backend/eyaml/subcommands').once
            Subcommands.find_all
          end

          it 'adds all subcommmands to list' do
            Subcommands.find_all
            expect(Subcommands.get_subcommands.count).to eq subcommand_classes.count
          end

          it 'uses subcommand name as key' do
            Subcommands.find_all
            expect(Subcommands.get_subcommands).to include('command1', 'command2')
          end

          it 'converts subcommand name to snake case' do
            Subcommands.find_all
            expect(Subcommands.get_subcommands).to include('command_three')
          end

          it 'uses subcommand class as value' do
            Subcommands.find_all
            expect(Subcommands.get_subcommands['command1']).to eq Hiera::Backend::Eyaml::Subcommands::Command1
          end
        end

        describe '.find_and_use' do

          before(:each) do
            Subcommands.stubs(:require)
            Subcommands.stubs(:class_for).returns Subcommands::Command1
          end

          context 'when subcommand class loads without failure' do

            let(:subcommand) { 'command1' }

            before(:each) do
              Subcommands.stubs(:require).returns(true)
            end

            it 'loads subcommands class' do
              Subcommands.expects(:require).with(regexp_matches(/#{subcommand}$/)).once
              Subcommands.find_and_use subcommand
            end

            it 'returns the subcommand class' do
              Subcommands.stubs(:class_for).with(subcommand).returns Subcommands::Command1
              command_class = Subcommands.find_and_use subcommand
              expect(command_class).to eq Subcommands::Command1
            end
          end

          context 'when subcommand class load fails' do

            let(:subcommand) { 'non_ex_command' }

            before(:each) do
              Subcommands.stubs(:require).raises(LoadError).then.returns(true)
            end

            it 'tries to load command class' do
              Subcommands.expects(:require).with(regexp_matches(/#{subcommand}$/)).once
              Subcommands.find_and_use subcommand
            end

            it 'falls back to unknown_command' do
              Subcommands.expects(:require).with(regexp_matches(/unknown_command$/)).once
              Subcommands.find_and_use subcommand
            end

            it 'returns unknown_command class' do
              Subcommands.stubs(:class_for).with('unknown_command').returns Subcommands::UnknownCommand
              command_class = Subcommands.find_and_use subcommand
              expect(command_class).to eq Subcommands::UnknownCommand
            end
          end
        end

        describe '.each' do

          let(:consumer) { mock('Object') }

          it 'yields each subcommand name and class' do
            Subcommands.set_subcommands subcommand_hash
            consumer.expects(:consume).with('command1', Subcommands::Command1).once
            consumer.expects(:consume).with('command2', Subcommands::Command2).once
            Subcommands.each { |name, klass|
              consumer.consume name, klass
            }
          end
        end

        describe '.collect' do

          it 'yields each subcommand name and class' do
            Subcommands.set_subcommands subcommand_hash
            results = Subcommands.collect { |name, klass|
              "#{name}=#{klass.to_s}"
            }
            expect(results).to include('command1=Hiera::Backend::Eyaml::Subcommands::Command1')
            expect(results).to include('command2=Hiera::Backend::Eyaml::Subcommands::Command2')
          end
        end

      end
    end
  end
end

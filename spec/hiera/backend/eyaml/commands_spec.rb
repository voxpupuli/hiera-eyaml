require 'spec_helper'
require 'hiera/backend/eyaml/commands'
require 'hiera/backend/eyaml/commands/unknown_command'

class Hiera
  module Backend
    module Eyaml

      module Commands
        def self.get_commands
          @@commands
        end
        def self.set_commands(commands)
          @@commands = commands
        end

        class Command1
        end
        class Command2
        end
        class CommandThree
        end
      end

      describe 'Commands' do

        let(:command_hash) {
          {
              'command1' => Hiera::Backend::Eyaml::Commands::Command1,
              'command2' => Hiera::Backend::Eyaml::Commands::Command2,
          }
        }
        let(:command_classes) {
          [
              Hiera::Backend::Eyaml::Commands::Command1,
              Hiera::Backend::Eyaml::Commands::Command2,
              Hiera::Backend::Eyaml::Commands::CommandThree,
          ]
        }

        describe '.names' do
          it 'returns the array of command names' do
            Commands.set_commands command_hash
            commands = Commands.names
            expect(commands).to be_an Array
            expect(commands).to include('command1', 'command2')
          end
        end

        describe '.classes' do
          it 'returns the array of command classes' do
            Commands.set_commands command_hash
            classes = Commands.classes
            expect(classes).to be_an Array
            expect(classes).to include(Hiera::Backend::Eyaml::Commands::Command1)
            expect(classes).to include(Hiera::Backend::Eyaml::Commands::Command2)
          end
        end

        describe '.class_for' do
          it 'returns the command class' do
            Commands.set_commands command_hash
            command = Commands.class_for('command2')
            expect(command).to eq Hiera::Backend::Eyaml::Commands::Command2
          end
        end

        describe '.find_all' do

          before(:each) do
            Utils.stubs(:require_dir)
            Utils.stubs(:find_all_subclasses_of).returns command_classes
          end

          it 'requires all commands' do
            Utils.expects(:require_dir).with('hiera/backend/eyaml/commands').once
            Commands.find_all
          end

          it 'adds all subcommmands to list' do
            Commands.find_all
            expect(Commands.get_commands.count).to eq command_classes.count
          end

          it 'uses command name as key' do
            Commands.find_all
            expect(Commands.get_commands).to include('command1', 'command2')
          end

          it 'converts command name to snake case' do
            Commands.find_all
            expect(Commands.get_commands).to include('command_three')
          end

          it 'uses command class as value' do
            Commands.find_all
            expect(Commands.get_commands['command1']).to eq Hiera::Backend::Eyaml::Commands::Command1
          end
        end

        describe '.find_and_use' do

          before(:each) do
            Commands.stubs(:require)
            Commands.stubs(:class_for).returns Commands::Command1
          end

          context 'when command class loads without failure' do

            let(:command) { 'command1' }

            before(:each) do
              Commands.stubs(:require).returns(true)
            end

            it 'loads commands class' do
              Commands.expects(:require).with(regexp_matches(/#{command}$/)).once
              Commands.find_and_use command
            end

            it 'returns the command class' do
              Commands.stubs(:class_for).with(command).returns Commands::Command1
              command_class = Commands.find_and_use command
              expect(command_class).to eq Commands::Command1
            end
          end

          context 'when command class load fails' do

            let(:command) { 'non_ex_command' }

            before(:each) do
              Commands.stubs(:require).raises(LoadError).then.returns(true)
            end

            it 'tries to load command class' do
              Commands.expects(:require).with(regexp_matches(/#{command}$/)).once
              Commands.find_and_use command
            end

            it 'falls back to unknown_command' do
              Commands.expects(:require).with(regexp_matches(/unknown_command$/)).once
              Commands.find_and_use command
            end

            it 'returns unknown_command class' do
              Commands.stubs(:class_for).with('unknown_command').returns Commands::UnknownCommand
              command_class = Commands.find_and_use command
              expect(command_class).to eq Commands::UnknownCommand
            end
          end
        end

        describe '.each' do

          let(:consumer) { mock('Object') }

          it 'yields each command name and class' do
            Commands.set_commands command_hash
            consumer.expects(:consume).with('command1', Commands::Command1).once
            consumer.expects(:consume).with('command2', Commands::Command2).once
            Commands.each { |name, klass|
              consumer.consume name, klass
            }
          end
        end

        describe '.collect' do

          it 'yields each command name and class' do
            Commands.set_commands command_hash
            results = Commands.collect { |name, klass|
              "#{name}=#{klass.to_s}"
            }
            expect(results).to include('command1=Hiera::Backend::Eyaml::Commands::Command1')
            expect(results).to include('command2=Hiera::Backend::Eyaml::Commands::Command2')
          end
        end

      end
    end
  end
end

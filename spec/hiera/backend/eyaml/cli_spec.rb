require 'spec_helper'
require 'hiera/backend/eyaml/CLI'
require 'hiera/backend/eyaml/encryptors/pkcs7'

class Hiera
  module Backend
    module Eyaml
      describe CLI do

        describe '.parse' do

          let(:command_arg) { 'command_arg' }
          let(:option_arg) { 'option_arg' }
          let(:command_class) { mock('Eyaml::Command') }

          before(:each) do
            Eyaml::Commands.stubs(:find_all)
            Eyaml::Commands.stubs(:find_and_use).returns command_class
            Eyaml::Commands.stubs(:names).returns [command_arg]
            command_class.stubs(:parse).returns({})
            command_class.stubs(:validate).returns({})
            Eyaml::Options.stubs(:set)
            Eyaml::Options.stubs(:trace)
            ARGV.clear
            ARGV.push command_arg
            ARGV.push option_arg
          end

          it 'finds all commands' do
            Eyaml::Commands.expects(:find_all).once
            CLI.parse
          end

          it 'reads eyaml command from ARGV' do
            CLI.parse
            expect(Eyaml::Commands.input).to eq command_arg
          end

          it 'cleans user input' do
            ARGV.clear
            ARGV.push 'CoMMand_Arg'
            Eyaml::Commands.expects(:find_and_use).with(command_arg).once.returns command_class
            CLI.parse
          end

          it 'uses the command class specified by command_arg' do
            Eyaml::Commands.expects(:find_and_use).with(command_arg).once.returns command_class
            CLI.parse
          end

          context 'when command_arg is nil' do
            before(:each) do
              ARGV.clear
              ARGV.push nil
              ARGV.push option_arg
            end

            it 'sets commands input to empty string' do
              CLI.parse
              expect(Eyaml::Commands.input).to eq ''
            end

            it 'uses the UnknownCommand class' do
              Eyaml::Commands.expects(:find_and_use).with('unknown_command').once.returns command_class
              CLI.parse
            end

            it 'clears the arguments array' do
              CLI.parse
              expect(ARGV.count).to eq 0
            end
          end

          context 'when command_arg starts with a dash' do
            before(:each) do
              ARGV.clear
              ARGV.push '-blah'
              ARGV.push option_arg
            end

            it 'uses the Help command' do
              Eyaml::Commands.expects(:find_and_use).with('help').once.returns command_class
              CLI.parse
            end

            it 'clears the arguments array' do
              CLI.parse
              expect(ARGV.count).to eq 0
            end
          end

          context 'when command_arg is not recognised' do
            before(:each) do
              ARGV.clear
              ARGV.push 'random_arg'
              ARGV.push option_arg
            end

            it 'uses the UnknownCommand class' do
              Eyaml::Commands.expects(:find_and_use).with('unknown_command').once.returns command_class
              CLI.parse
            end

            it 'clears the arguments array' do
              CLI.parse
              expect(ARGV.count).to eq 0
            end
          end
        end

      end
    end
  end
end

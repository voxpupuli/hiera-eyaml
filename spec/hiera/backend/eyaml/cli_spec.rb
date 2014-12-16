require 'spec/spec_helper'
require 'hiera/backend/eyaml/CLI'
require 'hiera/backend/eyaml/encryptors/pkcs7'

class Hiera
  module Backend
    module Eyaml
      describe CLI do

        describe '.parse' do

          let(:subcommand_arg) { 'command_arg' }
          let(:option_arg) { 'option_arg' }
          let(:subcommand_class) { mock('Eyaml::Subcommand') }

          before(:each) do
            Eyaml::Subcommands.stubs(:find_all)
            Eyaml::Subcommands.stubs(:find_and_use).returns subcommand_class
            Eyaml::Subcommands.stubs(:names).returns [subcommand_arg]
            subcommand_class.stubs(:parse).returns({})
            subcommand_class.stubs(:validate).returns({})
            Eyaml::Options.stubs(:set)
            Eyaml::Options.stubs(:trace)
            ARGV.clear
            ARGV.push subcommand_arg
            ARGV.push option_arg
          end

          it 'finds all subcommands' do
            Eyaml::Subcommands.expects(:find_all).once
            CLI.parse
          end

          it 'reads eyaml subcommand from ARGV' do
            CLI.parse
            expect(Eyaml::Subcommands.input).to eq subcommand_arg
          end

          it 'cleans user input' do
            ARGV.clear
            ARGV.push 'CoMMand_Arg'
            Eyaml::Subcommands.expects(:find_and_use).with(subcommand_arg).once.returns subcommand_class
            CLI.parse
          end

          it 'uses the subcommand class specified by subcommand_arg' do
            Eyaml::Subcommands.expects(:find_and_use).with(subcommand_arg).once.returns subcommand_class
            CLI.parse
          end

          context 'when subcommand_arg is nil' do
            before(:each) do
              ARGV.clear
              ARGV.push nil
              ARGV.push option_arg
            end

            it 'sets subcommands input to empty string' do
              CLI.parse
              expect(Eyaml::Subcommands.input).to eq ''
            end

            it 'uses the UnknownCommand class' do
              Eyaml::Subcommands.expects(:find_and_use).with('unknown_command').once.returns subcommand_class
              CLI.parse
            end

            it 'clears the arguments array' do
              CLI.parse
              expect(ARGV.count).to eq 0
            end
          end

          context 'when subcommand_arg starts with a dash' do
            before(:each) do
              ARGV.clear
              ARGV.push '-blah'
              ARGV.push option_arg
            end

            it 'uses the Help subcommand' do
              Eyaml::Subcommands.expects(:find_and_use).with('help').once.returns subcommand_class
              CLI.parse
            end

            it 'clears the arguments array' do
              CLI.parse
              expect(ARGV.count).to eq 0
            end
          end

          context 'when subcommand_arg is not recognised' do
            before(:each) do
              ARGV.clear
              ARGV.push 'random_arg'
              ARGV.push option_arg
            end

            it 'uses the UnknownCommand class' do
              Eyaml::Subcommands.expects(:find_and_use).with('unknown_command').once.returns subcommand_class
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

require 'spec/spec_helper'
require 'hiera/backend/eyaml/utils'

module Gem
  def self.set_version version
    send(:remove_const, 'VERSION')
    const_set('VERSION', version)
  end
end

class Hiera
  module Backend
    module Eyaml
      describe Utils do

        describe '.camelcase' do
          it 'takes a string and returns it in CamelCase' do
            expect(Utils.camelcase 'hello_world').to eq 'HelloWorld'
          end
        end

        describe '.find_gem_specs' do

          let(:source_index) { mock('Gem::SourceIndex') }

          context 'with rubygems version below 1.6.0' do
            it 'gets specs from source_index' do
              Gem.set_version '1.5.2'
              source_index.expects(:latest_specs).once
              Gem.expects(:source_index).returns(source_index).once
              Utils.find_gem_specs
            end
          end

          context 'with rubygems version below 1.8.0' do
            it 'gets latest specs from source_index' do
              Gem.set_version '1.7.3'
              source_index.expects(:latest_specs).with(true).once
              Gem.expects(:source_index).returns(source_index).once
              Utils.find_gem_specs
            end
          end

          context 'with rubygems above version 1.8.0' do
            it 'gets latest specs from Gem::Specification' do
              Gem.set_version '1.8.4'
              Gem::Specification.expects(:latest_specs).with(true).once
              Utils.find_gem_specs
            end
          end
        end

        describe '.find_file_in_gem' do

          let(:gem_spec) { mock('Gem::Specification') }
          let(:glob) { '**/some_file.rb' }
          let(:searcher) { mock('Gem::GemPathSearcher') }

          context 'with rubygems version below 1.8.0' do
            before(:each) do
              Gem.set_version '1.7.3'
            end

            it 'searches gem for glob' do
              Gem.expects(:searcher).once.returns(searcher)
              searcher.expects(:matching_files).with(gem_spec, glob).once.returns([])
              Utils.find_file_in_gem gem_spec, glob
            end

            it 'returns the first match' do
              Gem.stubs(:searcher).returns(searcher)
              searcher.stubs(:matching_files).with(anything, anything).returns(['one', 'two'])
              file = Utils.find_file_in_gem gem_spec, glob
              expect(file).to eq 'one'
            end
          end

          context 'with rubygems version above 1.8.0' do
            before(:each) do
              Gem.set_version '1.8.6'
            end

            it 'finds matches for glob' do
              gem_spec.expects(:matches_for_glob).with(glob).once.returns([])
              Utils.find_file_in_gem gem_spec, glob
            end

            it 'returns the first match' do
              gem_spec.stubs(:matches_for_glob).with(anything).returns(['one', 'two'])
              file = Utils.find_file_in_gem gem_spec, glob
              expect(file).to eq 'one'
            end
          end
        end

        describe '.find_all_subclasses_of' do

          class ParentClass
          end
          class ChildClassOne < ParentClass
          end
          class ChildClassTwo < ParentClass
          end
          class GrandChildOne < ChildClassOne
          end

          subject(:classes) { Utils.find_all_subclasses_of Hiera::Backend::Eyaml::ParentClass }

          it 'returns a collection of classes' do
            classes.each { |klass|
              expect(klass).to be_a Class
            }
          end

          it 'finds all children of parent class' do
            expect(classes).to include(Hiera::Backend::Eyaml::ChildClassOne, Hiera::Backend::Eyaml::ChildClassTwo)
          end

          it 'only finds direct descendants' do
            expect(classes.count).to eq 2
          end
        end

      end
    end
  end
end

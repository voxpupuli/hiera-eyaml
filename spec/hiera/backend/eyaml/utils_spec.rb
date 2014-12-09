require 'hiera/backend/eyaml/utils'

class Hiera
  module Backend
    module Eyaml

      describe Utils do

        describe '.camelcase' do
          it 'takes a string and returns it in CamelCase' do

            expect(Utils.camelcase 'hello_world').to eq 'HelloWorld'
          end
        end
      end

    end
  end
end

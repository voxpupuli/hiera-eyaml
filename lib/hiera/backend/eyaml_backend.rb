class Hiera
    module Backend
        class Eyaml_backend

            def initialize
                require 'openssl'
                require 'base64'
            end

            def lookup(key, scope, order_override, resolution_type)
    
                debug("Lookup called for key #{key}")
                answer = nil
    
                Backend.datasources(scope, order_override) do |source|
                    eyamlFile = Backend.datafile(:eyaml, scope, source, "eyaml") || next

                    debug("Processing datasource: #{eyamlFile}")
    
                    eyaml_text = File.read( eyamlFile )
                    data = YAML.load( eyaml_text )
    
                    next if !data
                    next if data.empty?
                    debug ("Data contains valid YAML")
    
                    next unless data.include?(key)
                    debug ("Key #{key} found in YAML document")
    
                    parsed_answer = Backend.parse_answer(data[key], scope)
    
                    answer = decrypt(parsed_answer, scope)
                end
    
                return answer
            end
    
            def decrypt(value, scope)
    
                if is_encrypted(value)
    
                    private_key_path = Backend.parse_string(Config[:eyaml][:private_key], scope) || '/etc/hiera/keys/private_key.pem'
                    debug("Using #{private_key_path} to decrypt value")
    
                    # remove enclosing 'ENC( )'
                    cipher_text = value[4..-2]
    
                    private_key = OpenSSL::PKey::RSA.new(File.read( private_key_path ))
    
                    plain_text = private_key.private_decrypt( Base64.decode64(cipher_text) )
    
                    return plain_text
                else
                    return value
                end
            end

            def is_encrypted(value)
                if value.start_with?('ENC(')
                    return true
                else
                    return false
                end
            end

            def debug(msg)
                Hiera.debug("[eyaml_backend]: #{msg}")
            end

            def warn(msg)
                Hiera.warn("[eyaml_backend]:  #{msg}")
            end
        end
    end
end

module Puppet::Parser::Functions
    newfunction(:generate_resource_hash, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
      Converts an array of values to a hash of hashes suitable for use with
      the create_resources() function. The keys op the top-level hash are
      the positions of the original array members, optionally prefixed
      by a fixed string. Each of the elements of this top-level hash is
      populated with a single key => value pair; the key being the second
      parameter passed to this function, the value being the corresponding
      value from the original array.

      ### Obtained from http://competa.com/blog/2013/11/generating-puppet-resources-from-simple-arrays/

      For example:

          $my_array = ['one','two']
          $my_hash = generate_resource_hash($my_array,'foo','bar')
          # The resulting hash is equivalent to:
          # $my_hash = {
          #   'bar1' => {
          #     'foo' => 'one'
          #   }
          #   'bar2' => {
          #     'foo' => 'two'
          #   }
          # }
          create_resources(foobar,$my_hash)

      ENDHEREDOC

      if args.length < 2
        raise Puppet::ParseError, ("generate_resource_hash(): wrong number of args (#{args.length}; must be at least 2)")
      end

      my_array = args[0]
      unless my_array.is_a?(Array)
        raise(Puppet::ParseError, 'generate_resource_hash(): first arg must be an array')
      end

      param = args[1]
      unless param.is_a?(String)
        raise(Puppet::ParseError, 'generate_resource_hash(): second arg must be a string')
      end

      prefix = args[2] if args[2]
      if prefix
        unless prefix.is_a?(String)
          raise(Puppet::ParseError, 'generate_resource_hash(): third arg must be a string')
        end
      end

      # The destination hash we'll be filling.
      generated = Hash.new
      pos = 1

      my_array.each do |value|
        id = prefix + pos.to_s
        generated[id] = Hash.new
        generated[id][param] = value
        pos = pos + 1
      end

      # Return the new hash
      generated
    end
  end
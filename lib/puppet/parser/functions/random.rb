module Puppet::Parser::Functions
	newfunction(:random, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
		Generates a random number with a given max value.  Example usage:

		$random = random(100)
		$random => 98
		ENDHEREDOC

		if args.length != 1 then
			raise Puppet::ParseError, ("random() only expects one argument!  Pass random() a max value!")
		end
		maxValue = args[0] 
		unless args[0].respond_to?(:to_i) then
			raise Puppet::ParseError, ("random() expects a reasonable max-value parameter, but did not find one")	
		end
		randomGenerator = Random.new
		randomGenerator.rand(maxValue.to_i)
	end
end

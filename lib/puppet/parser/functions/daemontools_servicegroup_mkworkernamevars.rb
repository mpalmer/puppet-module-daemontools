require 'erb'

module Puppet::Parser::Functions
	newfunction(:daemontools_servicegroup_mkworkernamevars, :type => :rvalue, :doc => "Generates an array of worker namevars, given a servicegroup name, an ERB command template, and a number of workers.") do |args|
		args[2].to_i.times.map { |n| "#{args[0]}_#{n}/#{(ERB.new args[1]).result(binding)}".to_s }
	end
end

require 'minitest/unit'
require 'test/unit'

#require 'pp'
#
# Code from here: https://github.com/sandal/rbp/blob/master/testing/test_unit_extensions.rb
#
class MiniTest::Unit
   alias alutils_run_suite _run_suite
   def _run_suite(*args)
     res = alutils_run_suite(*args)
     @@out = STDERR if 0 < (errors + failures)
     res
  end
end

module Test::Unit
  # Used to fix a minor minitest/unit incompatibility in flexmock
  AssertionFailedError = Class.new(StandardError)
  
  class TestCase
   
    def self.must(name, &block)
      test_name = "test_#{name.gsub(/\s+/,'_')}".to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{name}"
        end
      end
    end

  end
end


require 'ffi'
require 'pry'

module MyRustLib

  class MyString < FFI::AutoPointer
    def self.release(ptr)
      free_string(ptr)
    end

    def to_s
      @str ||= self.read_string.force_encoding('UTF-8')
    end
  end

  class SumOfArray
    def self.call(numbers)
      buf = FFI::MemoryPointer.new(:uint32, numbers.size)
      buf.write_array_of_uint32(numbers)
      Bindings.sum_of_array(buf, numbers.size)
    end
  end

  module Bindings
    extend FFI::Library
    ffi_lib 'lib/target/release/libmy_rust_lib.' + FFI::Platform::LIBSUFFIX
    attach_function :return_one, :return_one, [], :int
    attach_function :add_one, :add_one, [:int], :int
    attach_function :return_string, :return_string, [], MyRustLib::MyString
    attach_function :free_string, :free_string, [MyRustLib::MyString], :void
    attach_function :how_many_characters, :how_many_characters, [:string], :uint32
    attach_function :sum_of_array, :sum_of_array, [:pointer, :size_t], :uint32
  end

end

puts MyRustLib::Bindings.return_one
puts MyRustLib::Bindings.add_one 1
puts MyRustLib::Bindings.return_string
puts MyRustLib::Bindings.how_many_characters "lorem ipsum"
puts MyRustLib::SumOfArray.call([1,2,3,4,5])

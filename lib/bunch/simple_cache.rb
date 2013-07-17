# encoding: UTF-8

require "thread"

module Bunch
  def self.SimpleCache(*args)
    SimpleCache.new(*args)
  end

  class SimpleCache
    Result = Struct.new(:result)

    def initialize(processor_class, *args)
      @processor_class, @args = processor_class, args
      @cache = nil
      @hache = nil
      @mutex = Mutex.new
    end

    def new(tree)
      result = nil
      @mutex.synchronize do
        check_cache!(tree)
        @cache ||= begin
          processor = @processor_class.new(tree, *@args)
          processor.result
        end
        result = @cache.dup
      end
      Result.new(result)
    end

    private

    def check_cache!(tree)
      hash = ContentHash.new(tree).result
      if hash != @hache
        @cache = nil
        @hache = hash
      end
    end
  end
end

# encoding: UTF-8

module Bunch
  class SimpleCache
    Result = Struct.new(:result)

    def initialize(processor_class, *args)
      @processor_class, @args = processor_class, args
      @cache = nil
      @hache = nil
    end

    def new(tree)
      check_cache!(tree)
      @cache ||= begin
        processor = @processor_class.new(tree, *@args)
        processor.result
      end
      Result.new(@cache.dup)
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

# encoding: UTF-8

require "optparse"

module Bunch
  class CLI
    def self.run!(args)
      new(args).run!
    end

    def initialize(args, out = $stdout)
      @args, @out = args, out
    end

    def run!
      in_path, out_path, options = parse_options

      if in_path && out_path && options
        pipeline = Pipeline.for_environment options.fetch(:env)
        in_tree  = FileTree.from_path in_path
        out_tree = pipeline.process in_tree
        out_tree.write_to_path out_path
      end
    end

    private

    def parse_options
      options = {:env => "production"}

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: bunch [options] INPUT_PATH OUTPUT_PATH"

        opts.on "-e", "--env [ENV]",
            "Specify environment (default: \"production\")" do |env|
          options[:env] = env.strip
        end

        opts.on_tail "-h", "--help", "Show this message" do
          @out.puts opts
          return
        end
      end

      opts.parse!(@args)

      if @args.count != 2
        raise "Must provide input and output paths!"
      end

      [*@args, options]
    rescue => e
      @out.puts "Error: #{e.message}\n\n"
      @out.puts opts if opts
    end
  end
end

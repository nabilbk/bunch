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
      config = parse_options

      if config && config[:root] && config[:output_path]
        pipeline = Pipeline.for_environment config
        in_tree  = FileTree.from_path config[:root]
        out_tree = pipeline.process in_tree
        out_tree.write_to_path config[:output_path]
      end
    end

    private

    def parse_options
      config = { environment: "production", config_files: [] }

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: bunch [options] INPUT_PATH OUTPUT_PATH"

        opts.on "-e", "--env [ENV]",
            "Specify environment (default: \"production\")" do |env|
          config[:environment] = env.strip
        end

        opts.on "-c", "--config [FILE]",
            "File to load (default: \"config/bunch.rb\")" do |f|
          config[:config_files] << f.strip
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

      if config[:config_files].any?
        Bunch.load_config_files(config[:config_files])
      else
        Bunch.load_default_config_if_possible
      end

      config[:root], config[:output_path] = @args
      config
    rescue StandardError, LoadError => e
      @out.puts "Error: #{e.message}\n\n"
      @out.puts opts if opts
    end
  end
end

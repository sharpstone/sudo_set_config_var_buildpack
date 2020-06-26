require "bundler/setup"

require 'rspec/retry'

ENV["HATCHET_BUILDPACK_BASE"] = "https://github.com/sharpstone/sudo_set_config_var_buildpack.git"
ENV["HATCHET_BUILDPACK_BRANCH"] = ENV["CIRCLE_BRANCH"] if ENV["CIRCLE_BRANCH"]

require 'hatchet'
require 'pathname'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.verbose_retry       = true # show retry status in spec process
  config.default_retry_count = 2 if ENV['IS_RUNNING_ON_CI'] # retry all tests that fail again

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'parallel_tests/test/runtime_logger' if ENV['RECORD_RUNTIME']

def run!(cmd)
  out = `#{cmd}`
  raise "Error running #{cmd}, output: #{out}" unless $?.success?
  out
end

def spec_dir
  Pathname.new(__dir__)
end

def generate_fixture_app(compile_script:, name: )
  app_dir = spec_dir.join("fixtures/repos/generated/#{name}")
  bin_dir = app_dir.join("bin")
  bin_dir.mkpath

  bin_compile = bin_dir.join("compile")
  bin_compile.write(compile_script)

  bin_detect = bin_dir.join("detect")
  bin_detect.write(<<~EOM)
    #!/usr/bin/env bash

    echo "inline buildpack"

    exit 0
  EOM

  app_dir.join("Procfile").write("")

  FileUtils.chmod("+x", bin_compile)
  FileUtils.chmod("+x", bin_detect)

  app_dir
end

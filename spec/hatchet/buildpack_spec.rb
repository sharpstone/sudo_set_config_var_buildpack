require_relative "../spec_helper.rb"

RSpec.describe "This buildpack" do
  it "sets env vars that other buildpacks pick up" do
    app_dir = generate_fixture_app(
      name: "echos buildpack_vendor_url",
      compile_script: <<~EOM
        #!/usr/bin/env bash

        echo "BUILDPACK_VENDOR_URL is set to $BUILDPACK_VENDOR_URL"
      EOM
    )

    buildpacks = [
      :default,
      "https://github.com/heroku/heroku-buildpack-inline",
    ]

    Hatchet::Runner.new(app_dir, buildpacks: buildpacks, config: {"__SUDO_BUILDPACK_VENDOR_URL": "bloop"}).deploy do |app|
      expect(app.output).to include("BUILDPACK_VENDOR_URL is set to bloop")
    end
  end

  it "fails if no 'sudo' env vars are set" do
    app_dir = generate_fixture_app(
      name: "empty",
      compile_script: <<~EOM
        #!/usr/bin/env bash
      EOM
    )
    buildpacks = [
      :default,
      "https://github.com/heroku/heroku-buildpack-inline",
    ]

    Hatchet::Runner.new(app_dir, buildpacks: buildpacks, allow_failure: true).deploy do |app|
      expect(app.output).to include("No sudo env vars found")
      expect(app.deployed?).to be_falsey
    end
  end
end

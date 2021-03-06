require 'thor'
require_relative 'consts'
require_relative 'utils/run'
require_relative 'env'
require_relative 'simctl'

module Calypso

  class XcodeBuild < Thor

    desc 'schemes', 'Shows available schemes'
    def schemes
      run base_build_cmd(WORKSPACE, '-list')
    end

    desc 'test [tries] [scheme]', "Runs tests for given scheme or #{SCHEME_UI_UNIT_TESTS}"
    def test(tries = 1, scheme = SCHEME_UI_UNIT_TESTS)
      exec_tests scheme, tries
    end

    desc 'cmd xcode_command [scheme]', "Runs given command with default arguments and scheme (#{SCHEME_UNIT_TESTS})"
    def cmd(cmd, scheme = SCHEME_UNIT_TESTS)
      exec_cmd cmd, scheme
    end

    private

    include Run

    def exec_tests(scheme, tries)
      exitstatus = 0
      try = 0
      loop do
        try += 1
        log "Running tests (scheme: #{scheme}, try: #{try}/#{tries})"

        SimCtl.new.run_with_simulator(TEST_DEVICE, TEST_RUNTIME) do |simulator_udid|
          build_cmd = format_build_cmd('test', scheme,
                                       '-destination', "'platform=iOS Simulator,id=#{simulator_udid}'",
                                       '-enableCodeCoverage', 'YES')
          exitstatus = run(build_cmd, exit_on_failure: false)
        end

        break if exitstatus.zero?
        exit(exitstatus) if try >= tries.to_i
      end
    end

    def exec_cmd(cmd, scheme)
      run format_build_cmd(cmd, scheme)
    end

    def base_build_cmd(workspace = WORKSPACE, *args)
      "xcodebuild -workspace #{workspace} -sdk iphonesimulator #{args.join ' '}"
    end

    def format_build_cmd(cmd, scheme = nil, *args)
      scheme = scheme.nil? ? nil : "-scheme '#{scheme}'"
      cmd = base_build_cmd(WORKSPACE, cmd, scheme, args)

      if env_skip_xcpretty?
        cmd
      else
        "set -o pipefail && #{cmd} | xcpretty"
      end
    end

    include Env

  end

end

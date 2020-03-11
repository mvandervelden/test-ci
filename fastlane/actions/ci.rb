module Fastlane
  module Actions
    module SharedValues
      CI_CUSTOM_VALUE = :CI_CUSTOM_VALUE
    end

    class CiAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        UI.important("CircleCI job: \"#{params[:circle_job]}\" will run on git branch: \"#{params[:branch]}\"")

        circle_api_token = ENV["CIRCLE_CI_API_TOKEN"]
        options = params[:options]
        # CIRCLE_JOB is the name of the job that will be run, specified in `.circleci/config.yml`
        options[:CIRCLE_JOB] = params[:circle_job]
        build_parameters = options.to_json

        sh("curl -X POST --header 'Content-Type: application/json' -d '{\"build_parameters\": #{build_parameters}}' -s https://circleci.com/api/v1.1/project/github/mvandervelden/test-ci/tree/#{params[:branch]}?circle-token=#{circle_api_token} | grep build_url")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Runs the specific lane on CircleCI"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "Runs the specific lane on CircleCI, you can also customise the branch"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(
            key: :circle_job,
            env_name: "FL_CI_LANE_NAME", # The name of the environment variable
            description: "Name of the lane to be run on CI", # a short description of this parameter
            verify_block: proc do |value|
              UI.user_error!("No lane for CI action given, pass using `lane: 'lane'`") unless (value and not value.empty?)
              # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
            end),
          FastlaneCore::ConfigItem.new(
            key: :branch,
            env_name: "FL_CI_BRANCH",
            description: "Branch name to build (or develop if not given)",
            is_string: true, # true: verifies the input is a string, false: every kind of value
            default_value: "develop"), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :options,
            env_name: "FL_CI_OPTIONS",
            description: "build parameters to send (none by default)",
            is_string: false) # the default value if the user didn't provide one
        ]
      end



      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["app-bot"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end

require "puppetlabs_spec_helper/rake_tasks"

if ENV["CI_GENERATE_REPORTS"] == "true"
  require "ci/reporter/rake/rspec"

  task :setup_ci_reporter do
    setup_spec_opts("--format", "documentation")
  end

  task :spec_standalone => :setup_ci_reporter
end

if ENV["CI_CLEANUP_REPORTS"] == "true"
  require "ci/reporter/rake/rspec"
  task :spec => "ci:setup:spec_report_cleanup"
end

task :test => [:spec]

task :default => :test

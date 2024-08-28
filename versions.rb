# frozen_string_literal: true

require 'fileutils'
require 'bundler'
require 'pry'

REPOSITORY_URLS = [
  'git@github.com:18f/identity-idp.git',
  'git@github.com:18f/identity-pki PIV/CAC application.git',
  'git@github.com:18f/identity-idp-config.git',
  'git@github.com:18f/identity-dashboard.git',
  'git@github.com:18f/identity-charts.git',
  'git@github.com:18f/identity-hostdata.git',
  'git@github.com:18f/identity-logging.git',
  'git@github.com:18F/omniauth_login_dot_gov.git',
  'git@github.com:18f/identity-validations.git',
  'git@github.com:18f/identity-telephony.git',
  'git@github.com:18f/identity-doc-auth.git',
  'git@github.com:18f/identity-proofer-gem.git',
  'git@github.com:18f/identity-lexisnexis-api-client-gem.git',
  'git@github.com:18f/identity-aamva-api-client-gem.git',
  'git@github.com:18f/identity-oidc-sinatra.git',
  'git@github.com:18f/identity-saml-sinatra.git',
  'git@github.com:18f/saml_idp',
  'git@github.com:18f/identity-saml-rails.git',
  'git@github.com:18f/identity-monitor.git',
  'git@github.com:18f/identity-lambda-functions.git',
  'git@github.com:18f/identity-design-assets.git',
  'git@github.com:18f/identity-design-system.git',
  'git@github.com:18f/identity-handbook-private.git',
  'git@github.com:18f/connect.gov.git',
  'git@github.com:18f/identity-partners-site.git',
  'git@github.com:GSA-TTS/identity-site.git',
  'git@github.com:GSA-TTS/identity-dev-docs.git',
  'git@github.com:GSA-TTS/identity-reporting.git',
  'git@github.com:GSA-TTS/identity-handbook.git',
  # 'lg/identity-devops.git',
  # 'lg/identity-devops-private.git',
  # 'lg/identity-terraform.git',
  # 'lg/identity-cookbooks.git',
  # 'lg/identity-base-image.git',
  # 'lg-public/identity-internal-handbook.git'
].freeze

LOCKFILE_DIR = 'lockfiles'

FileUtils.rm_rf(LOCKFILE_DIR)

$repository_data = {}

REPOSITORY_URLS.each do |repository_url|
  begin
    repository_name = repository_url[%r{git@github.com:(.*)\.git$},1]
    base_name = repository_name[%r{.*/([^/]+)$}, 1]

    lock_file_dir = "#{LOCKFILE_DIR}/#{base_name}"
    FileUtils.mkdir_p(lock_file_dir)

    lockfile_url = "https://api.github.com/repos/#{repository_name}/contents/Gemfile.lock"
    ruby_version_url = "https://api.github.com/repos/#{repository_name}/contents/.ruby_version"

    Dir.chdir lock_file_dir do
      # This works for plain git, but doesn't work for GitHub; have to
      # use their API. Maybe useful for GitLab?
      # `git archive --remote='#{repository_url}' HEAD:Gemfile.lock | tar -x`

      `curl -H 'Accept: application/vnd.github.raw' -O -L #{lockfile_url}`
      `curl -H 'Accept: application/vnd.github.raw' -O -L #{ruby_version_url}`

      lockfile = Bundler::LockfileParser.new(Bundler.read_file('Gemfile.lock'))
      $repository_data[repository_name]= {
        ruby_version: lockfile.ruby_version.inspect,
      }
    end

  #puts "parsed Gemfile.lock"

  # puts "    bundler version: #{lockfile.bundler_version}"
  # puts "#{repository_name}: #{lockfile.ruby_version.inspect}"

  # puts "    platforms(#{lockfile.platforms}):"
  # lockfile.platforms.each do |platform|
  #   puts "        #{platform}"
  # end

  # puts "    sources(#{lockfile.sources.length}):"
  # lockfile.sources.each do |source|
  #   puts "        #{source}"
  # end

  # puts "    dependencies(#{lockfile.dependencies.length}):"
  # lockfile.dependencies.each do |name, dependency|
  #   puts "        #{name}: #{dependency.name}: #{dependency.requirements_list}"
  # end

  # puts "    gems (#{lockfile.specs.length}):"
  # lockfile.specs.each do |gem|
  #   puts "        #{gem.name}, #{gem.version}"
  # end
  rescue
  end
end

$repository_data.each do |repository, data|
  puts "#{repository}: #{data[:ruby_version]}"
end


# frozen_string_literal: true

require 'fileutils'
require 'bundler'
require 'pry'

REPOSITORY_URLS = [
  'git@github.com:18F/identity-base-image.git',
  'git@github.com:18F/identity-cookbooks.git',
  'git@github.com:18F/identity-dashboard.git',
  'git@github.com:18F/identity-devops-private.git',
  'git@github.com:18F/identity-devops.git',
  'git@github.com:18F/identity-handbook.git',
  'git@github.com:18F/identity-idp.git',
  'git@github.com:18F/identity-lambda-functions.git',
  'git@github.com:18F/identity-loadtest.git',
  'git@github.com:18F/identity-oidc-sinatra.git',
  'git@github.com:18F/identity-pki.git',
  'git@github.com:18F/identity-security-private.git',
  'git@github.com:18F/identity-site.git',
  'git@github.com:18F/identity-terraform.git',
  'git@github.com:GSA-TTS/identity-dev-docs.git',
]

LOCKFILE_DIR = 'lockfiles'

FileUtils.rm_rf(LOCKFILE_DIR)

$repository_data = {}

REPOSITORY_URLS.each do |repository_url|
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
end

$repository_data.each do |repository, data|
  puts "#{repository}: #{data[:ruby_version]}"
end


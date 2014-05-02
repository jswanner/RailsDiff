# encoding: utf-8

$:.unshift 'lib/rails_diff'
require 'diff_splitter'
require 'pygments.rb'
require 'sass'
require 'haml'
require 'json'

task 'default' => 'generate'

desc 'Generate diff, html, & json files'
task 'generate' => 'update_rails_repo' do |t|
  tags = organized_included_tags.dup

  tags.each do |tag, tails|
    tails.each do |tail|
      Rake::Task["diff/#{tag}/#{tail}/index.html"].invoke
      Rake::Task["diff/#{tag}/#{tail}/full/index.html"].invoke
    end
  end

  Rake::Task["index.html"].invoke
  Rake::Task["404.html"].invoke
  Rake::Task["json/versions.json"].invoke
  Rake::Task["sitemap.txt"].invoke
end

desc 'Regenerate HTML files'
task 'regenerate_html' do
  Dir['html/*html'].each { |file| Rake::Task[file].invoke }
  Rake::Task["index.html"].invoke
  Rake::Task["404.html"].invoke
end

desc 'Generate index.html'
file 'index.html' => ['templates/index.haml', 'templates/layout.haml'] do |t|
  puts 'Generating %s' % t.name

  render(t.name, t.prerequisites.first)
end

desc 'Generate 404.html'
file '404.html' => ['templates/404.haml', 'templates/layout.haml'] do |t|
  puts 'Generating %s' % t.name
  render(t.name, t.prerequisites.first)
end

desc 'Generate versions.json'
file 'json/versions.json' => ['json', 'update_rails_repo'] do |t|
  File.write(t.name, JSON.dump(organized_included_tags) + "\n")
end

desc 'Generate sitemap.txt'
file 'sitemap.txt' => 'update_rails_repo' do |t|
  base = 'http://railsdiff.org'
  paths = Dir['diff/**/index.html'].unshift ''
  urls = paths.map { |path| [base, path].join '/' }
  File.write(t.name, urls.join("\n") + "\n")
end

desc 'Compiles assets'
directory 'assets'
task 'assets' => ['assets/app.css']

file 'assets/app.css' => ['assets/app.sass'] do |t|
  puts 'Generating %s' % t.name
  template = Sass::Engine.new File.read(t.prerequisites.first), load_paths: ['assets'], style: :compact, syntax: :sass
  File.write t.name, template.render
end

file 'templates/layout.haml' => 'assets'

directory 'tmp/rails'
file 'tmp/rails/rails' => 'tmp/rails' do |t|
  puts 'Cloning Rails repo'
  sh "git clone https://github.com/rails/rails.git #{t} > /dev/null 2>&1", verbose: false
end

task 'update_rails_repo' => 'tmp/rails/rails' do |t|
  puts 'Updating Rails repo'

  cd t.prerequisites.first, verbose: false do
    sh "git fetch origin > /dev/null", verbose: false
  end
end

file 'tmp/rails/generator' => 'tmp/rails' do |t|
  generator = <<-GEN
railties_path = File.expand_path('../railties/lib', __FILE__)
$:.unshift(railties_path)
require 'rails/version'

if Rails::VERSION::STRING =~ /\\A2.3/
  require "rails_generator"
  require "rails_generator/scripts/generate"
  Rails::Generator::Base.use_application_sources!
  Rails::Generator::Scripts::Generate.new.run(ARGV, :generator => 'app')
else
  require "rails/cli"
end
  GEN
  File.write(t.name, generator)
end

rule(/tmp\/rails\/.*/ => ['tmp/rails/rails', 'tmp/rails/generator']) do |t|
  cd t.source, verbose: false do
    tag = t.name.match(/([^\/]+)$/)[0]
    sh "git reset --hard #{tag} > /dev/null 2>&1", verbose: false
  end
  cp_r t.source, t.name, verbose: false
  cp 'tmp/rails/generator', t.name, verbose: false
end

directory 'tmp/generated'
rule(/tmp\/generated\/.*/ => ['tmp/generated']) do |t|
  source = t.name.gsub /^tmp\/generated/, 'tmp/rails'
  Rake::Task[source].invoke

  rm_rf t.name, verbose: false if Dir.exists?(t.name)

  if source.split(/\//).last =~ /v2.3/
    sh "ruby #{source}/generator #{t.name} > /dev/null", verbose: false
  else
    sh "ruby #{source}/generator new #{t.name}/railsdiff > /dev/null", verbose: false
    sh sed_command(t.name), verbose: false
    sh "mv #{t.name}/railsdiff/* #{t.name}/.", verbose: false
    sh "mv #{t.name}/railsdiff/.??* #{t.name}/.", verbose: false
  end
  rm_rf source, verbose: false
end

rule(/diff\/[^\/]+\/[^\/]+$/) do |t|
  mkdir_p t.name, verbose: false
end

rule(/diff\/.*\/patch\.diff/ => [->(t) { t.gsub('/patch.diff', '') }]) do |t|
  puts 'Generating: %s' % t.name

  match = t.name.match(/diff\/(?<s>[^\/]+)\/(?<t>.*?)\/patch\.diff/)
  source = match['s']
  target = match['t']
  Rake::Task["tmp/generated/#{source}"].invoke
  Rake::Task["tmp/generated/#{target}"].invoke
  cd "tmp/generated", verbose: false do
    %x{diff -Nru #{source} #{target} > ../../#{t.name}}
  end
end

rule(/diff\/.*\/full\.diff/ => [->(t) { t.gsub('/full.diff', '') }]) do |t|
  puts 'Generating: %s' % t.name

  match = t.name.match(/diff\/(?<s>[^\/]+)\/(?<t>.*?)\/full\.diff/)
  source = match['s']
  target = match['t']

  Rake::Task["tmp/generated/#{source}"].invoke
  Rake::Task["tmp/generated/#{target}"].invoke

  cd "tmp/generated", verbose: false do
    %x{diff -Nr -U 1000 #{source} #{target} > ../../#{t.name}}
  end
end

# Turn diff into HTML
rule(/diff\/[^\/]+\/[^\/]+\/index\.html/ => [->(t) { t.gsub('index.html', 'patch.diff') }, 'templates/layout.haml', 'templates/diff.haml']) do |t|
  puts 'Generating: %s' % t.name

  diff = File.read t.source
  diffs = RailsDiff::DiffSplitter.new(diff).split

  render(t.name, t.sources.last, diffs: diffs, title: page_title(t.name))
end

rule(/diff\/[^\/]+\/[^\/]+\/full$/) do |t|
  mkdir_p t.name, verbose: false
end

# Turn full file diff into HTML
rule(/diff\/[^\/]+\/[^\/]+\/full\/index\.html/ => [->(t) { t.gsub('full/index.html', 'full.diff') }, ->(t) { t.gsub('/index.html', '') }, 'templates/layout.haml', 'templates/full_diff.haml']) do |t|
  puts 'Generating: %s' % t.name

  diff = File.read t.source
  diffs = RailsDiff::DiffSplitter.new(diff).split

  render(t.name, t.sources.last, diffs: diffs, title: page_title(t.name))
end

rule(/html\/.*\.html/) do |t|
  match = t.name.match(/html\/(?<s>[^-]+)-(?<t>.*?)\.html/)
  source = match['s']
  target = match['t']
  url = '/diff/%s/%s/' % [source, target]

  content = template('templates/redirect.haml').render(nil, {url: url})
  File.write t.name, content
end

# Turn diff into JSON
directory 'json'
rule(/json\/.*\.json/ => [->(t) { t.gsub(/json/, 'diff') }, 'json']) do |t|
  puts 'Generating: %s' % t.name

  $:.unshift 'lib/rails_diff'
  diff = File.read t.source
  diffs = RailsDiff::DiffSplitter.new(diff).split

  File.open(t.name, 'w') do |file|
    file.puts ['{', '"diffs": [']
    file.puts diffs.map { |name, text|
      ['{', %Q|"filepath": #{name.inspect},|, %Q|"diff": #{text.inspect}|, '}', ',']
    }.flatten[0...-1]
    file.puts [']', '}']
  end
end

def page_title file_path
  versions = file_path.split('/')[1..2]
  'Rails %s - %s diff' % versions
end

def render file_name, template_name, locals = {}
  locals[:title] ||= nil

  content = template('templates/layout.haml').render(nil, locals) do
    template(template_name).render(nil, locals)
  end
  File.write file_name, content
end

def template name
  @templates ||= {}
  @templates.fetch name do |name|
    template = Haml::Engine.new(File.read name)
    @templates[name] = template
    template
  end
end

def all_included_tags
  @all_included_tags ||= all_tags.select { |tag| include_tag? tag }
end

def all_included_versions
  all_included_tags.map { |tag| version(tag).version }
end

def organized_included_tags
  organized_tags = {}
  all_included_tags.each do |tag|
    organized_tag = {
      tag => all_included_tags.select.with_index do |t, index|
        index > all_included_tags.index(tag) && t < max_comparable_tag(tag).next
      end
    }
    organized_tags.merge!(organized_tag)
  end
  organized_tags
end

def max_comparable_tag(tag)
  tag =~ /\Av2.3/ ? 'v3.0' : 'w'
end

def all_tags
  @all_tags ||= begin
                  result = nil
                  cd 'tmp/rails/rails', verbose: false do
                    result = %x{git tag -l "v2.3*" "v3*" "v4*"}.split
                  end
                  result.sort { |a, b| version(a) <=> version(b) }
                end
end

def include_tag? tag
  version = version tag
  (!version.prerelease? || version > last_full_release_version) &&
    version >= min_version
end

def last_full_release_version
  @last_full_release_version ||= all_tags.dup.reverse.
    map{ |tag| version tag }.find { |version| !version.prerelease? }
end

def min_version
  @min_version ||= version 'v2.3.0'
end

def sed_command base_path
  expression, file_path = [
    [
      "s/'.*'/'your-secret-token'/",
      "#{base_path}/railsdiff/config/initializers/secret_token.rb",
    ],
    [
      's/(secret_key_base:[[:space:]])[^<].*$/\1your-secret-token/',
      "#{base_path}/railsdiff/config/secrets.yml",
    ],
  ].find { |expression, file_path| File.exists?(file_path) }

  %Q{sed -E -i '' "#{expression}" #{file_path}}
end

def version tag
  Gem::Version.new(tag[1..-1])
rescue
  Gem::Version.new('0')
end

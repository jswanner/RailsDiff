# encoding: utf-8

$:.unshift 'lib/rails_diff'
require 'diff_splitter'
require 'pygments.rb'
require 'sass'
require 'haml'

task 'default' => 'generate'

desc 'Generate diff, html, & json files'
task 'generate' => 'update_rails_repo' do |t|
  tags = all_included_tags.dup
  tail = tags.pop

  while tags.any?
    tags.each do |tag|
      Rake::Task["html/#{tag}-#{tail}.html"].invoke
      Rake::Task["json/#{tag}-#{tail}.json"].invoke
    end
    tail = tags.pop
  end

  Rake::Task["index.html"].invoke
  Rake::Task["404.html"].invoke
end

desc 'Regenerate HTML files'
task 'regenerate_html' do
  Dir['html/*html'].each { |file| Rake::Task[file].invoke }
  Rake::Task["index.html"].invoke
  Rake::Task["404.html"].invoke
end

desc 'Generate index.html'
file 'index.html' => ['templates/index.haml', 'templates/layout.haml', 'update_rails_repo'] do |t|
  puts 'Generating %s' % t.name

  render(t.name, t.prerequisites.first, versions: all_included_versions)
end

desc 'Generate 404.html'
file '404.html' => ['templates/404.haml', 'templates/layout.haml', 'update_rails_repo'] do |t|
  puts 'Generating %s' % t.name
  render(t.name, t.prerequisites.first, versions: all_included_versions)
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
require "rails/cli"
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

  sh "ruby #{source}/generator new #{t.name}/railsdiff --skip-bundle > /dev/null", verbose: false
  rm "#{t.name}/railsdiff/config/initializers/secret_token.rb", verbose: false
  sh "mv #{t.name}/railsdiff/* #{t.name}/.", verbose: false
  sh "mv #{t.name}/railsdiff/.??* #{t.name}/.", verbose: false
  rm_rf source, verbose: false
end

directory 'diff'
rule(/diff\/.*\.diff/ => ['diff']) do |t|
  puts 'Generating: %s' % t.name

  match = t.name.match(/diff\/(?<s>[^-]+)-(?<t>.*?).diff/)
  source = match['s']
  target = match['t']
  Rake::Task["tmp/generated/#{source}"].invoke
  Rake::Task["tmp/generated/#{target}"].invoke
  cd "tmp/generated", verbose: false do
    %x{diff -Nru #{source} #{target} > ../../#{t.name}}
  end
end

# Turn diff into HTML
directory 'html'
rule(/html\/.*\.html/ => [->(t) { t.gsub(/html/, 'diff') }, 'html', 'templates/layout.haml', 'templates/diff.haml']) do |t|
  puts 'Generating: %s' % t.name

  diff = File.read t.source
  diffs = RailsDiff::DiffSplitter.new(diff).split

  render(t.name, t.sources.last, diffs: diffs, versions: all_included_versions)
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

def render file_name, template_name, locals
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

def all_tags
  @all_tags ||= begin
                  result = nil
                  cd 'tmp/rails/rails', verbose: false do
                    result = %x{git tag -l "v3*" "v4*"}.split
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
  @min_version ||= version 'v3.0.0'
end

def version tag
  Gem::Version.new(tag[1..-1])
rescue
  Gem::Version.new('0')
end

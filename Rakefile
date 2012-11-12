# encoding: utf-8

$:.unshift 'lib/rails_diff'
require 'diff_splitter'
require 'pygments.rb'
require 'erubis'

desc 'Generate diff, html, & json files'
task :gen_diffs => ['tmp/rails/rails', :update_rails_repo] do |t|
  tags = all_tags
  tail = tags.pop
  while tags.any?
    tags.each do |tag|
      Rake::Task["html/#{tag}-#{tail}.html"].invoke
      Rake::Task["json/#{tag}-#{tail}.json"].invoke
    end
    tail = tags.pop
  end
end

desc 'Generate index.html'
file 'index.html' => ['templates/index.html.erb', 'tmp/rails/rails'] do |t|
  tags = all_tags
  versions = tags.map {|t| version(t).version }
  File.write(t.name, template(t.prerequisites.first).result(versions: versions))
end

desc 'Generate 404.html'
file '404.html' => ['templates/404.html.erb', 'tmp/rails/rails'] do |t|
  tags = all_tags
  versions = tags.map {|t| version(t).version }
  File.write(t.name, template(t.prerequisites.first).result(versions: versions))
end

def template name
  @templates ||= {}
  @templates.fetch name do |name|
    template = Erubis::Eruby.new(File.read name)
    @templates[name] = template
    template
  end
end

def all_tags
  tags = nil
  cd 'tmp/rails/rails' do
    tags = %x{git tag -l "v3*"}.split
  end
  tags.
    sort { |a, b| version(a) <=> version(b) }.
    select { |t| version(t) >= min_version }
end

def version tag
  Gem::Version.new(tag[1..-1])
rescue
  Gem::Version.new('0')
end

def min_version
  @min_version ||= version 'v3.0.0'
end

directory 'tmp/rails'
file 'tmp/rails/rails' => 'tmp/rails' do |t|
  puts 'Cloning Rails repo'
  %x{git clone git://github.com/rails/rails.git #{t}}
end

task 'update_rails_repo' => 'tmp/rails/rails' do |t|
  cd t.prerequisites.first do
    %x{git fetch origin}
    %x{git checkout master}
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
  cd t.source do
    tag = t.name.match(/([^\/]+)$/)[0]
    %x{git checkout master}
    %x{git checkout #{tag}}
  end
  cp_r t.source, t.name
  cp 'tmp/rails/generator', t.name
end

directory 'tmp/generated'
rule(/tmp\/generated\/.*/ => ['tmp/generated']) do |t|
  tag = t.name.match(/([^\/]+)$/)[0]
  Rake::Task["tmp/rails/#{tag}"].invoke
  rails_dir = "tmp/rails/#{tag}"
  system %{ruby #{rails_dir}/generator new #{t.name}/railsdiff --skip-bundle}
  rm "#{t.name}/railsdiff/config/initializers/secret_token.rb"
  %x{mv #{t.name}/railsdiff/* #{t.name}/.}
  %x{mv #{t.name}/railsdiff/.??* #{t.name}/.}
end

def rails_binary dir
  old = "#{dir}/bin/rails"
  new = "#{dir}/railties/bin/rails"
  File.exists?(old) ? old : new
end

directory 'diff'
rule(/diff\/.*\.diff/ => ['diff']) do |t|
  match = t.name.match(/diff\/(?<s>[^-]+)-(?<t>.*?).diff/)
  source = match['s']
  target = match['t']
  Rake::Task["tmp/generated/#{source}"].invoke
  Rake::Task["tmp/generated/#{target}"].invoke
  cd "tmp/generated" do
    %x{diff -Nru #{source} #{target} > ../../#{t.name}}
  end
end

# Turn diff into HTML
directory 'html'
rule(/html\/.*\.html/ => [proc { |t| t.gsub(/html/, 'diff') }, 'html', 'templates/diff.html.erb']) do |t|

  diff = File.read t.source
  diffs = RailsDiff::DiffSplitter.new(diff).split

  File.write(t.name, template(t.sources.last).result(diffs: diffs))
end

# Turn diff into JSON
directory 'json'
rule(/json\/.*\.json/ => [proc { |t| t.gsub(/json/, 'diff') }, 'json']) do |t|
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

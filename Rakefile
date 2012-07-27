# encoding: utf-8

task :gen_diffs => 'tmp/rails/rails' do |t|
  all_tags = nil
  cd 'tmp/rails/rails' do
    all_tags = %x{git tag -l "v3*"}.split
  end
  all_tags.sort! { |a, b| version(a) <=> version(b) }
  tail = all_tags.pop
  while all_tags.any?
    all_tags.each do |tag|
      next unless version(tag) >= min_version
      Rake::Task["diffs/#{tag}-#{tail}.html"].invoke
      Rake::Task["diffs/#{tag}-#{tail}.json"].invoke
    end
    tail = all_tags.pop
  end
end

def version tag
  Gem::Version.new(tag[1..-1])
rescue
  Gem::Version.new('0')
end

def min_version
  @min_version ||= version 'v3.1.1.rc1'
end

directory 'tmp/rails'
file 'tmp/rails/rails' => 'tmp/rails' do |t|
  puts 'Cloning Rails repo'
  %x{git clone git://github.com/rails/rails.git #{t}}
end

rule(/tmp\/rails\/.*/ => ['tmp/rails/rails']) do |t|
  cd t.source do
    tag = t.name.match(/([^\/]+)$/)[0]
    %x{git checkout master}
    %x{git checkout #{tag}}
  end
  cp_r t.source, t.name
end

directory 'tmp/generated'
rule(/tmp\/generated\/.*/ => ['tmp/generated']) do |t|
  tag = t.name.match(/([^\/]+)$/)[0]
  Rake::Task["tmp/rails/#{tag}"].invoke
  rails_dir = "tmp/rails/#{tag}"
  %x{#{rails_binary rails_dir} new #{t.name}/railsdiff --skip-bundle}
  rm "#{t.name}/railsdiff/config/initializers/secret_token.rb"
  %x{mv #{t.name}/railsdiff/* #{t.name}/.}
  %x{mv #{t.name}/railsdiff/.??* #{t.name}/.}
end

def rails_binary dir
  old = "#{dir}/bin/rails"
  new = "#{dir}/railties/bin/rails"
  File.exists?(old) ? old : new
end

directory 'diffs'
rule(/diffs\/.*\.diff/ => ['diffs']) do |t|
  match = t.name.match(/diffs\/(?<s>[^-]+)-(?<t>.*?).diff/)
  source = match['s']
  target = match['t']
  Rake::Task["tmp/generated/#{source}"].invoke
  Rake::Task["tmp/generated/#{target}"].invoke
  cd "tmp/generated" do
    %x{diff -Nru #{source} #{target} > ../../#{t.name}}
  end
end

# Turn diff into HTML
rule '.html' => ['.diff'] do |t|
  $:.unshift 'lib/rails_diff'
  require 'diff_splitter'
  diff = File.read t.source
  diffs = RailsDiff::DiffSplitter.new(diff).split

  File.open(t.name, 'w') do |file|
    file.puts ['---', 'layout: diff', '---']
    file.puts diffs.map { |name, text|
      ["<h2>#{name}</h2>", '{% highlight diff %}', text, '{% endhighlight %}']
    }
  end
end

# Turn diff into JSON
rule '.json' => ['.diff'] do |t|
  $:.unshift 'lib/rails_diff'
  require 'diff_splitter'
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

# encoding: utf-8

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

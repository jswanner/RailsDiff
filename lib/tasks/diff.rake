# encoding: utf-8

namespace :diff do
  desc 'Uploads diff to railsdiff.org.'
  task :upload, [:diff, :url] do |_, args|
    unless args[:diff] && args[:url]
      puts <<-USAGE
Usage:
  rake diff:upload[path/to/diff,http://railsdiff.org/source/target]
      USAGE
      exit 1
    end

    $:.unshift 'app'
    require 'rails_diff/diff_splitter'
    require 'rails_diff/diff_uploader'

    diff = Pathname.new(args[:diff]).read
    diffs = RailsDiff::DiffSplitter.new(diff).split
    diffs = diffs.map{ |k,v| {file_path: k, text: v} }

    RailsDiff::DiffUploader.new(args[:url], diffs).upload
  end
end

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

    $:.unshift 'lib/rails_diff'
    require 'diff_splitter'
    require 'diff_uploader'

    diff = Pathname.new(args[:diff]).read
    diffs = RailsDiff::DiffSplitter.new(diff).split
    diffs = diffs.map{ |k,v| {file_path: k, text: v} }

    RailsDiff::DiffUploader.new(args[:url], diffs).upload
  end

  desc 'Seed diffs'
  task seed: :environment do
    FileList['diff/*.diff'].each do |diff_path|
      diff = File.read diff_path
      diffs = RailsDiff::DiffSplitter.new(diff).split
      diffs = diffs.map{ |k,v| {file_path: k, text: v} }

      matches = diff_path.match(/\/(?<source>[^-]+)-(?<target>[^-]+).diff$/)
      source, target = matches[:source], matches[:target]
      [source, target].each { |v| Version.where(version: v).first_or_create }
      diff = Diff.where(source: source, target: target).first_or_initialize
      diff.update_attributes file_diffs_attributes: diffs
    end
  end
end

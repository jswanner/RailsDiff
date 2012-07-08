# encoding: utf-8

module RailsDiff
  class DiffSplitter < Struct.new(:diff)
    def lines
      diff.lines
    end
    private :lines

    def split
      file_path = nil
      lines.inject({}) do |diffs, line|
        if line =~ /^diff/ and match = line.match(/b\/(?<file_path>.+)$/)
          file_path = match[:file_path]
          diffs[file_path] = ''
        elsif !diffs[file_path].empty? || line =~ /^@/
          diffs[file_path] << line
        end

        diffs
      end
    end
  end
end

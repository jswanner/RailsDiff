class FileDiff < ActiveRecord::Base
  belongs_to :diff
  attr_accessible :file_path, :text
end

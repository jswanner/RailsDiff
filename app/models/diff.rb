class Diff < ActiveRecord::Base
  has_many :file_diffs

  accepts_nested_attributes_for :file_diffs

  attr_accessible :file_diffs_attributes
end

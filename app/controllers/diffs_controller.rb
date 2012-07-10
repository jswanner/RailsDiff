class DiffsController < ApplicationController
  def show
    diff = Diff.where(source: params[:source], target: params[:target]).first!
    @file_diffs = diff.file_diffs.order(:file_path)
  end

  def update
    [params[:source], params[:target]].each { |v| Version.where(version: v).first_or_create }
    diff = Diff.where(source: params[:source], target: params[:target]).first_or_initialize
    diff.update_attributes file_diffs_attributes: params[:diffs]
    head :created, location: diff_path(params[:source], params[:target])
  end
end

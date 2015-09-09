require_dependency 'article'
require_dependency 'folder'

class Folder < Article

  settings_items :grade_submission_id, :type =>  :integer

  after_save do |folder|
    if folder.parent.kind_of?(WorkAssignmentPlugin::WorkAssignment)
      folder.children.each do |c|
        c.published = folder.published
        c.article_privacy_exceptions = folder.article_privacy_exceptions
      end
    end
  end

  def final_grade (folder)
    unless folder.grade_submission_id.nil?
      UploadedFile.find(folder.grade_submission_id).grade_version
    end
  end

end

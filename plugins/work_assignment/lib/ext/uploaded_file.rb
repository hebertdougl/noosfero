require_dependency 'article'
require_dependency 'uploaded_file'

class UploadedFile < Article

  settings_items :grade_version, :type =>  :float, :default => 0
  settings_items :valuation_date, :type =>  :datetime

end

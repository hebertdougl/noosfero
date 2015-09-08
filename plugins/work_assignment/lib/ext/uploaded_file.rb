require_dependency 'article'
require_dependency 'uploaded_file'

class UploadedFile < Article

  settings_items :grade_version, :type =>  :float, :default => 0
  settings_items :valuation_date, :type =>  :datetime
  settings_items :final_grade, :type => :boolean, :default => false

  attr_accessible :grade_version
  attr_accessible :valuation_date
  attr_accessible :final_grade

end

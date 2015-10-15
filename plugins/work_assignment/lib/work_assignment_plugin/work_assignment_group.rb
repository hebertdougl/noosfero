class WorkAssignmentPlugin::WorkAssignmentGroup < Folder

  settings_items :short_name, :type => :string
  settings_items :start_date, :type => :DateTime
  settings_items :end_date, :type => :DateTime

  attr_accessible :short_name
  attr_accessible :start_date
  attr_accessible :end_date


  def self.icon_name(article = nil)
    'work-assignment-group'
  end

  def self.short_description
    _('Work Assignment Group')
  end

  def self.description
    _('Criacao de cursos')
  end

  def work_assignment_list
    children.where(:type => 'WorkAssignmentPlugin::WorkAssignment').order("ending ASC")
  end

  def accept_comments?
    false
  end

  def allow_create?(user)
    profile.members.include?(user)
  end

  def to_html(options = {})
    work_assignment_group = self
    proc do
      render :file => 'content_viewer/work_assignment_group.html.erb', :locals => {:work_assignment_group => work_assignment_group}
    end
  end

end

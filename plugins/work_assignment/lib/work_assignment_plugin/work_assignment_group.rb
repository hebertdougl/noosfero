class WorkAssignmentPlugin::WorkAssignmentGroup < Folder

  settings_items :description, :type => :string

  attr_accessible :description


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
    children.where(:type => 'WorkAssignmentPlugin::WorkAssignment')
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

class WorkAssignmentPlugin::WorkAssignment < Folder

  settings_items :publish_submissions, :type => :boolean, :default => false
  settings_items :default_email, :type => :string, :default => ""
  settings_items :allow_visibility_edition, :type => :boolean, :default => false
  settings_items :publish_grades, :type => :boolean, :default => false
  settings_items :work_assignment_activate_evaluation, :type => :boolean, :default => false
  settings_items :work_assignment_final_grade_options, :type => :string, :default => "Highest Grade"

  attr_accessible :publish_submissions
  attr_accessible :default_email
  attr_accessible :allow_visibility_edition
  attr_accessible :publish_grades
  attr_accessible :work_assignment_activate_evaluation
  attr_accessible :work_assignment_final_grade_options

  WORK_ASSIGNMENT_FINAL_GRADE_OPTIONS = ["Highest Grade", "Last Grade", "Optional Grade"]

  def self.icon_name(article = nil)
    'work-assignment'
  end

  def self.short_description
    _('Work Assignment')
  end

  def self.description
    _('Defines a work to be done by the members and receives their submissions about this work.')
  end

  def self.versioned_name(submission, folder)
    "(V#{folder.children.count + 1}) #{submission.name}"
  end

  def accept_comments?
    true
  end

  def allow_create?(user)
    profile.members.include?(user)
  end

  def to_html(options = {})
    lambda do
      render :file => 'content_viewer/work_assignment.html.erb'
    end
  end

  def find_or_create_author_folder(author)
    children.find_by_slug(author.name.to_slug) || Folder.create!(
                                                                {
                                                                  :name => author.name,
                                                                  :parent => self,
                                                                  :profile => profile,
                                                                  :author => author,
                                                                  :published => publish_submissions,
                                                                },
                                                                :without_protection => true
                                                  )
  end

  def submissions
    children.map(&:children).flatten.compact
  end

  def cache_key_with_person(params = {}, user = nil, language = 'en')
    cache_key_without_person + (user && profile.members.include?(user) ? "-#{user.identifier}" : '')
  end
  alias_method_chain :cache_key, :person

  def final_grade_options
    WORK_ASSIGNMENT_FINAL_GRADE_OPTIONS
  end
end

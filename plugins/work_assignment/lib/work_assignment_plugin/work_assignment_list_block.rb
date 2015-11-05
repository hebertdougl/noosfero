class WorkAssignmentPlugin::WorkAssignmentListBlock < Block

  def self.description
    _('Recent Grade List')
  end

  def help
    _('This block displays a list of recent grades.')
  end

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/recent_grades_list', :locals => {:block => block}
    end
  end
end

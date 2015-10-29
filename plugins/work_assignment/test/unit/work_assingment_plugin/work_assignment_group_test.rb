require File.expand_path(File.dirname(__FILE__) + "/../../../../../test/test_helper")

class WorkAssignmentGroupTest < ActiveSupport::TestCase

  def setup
    @organization = fast_create(Organization)
    @work_assignment_group = WorkAssignmentPlugin::WorkAssignmentGroup.create!(:name => 'Work Assignment Group', :profile => @organization, :start_date => Time.now, :end_date => Time.now + 2.day)
    @work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => 'Sample Work Assignment', :profile => @organization, :begining => Time.now, :ending => Time.now + 1.day)
  end

  should 'return children work assignment' do
    @work_assignment.parent = @work_assignment_group
    @work_assignment.save!
    assert_equal [@work_assignment], @work_assignment_group.work_assignment_list
  end
end

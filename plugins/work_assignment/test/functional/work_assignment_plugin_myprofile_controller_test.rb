require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")
require 'work_assignment_plugin_myprofile_controller'

# Re-raise errors caught by the controller.
class WorkAssignmentPluginMyprofileController; def rescue_action(e) raise e end; end

class WorkAssignmentPluginMyprofileControllerTest < ActionController::TestCase

  def setup
    @controller = WorkAssignmentPluginMyprofileController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @person = create_user('test_user').person
    login_as :test_user
    e = Environment.default
    e.enabled_plugins = ['WorkAssignmentPlugin']
    e.save!
    @organization = fast_create(Organization) #
  end

  should 'submission edit visibility deny access to users and admin when Work Assignment allow_visibility_edition is false' do
    @organization.add_member(@person)
    ##### Testing with normal user
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, false)
    work_assignment.save!
    assert_equal false, work_assignment.allow_visibility_edition
    parent = work_assignment.find_or_create_author_folder(@person)
    UploadedFile.create(
            {
              :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'),
              :profile => @organization,
              :parent => parent,
              :last_changed_by => @person,
              :author => @person,
            },
            :without_protection => true
          )
    submission = UploadedFile.find_by_filename("test.txt")
    assert_equal false, submission.published
    assert_equal false, submission.parent.published

    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id
    assert_template 'access_denied'
    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id, :article => { :published => true }
    assert_template 'access_denied'

    submission.reload
    assert_equal false, submission.published
    assert_equal false, submission.parent.published

    #### Even with admin user
    e = Environment.default
    assert_equal false, @person.is_admin?
    e.add_admin(@person)
    e.save!
    assert_equal true, @person.is_admin?

    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id
    assert_template 'access_denied'
    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id, :article => { :published => true }
    assert_template 'access_denied'

    submission.reload
    assert_equal false, submission.published
  end

  should 'redirect an unlogged user to the login page if he tryes to access the edit visibility page and work_assignment allow_visibility_edition is true' do
    @organization.add_member(@person)
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, true)
    assert_equal true, work_assignment.allow_visibility_edition
    work_assignment.save!
    parent = work_assignment.find_or_create_author_folder(@person)
    UploadedFile.create(
            {
              :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'),
              :profile => @organization,
              :parent => parent,
              :last_changed_by => @person,
              :author => @person,
            },
            :without_protection => true
          )
    logout
    submission = UploadedFile.find_by_filename("test.txt")
    assert_equal false, submission.parent.published
    assert_equal false, submission.published

    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id
    assert_redirected_to '/account/login'
    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id, :article => { :published => true }
    assert_redirected_to '/account/login'
    submission.reload
    assert_equal false, submission.parent.published
    assert_equal false, submission.published
  end

  should 'submission edit_visibility deny access to not owner when WorkAssignment edit_visibility is true' do
    @organization.add_member(@person) # current_user is a member
    work_assignment = create_work_assignment('Another Work Assignment', @organization, nil, true)
    parent = work_assignment.find_or_create_author_folder(@person)
    UploadedFile.create(
            {
              :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'),
              :profile => @organization,
              :parent => parent,
              :last_changed_by => @person,
              :author => @person,
            },
            :without_protection => true
          )
    logout


    other_person = create_user('other_user').person
    @organization.add_member(other_person)
    login_as :other_user

    @organization.add_member(other_person)
    submission = UploadedFile.find_by_filename("test.txt")
    assert_equal(submission.author, @person)

    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id
    assert_template 'access_denied'

    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id, :article => { :published => true }
    assert_template 'access_denied'

    submission.reload
    assert_equal false, submission.parent.published
    assert_equal false, submission.published
  end

  should 'submission white list give permission to an user that has been added' do
    other_person = create_user('other_user').person
    @organization.add_member(@person)
    @organization.add_member(other_person)
    work_assignment = create_work_assignment('Another Work Assignment', @organization, false,  true)
    parent = work_assignment.find_or_create_author_folder(@person)
    UploadedFile.create(
            {
              :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'),
              :profile => @organization,
              :parent => parent,
              :last_changed_by => @person,
              :author => @person,
            },
            :without_protection => true
          )
    submission = UploadedFile.find_by_filename("test.txt")
    assert_equal false, submission.article_privacy_exceptions.include?(other_person)
    post :edit_visibility, :profile => @organization.identifier, :article_id  => parent.id, :article => { :published => false }, :q => other_person.id
    submission.reload
    assert_equal true, submission.parent.article_privacy_exceptions.include?(other_person)
    assert_equal true, submission.article_privacy_exceptions.include?(other_person)
  end

  should 'submission edit_visibility deny access to owner if not organization member' do
    @organization.add_member(@person) # current_user is a member
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, true)
    parent = work_assignment.find_or_create_author_folder(@person)
    UploadedFile.create(
            {
              :uploaded_data => fixture_file_upload('/files/test.txt', 'text/plain'),
              :profile => @organization,
              :parent => parent,
              :last_changed_by => @person,
              :author => @person,
            },
            :without_protection => true
          )
    @organization.remove_member(@person)
    submission = UploadedFile.find_by_filename("test.txt")

    assert_equal false, (@person.is_member_of? submission.profile)

    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id
    assert_template 'access_denied'

    post :edit_visibility, :profile => @organization.identifier, :article_id => parent.id, :article => { :published => true }
    assert_template 'access_denied'

    submission.reload
    assert_equal false, submission.parent.published
    assert_equal false, submission.published
  end

# work_assignment grade functionality

  should 'the final grade not show if the evaluation option isnt selected' do
    @organization.add_member(@person)
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, nil, false, false)

    folder = work_assignment.find_or_create_author_folder(@person)
    folder.parent.save!

    file = create_uploaded_file("/files/file.txt", @organization, folder, @person, @person, true)

    post :assign_grade, :profile => @organization.identifier, :submission => file.id, :grade_version => 6
    assert_template 'access_denied'

    file.reload
    assert_nil folder.final_grade
  end

  should 'the final grade be updated with action assign_grade' do
    @organization.add_member(@person)
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, true, true, true)
    folder = work_assignment.find_or_create_author_folder(@person)
    file = create_uploaded_file("/files/file.txt", @organization, folder, @person, @person, true)

    folder.reload #update children

    grade = 6
    post :assign_grade, :profile => @organization.identifier, :submission => file.id, :grade_version => grade
    assert_equal folder.final_grade, grade
  end

  should 'the final grade be the highest if the highest option is selected' do
    @organization.add_member(@person)
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, true, true, true)
    folder = work_assignment.find_or_create_author_folder(@person)
    file = create_uploaded_file("/files/file.txt", @organization, folder, @person, @person, true)
    other_file = create_uploaded_file("file2.txt", @organization, folder, @person, @person, true)

    folder.reload #update children
    folder.parent.work_assignment_final_grade_options = "Highest Grade"
    folder.parent.save

    post :assign_grade, :profile => @organization.identifier, :submission => file.id, :grade_version => 6
    post :assign_grade, :profile => @organization.identifier, :submission => other_file.id, :grade_version => 5

    @back_to = url_for(work_assignment.url)

    assert_redirected_to @back_to
    file.reload
    other_file.reload

    assert_equal folder.final_grade, 6
  end

  should 'the final grade be the latest when the latest option is selected' do
    @organization.add_member(@person)
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, true, true, true)
    folder = work_assignment.find_or_create_author_folder(@person)
    file = create_uploaded_file("file.txt", @organization, folder, @person, @person, true)
    other_file = create_uploaded_file("file2.txt", @organization, folder, @person, @person, true)

    folder.reload
    folder.parent.work_assignment_final_grade_options = "Last Grade"
    folder.parent.save

    post :assign_grade, :profile => @organization.identifier, :submission => file.id, :grade_version => 6
    post :assign_grade, :profile => @organization.identifier, :submission => other_file.id, :grade_version => 5

    @back_to = url_for(work_assignment.url)
    assert_redirected_to @back_to
    other_file.reload

    assert_equal folder.final_grade, other_file.setting[:grade_version]
  end


  should 'the final grade be the optional when the optional grade is selected' do
    @organization.add_member(@person)
    work_assignment = create_work_assignment('Work Assignment', @organization, nil, true, true, true)
    folder = work_assignment.find_or_create_author_folder(@person)
    file = create_uploaded_file("file.txt", @organization, folder, @person, @person, true)
    folder.reload
    folder.parent.work_assignment_final_grade_options = "Optional Grade"
    folder.parent.save

    post :assign_grade, :profile => @organization.identifier, :submission => file.id, :grade_version => 6, :final_grade => true

    folder.reload
    file.reload

    assert_equal folder.final_grade, file.setting[:grade_version]
  end

# end tests for work_assignment grade functionality

  private

    def create_work_assignment(name = "text.txt", profile = nil, publish_submissions = nil, allow_visibility_edition = nil, work_assignment_activate_evaluation = nil, publish_grades = nil)
      @work_assignment = WorkAssignmentPlugin::WorkAssignment.create!(:name => name, :profile => profile, :publish_submissions => publish_submissions, :allow_visibility_edition => allow_visibility_edition, :publish_grades => publish_grades, :work_assignment_activate_evaluation => work_assignment_activate_evaluation)
    end

    def create_uploaded_file(name_slug = nil, profile = nil, parent = nil, last_changed_by= nil, author = nil, protection_type = nil)
      UploadedFile.create!(
            {
              :name => name_slug,
              :slug => name_slug,
              :uploaded_data => fixture_file_upload("files/test.txt", 'text/plain'),
              :profile => profile,
              :parent => parent,
              :last_changed_by => last_changed_by,
              :author => author,
            },
            :without_protection => protection_type
          )
    end
end

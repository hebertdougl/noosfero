require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")
require 'account_controller'

class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    e = Environment.default
    e.enabled_plugins.push('SignUpReasonPlugin')
    e.save!
  end

  should 'signup create task to last user' do
    file = stub(:true)
    user = User.new( login: 'newuser1234', password: '12345678', password_confirmation: '12345678', email: 'newuser1234@gmail.com' )
    get :signup, user: user, profile_data: { name: 'New User', template_id: '4' }, file: file
    user.reload
    task = Task.last

    assert_equals task.requestor_id, User.last.id
  end

end
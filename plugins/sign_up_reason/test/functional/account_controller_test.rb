require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")

class AccountController; def rescue_action(e) raise e end; end

class AccountControllerPluginTest < ActionController::TestCase

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @organization = fast_create(Organization)

    @environment = Environment.default
    @environment.enabled_plugins = ['SignUpReasonPlugin']
    @environment.save!
  end

  should 'signup create task to last user' do
    puts "#{Environment.default}"
    puts "#{Environment.default.class}"
    @environment.enable('skip_new_user_email_confirmation')
    puts "enable"
    @environment.save!
    puts "save!"

    puts "User.count: #{User.count}"

    post(:signup, :user => {
        :login => 'testuser',
        :password => '123456',
        :password_confirmation => '123456',
        :email => 'testuser@example.com'
      },
      :profile_data => {:name =>'testuser'},
      :task =>{:signup_reason => 'A REASON'},
      :honeypot =>''
    )

    puts "nao quebrou"
    assert_response :success

    puts "User.count: #{User.count}"

    puts @response.body

    user = User.find_by_login('testuser')
    puts "#"*80,user,"#"*80

    assert user.activated?

    # user.reload
    puts "*"*80,Task.last.inspect,"*"*80

    task = Task.last

    assert_equals task.requestor_id, User.last.id
  end

end

class SignUpReasonPlugin < Noosfero::Plugin

  def self.plugin_name
    "Sign Up Reason Plugin"
  end

  def self.plugin_description
    _("Add field in register form for the user to inform a reason to signup.")
  end

  def signup_extra_contents
    proc {
      labelled_form_field(_('Reason:'), text_area(:task, :signup_reason, :rows => 10))
    }
  end

  def account_controller_filters
    block = proc do
      if request.post?
        @user = environment.users.find_by_login(params[:user][:login])
        @task = ModerateUserRegistration.new
        @task.signup_reason = params[:task][:signup_reason]
        @task.requestor_id = @user.id
        @task.status = 4
        @task.save!
      end
    end

    [{ :type => 'after_filter',
      :method_name => 'create_task_with_signup_reason',
      :options => {:only => 'signup'},
      :block => block }]
  end



end

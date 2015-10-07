class SignUpReasonPlugin < Noosfero::Plugin

  def self.plugin_name
    "Sign Up Reason Plugin"
  end

  def self.plugin_description
    _("Add field in register form for the user to inform a reason to signup.")
  end

  def signup_extra_contents
    proc {
      if Environment.default.enabled?('admin_must_approve_new_users')
        content_tag(:div, labelled_form_field(_('Reason:'), text_area(:task, :signup_reason, :rows => 10)))
      end
    }
  end

  def account_controller_filters
    validate_block = proc do
      if request.post?
        if Environment.default.enabled?('admin_must_approve_new_users')
          if params[:task][:signup_reason].empty?
            @person = Person.new(params[:profile_data])
            @person.environment = environment
            @user = User.new(params[:user])
            @task = ModerateUserRegistration.new
            @task.signup_reason = params[:task][:signup_reason]
            @person.errors.add(:signup_reason, _(' invalid.'))
            render :action => :signup
          end
        end
      end
    end

    block = proc do
      if request.post?
        if Environment.default.enabled?('admin_must_approve_new_users')
          user = environment.users.find_by_login(params[:user][:login])
          unless @user.errors.any?
            @task = ModerateUserRegistration.new
            @task.signup_reason = params[:task][:signup_reason]
            @task.requestor_id = user.person.id
            @task.status = 4
            @task.save
          end
        end
      end
    end

    [
      {:type => 'before_filter',
      :method_name => 'validate_signup_reason',
      :options => {:only => 'signup'},
      :block => validate_block},
      {:type => 'after_filter',
      :method_name => 'create_task_with_signup_reason',
      :options => {:only => 'signup'},
      :block => block}
    ]
  end

end

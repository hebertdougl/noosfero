class SignUpReasonPlugin < Noosfero::Plugin

  def self.plugin_name
    "Sign Up Reason Plugin"
  end

  def self.plugin_description
    _("Add field in register form for the user to give a reason to the signup.")
  end

end

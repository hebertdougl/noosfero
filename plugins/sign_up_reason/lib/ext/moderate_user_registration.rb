require_dependency 'moderate_user_registration'

class ModerateUserRegistration

  def information
    { :message => _('%{sender} wants register. Signup Reason: %{signup_reason}'),
      :variables => {:sender => sender, :signup_reason => signup_reason} }
  end
end
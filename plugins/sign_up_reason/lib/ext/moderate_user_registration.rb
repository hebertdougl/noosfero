require_dependency 'moderate_user_registration'

class ModerateUserRegistration

  attr_accessible :signup_reason

  def information
    { :message => _('%{sender} wants register. Signup reason: %{signup_reason}'),
      :variables => {:sender => sender, :signup_reason => signup_reason} }
  end
end

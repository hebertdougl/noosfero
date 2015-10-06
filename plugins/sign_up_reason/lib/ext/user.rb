require_dependency 'user'

class User

  def create_moderate_task
    @task = ModerateUserRegistration.find_by_requestor_id(self.person.id)
    unless @task.nil?
      @task.user_id = self.id
      @task.name = self.name
      @task.email = self.email
      @task.target = self.environment
      @task.requestor = self.person
      @task.status = 1
      @task.save
    else
    end
  end

end

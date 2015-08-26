require_dependency 'user'

class User

  def create_moderate_task
    puts "&" * 200
    @task = ModerateUserRegistration.find_by_requestor_id(self.id)
    @task.user_id = self.id
    @task.name = self.name
    @task.email = self.email
    @task.target = self.environment
    @task.requestor = self.person
    @task.save
  end

end

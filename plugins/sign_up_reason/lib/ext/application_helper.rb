require_dependency 'application_helper'

module ApplicationHelper

  def task_information(task)
    values = {}
    values.merge!({:requestor => link_to(task.requestor.name, task.requestor.url)}) if task.requestor
    values.merge!({:subject => content_tag('span', task.subject, :class=>'task_target')}) if task.subject
    values.merge!({:linked_subject => link_to(content_tag('span', task.linked_subject[:text], :class => 'task_target'), task.linked_subject[:url])}) if task.linked_subject
    values.merge!({:signup_reason => content_tag('span', task.signup_reason, :class=>'task_target')}) if task.signup_reason
    values.merge!(task.information[:variables]) if task.information[:variables]

    task.information[:message] % values
  end
end


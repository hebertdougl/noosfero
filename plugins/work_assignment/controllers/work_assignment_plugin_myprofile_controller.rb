class WorkAssignmentPluginMyprofileController < MyProfileController

helper ArticleHelper
helper CmsHelper

before_filter :protect_if, :only => [:edit_visibility]

  def edit_visibility
    unless params[:article_id].blank?
      folder = profile.environment.articles.find_by_id(params[:article_id])
      @back_to = url_for(folder.parent.url)
      unless params[:article].blank?
        folder.published = params[:article][:published]
        unless params[:q].nil?
          folder.article_privacy_exceptions = params[:q].split(/,/).map{|n| environment.people.find n.to_i}
        end
        folder.save!
        redirect_to @back_to
      end
    end
   end

  def search_article_privacy_exceptions
    arg = params[:q].downcase
    result = profile.members.find(:all, :conditions => ['LOWER(name) LIKE ?', "%#{arg}%"])
    render :text => prepare_to_token_input(result).to_json
  end

  def assign_grade
    @submission = UploadedFile.find params[:submission]
    if request.post?
      @submission.grade_version = params[:grade_version]
      @submission.final_grade = params[:final_grade]
      @submission.valuation_date = Time.now
      @submission.save!
      @submission.parent.change_grade_parent @submission
      assign_final_grade @submission

      redirect_to :back
    end
  end

  def assign_final_grade(submission)
    folder = submission.parent
    folder.children.each do |f|
      if f.id != submission.id
        submission.final_grade = false
      end
    end
      submission.save!
  end

  protected

  def protect_if
    article = environment.articles.find_by_id(params[:article_id])
    render_access_denied unless (user && !article.nil? && (user.is_member_of? article.profile) &&
    article.parent.allow_visibility_edition && article.folder? &&
    (article.author == user || user.has_permission?('view_private_content', profile)))
  end

end

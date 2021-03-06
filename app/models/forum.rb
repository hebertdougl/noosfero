class Forum < Folder

  acts_as_having_posts :order => 'updated_at DESC'
  include PostsLimit

  attr_accessible :has_terms_of_use, :terms_of_use, :topic_creation

  settings_items :terms_of_use, :type => :string, :default => ""
  settings_items :has_terms_of_use, :type => :boolean, :default => false
  settings_items :topic_creation, :type => :string, :default => 'self'
  has_and_belongs_to_many :users_with_agreement, :class_name => 'Person', :join_table => 'terms_forum_people'

  before_save do |forum|
    if forum.has_terms_of_use
      last_editor = forum.profile.environment.people.find_by_id(forum.last_changed_by_id)
      if last_editor && !forum.users_with_agreement.exists?(last_editor)
        forum.users_with_agreement << last_editor
      end
    else
      forum.users_with_agreement.clear
    end
  end

  def self.type_name
    _('Forum')
  end

  def self.short_description
    _('Forum')
  end

  def self.description
    _('An internet forum, also called message board, where discussions can be held.')
  end

  module TopicCreation
    BASE = ActiveSupport::OrderedHash.new
    BASE['users'] = _('Logged users')

    PERSON = ActiveSupport::OrderedHash.new
    PERSON['self'] = _('Me')
    PERSON['related'] = _('Friends')

    GROUP = ActiveSupport::OrderedHash.new
    GROUP['self'] = _('Administrators')
    GROUP['related'] = _('Members')

    def self.general_options(forum)
      forum.profile.person? ? PERSON.merge(BASE) : GROUP.merge(BASE)
    end
  end

  include ActionView::Helpers::TagHelper
  def to_html(options = {})
    proc do
      render :file => 'content_viewer/forum_page'
    end
  end

  def forum?
    true
  end

  def self.icon_name(article = nil)
    'forum'
  end

  def notifiable?
    true
  end

  def first_paragraph
    return '' if body.blank?
    paragraphs = Nokogiri::HTML.fragment(body).css('p')
    paragraphs.empty? ? '' : paragraphs.first.to_html
  end

  def add_agreed_user(user)
    self.users_with_agreement << user
    self.save
  end

  def agrees_with_terms?(user)
    return true unless self.has_terms_of_use
    return false unless user
    self.users_with_agreement.exists? user
  end

  def can_create_topic?(user)
    return true if user == profile || profile.admins.include?(user) || profile.environment.admins.include?(user)
    case topic_creation
    when 'related'
      profile.person? ? profile.friends.include?(user) : profile.members.include?(user)
    when 'users'
      user.present?
    end
  end

  def allow_create?(user)
    super || can_create_topic?(user)
  end
end

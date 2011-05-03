class User < ActiveRecord::Base
  ACCESS_LEVELS = [
    ADMIN = "admin",
    USER  = "user"
  ]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :name, :email, :access_level

  has_many :memberships, :foreign_key => :member_id, :dependent => :destroy
  has_many :groups, :through => :memberships

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :password, :password_confirmation, :remember_me

  def admin?
    ADMIN == self.access_level
  end

  def administrated_groups
    self.memberships.select{ |m| m.group_admin? }.map(&:group)
  end

  def reached_max_search_limit?(group)
    Search.reached_max_limit?(self, group)
  end

  def member_of?(group)
    group.is_a?(Group) && group_ids.include?(group.id)
  end

  def group_admin_of?(group)
    group.membership_for(user).try(:group_admin?)
  end
end

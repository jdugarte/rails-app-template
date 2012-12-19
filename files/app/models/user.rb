class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :confirmable, 
         :recoverable, :rememberable, :trackable, :validatable
  
  attr_accessible :username, :name, :email, :password, :password_confirmation, :remember_me

  validates :username, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :name, :presence => true
  validates :email, :uniqueness => { :case_sensitive => false }
  
  attr_accessible :avatar
  has_attached_file :avatar, :styles => { :profile => "100x100>", :thumb => "50x50>" }, 
                             :convert_options => { :profile => "-thumbnail 100x100", :thumb => "-thumbnail 50x50" }

  validates_attachment_size :avatar, :less_than=>100.kilobytes, :message => "must be less than 100 Kb"
  validates_attachment_content_type :avatar, :content_type=>['image/jpeg', 'image/png', 'image/gif'] 

  has_and_belongs_to_many :following, :class_name => "User", 
                          :join_table => "friends", 
                          :association_foreign_key => "friend_id", 
                          :order => :name, :uniq => true
  has_and_belongs_to_many :followers, :class_name => "User", 
                          :join_table => "friends", 
                          :foreign_key => "friend_id", 
                          :association_foreign_key => "user_id", 
                          :order => :name, :uniq => true
  
  def self.search(search = "", me = nil)
    search = search.split("@").first unless search.nil?
    return [] if search.blank?
    where("username LIKE ? or name LIKE ? or email LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%@%").
    where('id != ?', me.try(:id) || 0).
    limit(50)
  end
  
end

class User < ActiveRecord::Base

  devise :database_authenticatable, :confirmable, 
         :recoverable, :rememberable, :trackable, :validatable
  
  attr_accessible :username, :name, :email, :password, :password_confirmation, :remember_me, :admin

  validates :username, :presence => true, :uniqueness => { :case_sensitive => false }
  validates :name, :presence => true
  validates :email, :uniqueness => { :case_sensitive => false }
  
  attr_accessible :avatar
  has_attached_file :avatar, :styles => { :profile => "100x100>", :thumb => "50x50>" }, 
                             :convert_options => { :profile => "-thumbnail 100x100", :thumb => "-thumbnail 50x50" }

  validates_attachment_size :avatar, :less_than=>100.kilobytes, :message => "must be less than 100 Kb"
  validates_attachment_content_type :avatar, :content_type=>['image/jpeg', 'image/png', 'image/gif'] 

end

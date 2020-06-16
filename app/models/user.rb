class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  attr_accessor :remember_token
  before_save { self.email = email.downcase }
  
  validates :name,  presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :department, length: { in: 2..50 }, allow_blank: true
  #validates :basic_work_time, presence: true
  #validates :designated_work_start_time, presence: true
  #validates :designated_work_end_time, presence: true
  validates :work_time, presence: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def self.search(search)
    if search
      User.where(['name LIKE ?',"%#{search}%"])
    else
      User.all
    end
  end
  
  def self.import(file)
    CSV.foreach(file.path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
      user =  find_by(id: row["id"]) || new
      user.attributes = row.to_hash.slice(*updatable_attributes)
      user.save!
    end
  end
  
  # 更新を許可するカラムを定義
  def self.updatable_attributes
    ["name", "email", "department", "employee_number", "uid", "password",
    "basic_work_time", "designated_work_start_time", "designated_work_end_time",
    "superior", "admin"]
  end
  
end

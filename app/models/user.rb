class User < ActiveRecord::Base
    
    attr_accessor :remember_token, :activation_token
    
    before_save :downcase_email
    before_create :create_activation_digest
    validates(:name, presence: true);
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates(:email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false});
    validates( :name,  presence: true, length: { maximum: 50 })
    validates( :email, presence: true, length: { maximum: 255 })
    has_secure_password
    validates( :password, presence: true, length: { minimum: 6 }, allow_nil: true)
    
    #returns the hash digest of a given string
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        
        BCrypt::Password.create(string, cost: cost)
    end
    
    #returns a random token string
    def User.new_token
        SecureRandom.urlsafe_base64
    end
    
    #remembers a user in the database for use in persistent sessions
    def remember 
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end
    
    #returns true if the given token matches the digest
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end
    
    #forgets a user
    def forget 
       update_attribute(:remember_digest, nil) 
    end
    
    #activated a user account
    def activate 
        update_attribute(:activated, true)
        update_attribute(:activated_at, Time.zone.now)
    end
    
    #sends an activation email
    def send_activation_email
       UserMailer.account_activation(self).deliver_now 
    end
    
    
    private 
    
        #converts an email to all lowercase
        def downcase_email
            self.email = self.email.downcase 
        end
    
        def create_activation_digest 
            self.activation_token = User.new_token
            self.activation_digest = User.digest(self.activation_token)
        end
        
end

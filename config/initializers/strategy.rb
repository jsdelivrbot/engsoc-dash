Warden::Strategies.add(:interpret_headers) do
  def valid?
    if Rails.env.production?
      # code here to check whether to try and authenticate using this strategy;
      return true
    end
  end

  def authenticate!
    user_email = request.headers["HTTP_EMAIL"]
    user_givenName = request.headers["givenName"]
    user_surname = request.headers["surname"]
    if user = User.where(:email => user_email).present?
      success!(user)
    else
      new_user = User.new(:email => user_email,
                     :first_name => user_givenName,
                      :last_name => user.surname)
      if new_user.save
        success!(new_user)
      else
        message = "Could not initialize your account at this time, please contact 12sj16@queensu.ca"
        fail!(message)
      end
    end
  end
end
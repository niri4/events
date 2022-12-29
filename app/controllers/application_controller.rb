class ApplicationController < ActionController::API
  # with authentication this method removed
  def current_user
    User.find_or_create_by(id: 1)
  end
end

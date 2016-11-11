class StaticPagesController < ApplicationController
  before_action :admin_user, only: [:admin]
  
  def home
    redirect_to current_user if logged_in?
  end
  
  def admin
    
  end
  
  def letsencrypt
    render text: ENV["LETS_ENCRYPT_KEY"]
  end
 
end

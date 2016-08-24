class StaticPagesController < ApplicationController
  before_action :admin_user, only: [:admin]
  
  def home
    redirect_to current_user if logged_in?
  end
  
  def admin
    
  end
  
  def letsencrypt
    render text: "PXBhfS59R3qA6VQovuWg6ClTC3xAZJaX9ivpYYoTK1k.CVdYVvLUZrSKMaO47kARZTGMHyRaz5zQgRNMa7gtC_A"
  end
 
end

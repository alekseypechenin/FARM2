class ApplicationController < ActionController::Base

 def login_required
    if session[:user]
      return true
    end
    render :text => 'Access denied'
  end

  def current_user
    u=User.find(:first, :conditions=>["id = ?", session[:user]])
    return nil if u.nil?
    return u
  end
  
end

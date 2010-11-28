class UserController < ApplicationController

  def users_xml
     @users = User.all
     render :xml => @users
  end

  def signup_xml
    @user = User.new(params[:user])
     if @user.save
        session[:user] = @user.id
        render :xml => @user
     else
        render :text => "error"
     end
  end

  def login_xml
     if @users = User.authenticate(params[:login], params[:password])
       session[:user] = @users.id
       render :xml => @users
     else
       render :text => "error"
     end
  end

  def logout
    session[:user] = nil
  end

  def forgot_password
     @user = User.find_by_email(params[:user][:email])
     if u and u.send_new_password
        render :xml => @user
     else
        render :text => "error"
     end
  end
end

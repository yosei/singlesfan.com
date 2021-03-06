class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  PASSWORD_NULL = 'nullnull'
  
  protected
    def check_auth
      if ! session[:master_id]
        redirect_to login_path
      end
    end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # ************** http basic authentication below ************
  #http_basic_authenticate_with name: "Grant", password: "Winter"
  protect_from_forgery with: :exception
  include SessionsHelper
end

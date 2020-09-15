class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # デフォルトで全てのヘルパーはビューで使用できるが、コントローラーでは使用可能になっていないため、SessionsHelperをincludeする
  include SessionsHelper
end

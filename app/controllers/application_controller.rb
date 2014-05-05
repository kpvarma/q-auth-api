class ApplicationController < ActionController::Base

  include ActionController::HttpAuthentication::Token::ControllerMethods

  include AbstractController::Layouts
  include AbstractController::Translation
  include ActionController::ImplicitRender
  include ActionController::Helpers

  layout 'application'

end

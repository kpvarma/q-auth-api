module Api
  module V1
    class BaseController < ApplicationController

      before_filter :require_user

      protected

      def current_user
        @current_user
      end

      def require_user
        # Check if the user exists with the auth token present in request header
        @current_user = authenticate_with_http_token { |token, options| User.find_by(auth_token: token) }
        unless @current_user
          proc_code = Proc.new do
            @alert = I18n.translate("response.authentication_error")
            raise AuthenticationError
          end
          render_json_response(proc_code)
          return
        end
      end

      ## This method will accept a proc, execute it and render the json
      def render_json_response(proc_code)

        begin
          #raise AuthenticationError unless @current_user
          proc_code.call
          @status ||= 200
          @success = @success == false ? (false) : (true)

        rescue ValidationError, InvalidLoginError, FailedToCreateError, FailedToUpdateError, FailedToDeleteError, AuthenticationError => e
          @status = 200
          @success = false

          @data = {
                    errors: {
                      name:  e.message,
                      description: I18n.translate("response.#{e.message.underscore}")
                    }
                  }
          @data[:errors][:details] = @errors unless @errors.blank?

          if Rails.env == "development" || ["true", "t", "1", "yes"].include?(params[:debug].to_s.downcase.strip)
            @data[:errors][:stack] = e.backtrace
          end

        rescue Exception => e

          @data = {
                    errors: {
                      name:  e.message,
                      description: I18n.translate("response.#{e.message.underscore}"),
                      details: @errors
                    }
                  }
          if Rails.env == "development" || ["true", "t", "1", "yes"].include?(params[:debug].to_s.downcase.strip)
            @data[:errors][:stack] = e.backtrace
          end

        end

        response_hash = {success: @success}
        response_hash[:alert] = @alert unless @alert.blank?
        response_hash[:total_data] = @total_data unless @total_data.blank?
        response_hash[:per_page] = @per_page unless @per_page.blank?
        response_hash[:current_page] = @current_page unless @current_page.blank?
        response_hash[:data] = @data unless @data.blank?

        render status: @status, json: response_hash
        return

      end

    end
  end
end

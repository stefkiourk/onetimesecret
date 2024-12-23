
require_relative '../../altcha'
require_relative 'base'

module Onetime::Logic
  module Misc

    class ReceiveFeedback < OT::Logic::Base
      attr_reader :msg, :authenticity_payload, :verified, :verification_data, :greenlighted, :tz, :version

      def process_params
        @msg = params[:msg].to_s.slice(0, 999)
        @authenticity_payload = params[:authenticity_payload].to_s.slice(0, 999)
        @tz = params[:tz].to_s.slice(0, 64)
        @version = params[:version].to_s.slice(0, 32)
      end

      def raise_concerns
        limit_action :send_feedback

        raise_form_error "You can be more original than that!" if @msg.empty?

        if cust.anonymous?
          raise_form_error "Cannot skip authenticity check" if authenticity_payload.empty?
          raise_form_error "You need to be carbon-based to do that" unless verify_authenticity_payload
        end
      end

      def verify_authenticity_payload
        @verified = Altcha.verify_solution(authenticity_payload, secret_key)
      end

      def filter_spam_authenticity_payload
        # authenticity_payload is a base64 encoded JSON string.
        @verified, @verification_data = Altcha.verify_server_signature(authenticity_payload, secret_key)

        fields_verified = Altcha.verify_fields_hash(
          params,
          verification_data.fields,
          verification_data.fields_hash,
          'SHA-256'
        )

        verified && fields_verified
      end

      def process
        @greenlighted = true
        @msg = format_feedback_message
        OT.ld [:receive_feedback, msg].inspect
        OT::Feedback.add @msg
      end

      def format_feedback_message
        identifier = cust.anonymous? ? sess.ipaddress : cust.custid
        "#{msg} [#{identifier}] [TZ: #{tz}] [v#{version}]"
      end
      private :format_feedback_message

      def success_data
        {
          success: greenlighted,
          record: {
          },
          details: {
            message: "Message received. Send as much as you like!"
          }
        }
      end

      def secret_key
        OT.conf.dig(:site, :authenticity, :secret_key) # ALTCHA_HMAC_KEY
      end
    end

  end
end

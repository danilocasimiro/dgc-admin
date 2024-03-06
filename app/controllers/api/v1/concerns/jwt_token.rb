# frozen_string_literal: true

module Api
  module V1
    module Concerns
      module JwtToken
        extend ActiveSupport::Concern

        def feth_decoded_jwt
          header = request.headers['Authorization']
          token = header&.split&.last

          begin
            jwt_token =
              JWT.decode(token, Figaro.env.jwt_secret, true, algorithm: 'HS256')
            jwt_token.first.is_a?(Array) ? jwt_token.first : jwt_token
          rescue JWT::DecodeError
            raise UnauthorizedError, 'Necessário autenticação'
          end
        end

        # rubocop:disable Metrics/MethodLength
        def self.generate_token(user, company_id = nil)
          company = Company.find(company_id) if company_id

          JWT.encode({
                       user: {
                         email_address: user.email_address,
                         friendly_id: user.friendly_id,
                         name: user.name,
                         id: user.id,
                         type: user.type,
                         expiration_date: user.expiration_date,
                         subscription_status: subscription_status(user),
                         company_name: company&.name,
                         company_id:,
                         menu: user.menu(company).as_json
                       }
                     }, Figaro.env.jwt_secret, 'HS256')
        end
        # rubocop:enable Metrics/MethodLength

        def user_authenticate?
          feth_decoded_jwt
        end

        def company_authenticate?
          return false if current_company_id

          render json: { error: 'Necessário autenticação em uma empresa' },
                 status: :unauthorized
        end

        def current_company_id
          feth_decoded_jwt.first.dig('user', 'company_id')
        end

        def current_user
          id = fetch_user_claim.dig('user', 'id')
          User.find(id)
        end

        def fetch_user_claim
          feth_decoded_jwt.find { |token| token.key? 'user' }
        end

        def self.subscription_status(user)
          if user.needs_subscription_to_access &&
             user.profile.allow_access?
            'active'
          end
        end
      end
    end
  end
end

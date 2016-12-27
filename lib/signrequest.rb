require 'signrequest/version'

require 'rest-client'
require 'oj'

# Main Module for Signrequest gem
module SignRequest
  class SignRequestError < StandardError; end

  # API module for gem
  module API
    # Constants for the API enpoints
    #
    # TOKEN_REQUEST_ENDPOINT is used for authentication with username and passwd
    #   to obtain an API token.
    #
    # DOCUMENT_ENDPOINT is used to create a document, and is also the base url
    #   for any created documents (e.g. BASE/document_id).
    #
    # SIGNATURE_ENDPOINT is used to request a signature for a given document.
    TOKEN_REQUEST_ENDPOINT = 'https://signrequest.com/api/v1/api-tokens/'.freeze
    DOCUMENT_ENDPOINT      = 'https://signrequest.com/api/v1/documents/'.freeze
    SIGNATURE_ENDPOINT     = 'https://signrequest.com/api/v1/signrequests/'.freeze

    def self.handle_restclient_error(response_code, error_message)
      response = {}
      response['code'] = response_code
      response['body'] = Oj.load(error_message.response)

      response
    end
    # Authentication with username and password to receive a token for the
    # SignRequest API.
    #
    # The authenticate method will, upon success, return a JSON object
    # containing {"token": "<token>", "created": true}
    def self.authenticate(user, passwd, subdomain)
      res = RestClient::Request.execute(
        method:   :post,
        user:     user,
        password: passwd,
        payload:  "subdomain=#{subdomain}",
        url:      TOKEN_REQUEST_ENDPOINT
      )
      # On Success:
      #   response.code = 201
      #   response.body = '{"token":<token>,"created":true}'
      response = {}
      response['code'] = res.code.to_i
      response['body'] = Oj.load res.body if response['code'] == 201

      response
    rescue RestClient::Forbidden => error_message
      # RestClient::Forbidden
      #   On invalid user/password
      #   On invalid subdomain
      handle_restclient_error(403, error_message)
    rescue RestClient::BadRequest => error_message
      # RestClient::BadRequest
      #   When no subdomain is given
      handle_restclient_error(400, error_message)
    end

    def self.valid_args?(received, args_list)
      error_message = "Payload requires #{args_list.length} arguments: " \
      "#{args_list * ', '} (Received #{received})"

      raise ArgumentError, error_message unless received == args_list.length
    end

    def self.create_document_from_file(token, *payload_args)
      valid_args?(payload_args.size, %w(file external_id))

      res = RestClient::Request.execute(
        method:  :post,
        headers: {
          Authorization: "Token #{token}",
          content_type:  'multipart/form-data'
        },
        payload: {
          multipart:   true,
          file:        File.new(payload_args[0], 'rb'),
          external_id: payload_args[1]
        },
        url: DOCUMENT_ENDPOINT
      )
    rescue error_message
      # temporary to determine probable errors
      p error_message
      p error_message.response
    end

    def self.create_document_from_url(token, *payload_args)
      valid_args?(payload_args.size, %w(file_from_url external_id))

      res = RestClient::Request.execute(
        method: :post,
        headers: {
          Authorization: "Token #{token}",
          content_type:  :json
        },
        payload: {
          'file_from_url' => payload_args[0],
          'external_id'   => payload_args[1]
        },
        url: DOCUMENT_ENDPOINT
      )
    rescue error_message
      # temporary to determine probable errors
      p error_message
      p error_message.response
    end

    def self.create_sign_request(token, *payload_args)
      valid_args?(payload_args.size, %w(document from_email message signers))

      res = RestClient::Request.execute(
        method: :post,
        headers: {
          Authorization: "Token #{token}",
          content_type:  :json
        },
        payload: {
          document:   payload_args[0],
          from_email: payload_args[1],
          message:    payload_args[2],
          signers:    payload_args[3]
        },
        url: SIGNATURE_ENDPOINT
      )

    rescue error_message
      # temporary to determine probable errors
      p error_message
      p error_message.response
    end

    def self.sign_request_reminder(token, *payload_args)
    #   valid_args?(payload_args.size, %w())
    #
    #   res = RestClient::Request.execute(
    #     method: :post,
    #     headers: {
    #
    #     },
    #     payload: {
    #
    #     },
    #     url: URL
    #   )
    #
    #   res.code == 201 ? Oj.load res.body : raise SignRequestError, "#{res.code}"
    # rescue error_message
    #   # temporary to determine probable errors
    #   p error_message
    #   p error_message.response
    end
  end
end

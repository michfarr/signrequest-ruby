require 'signrequest/version'

require 'rest-client'
require 'oj'

# Main Module for Signrequest gem
module SignRequest
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

    # Authentication with username and password to receive a token for the
    # SignRequest API.
    #
    # The authenticate method will, upon success, return a JSON object
    # containing {"token": "<token>", "created": true}
    def authenticate(user, passwd, subdomain)
      RestClient::Request.execute(
        method:   :post,
        user:     user,
        password: passwd,
        payload:  "subdomain=#{subdomain}",
        url:      TOKEN_REQUEST_ENDPOINT
      )
    end

    def valid_args?(received, required, args_list)
      error_message = "Payload requires #{required} arguments: " \
      "#{args_list * ', '} (Received #{received}"

      raise ArgumentError, error_message unless received == required
    end

    def local_create_document(token, *payload_args)
      valid_args?(payload_args.size, 2, %w(file external_id))

      RestClient::Request.execute(
        method:  :post,
        headers: {
          Authoriaation: "Token #{token}",
          content_type:  'multipart/form-data'
        },
        payload: {
          multipart:   true,
          file:        payload_args[0],
          external_id: payload_args[1]
        },
        url: DOCUMENT_ENDPOINT
      )
    end

    def remote_create_document
      valid_args?(payload_args.size, 2, %w(file_from_url external_id))

      RestClient::Request.execute(
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
    end

    def sign_request(token, *payload_args)
      valid_args?(payload_args.size, 4, %w(document from_email message signers))

      RestClient::Request.execute(
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
    end
  end
end

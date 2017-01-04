require 'signrequest/version'

require 'rest-client'
require 'json'

# Main Module for Signrequest gem
module SignRequest
  # API module for gem
  module API
    # Endpoints using API_BASE_URL
    # /api-tokens/                Authentication / Token Creation (POST)
    # /documents/                 Document Creation / Listing     (POST / GET)
    # /signrequest/               Sign Request Creation / Listing (POST / GET)
    # /signrequest_quick_create   Doc & Sign Request Creation     (POST)
    # /documents/{doc_uuid}/            Uploaded PDF
    # /signrequest/{signrequest_uuid}/  Created Sign Request
    # /signrequest/{sr_uuid}/resend_signrequest_email/

    API_BASE_URL = "https://#{ENV['SIGNREQUEST_SUBDOMAIN'].to_s + '.'}" \
      'signrequest.com/api/v1'.freeze if ENV['SIGNREQUEST_SUBDOMAIN']

    API_BASE_URL = 'https://signrequest.com/api/v1'.freeze if !API_BASE_URL

    def self.handle_restclient_error(response_code, error_message)
      response = {
        'code': response_code,
        'body': JSON.parse(error_message)
      }
    end

    # API_BASE_URL  /api-tokens/
    # POST: 201 Created

    # application/json
    # {
    #   "email": "{email}",
    #   "password": "{password}",
    #   "subdomain": "{subdomain}",
    #   "name": "{token_name}"
    # }

    # RESPONSE
    # {
    #   "token": "{token}",
    #   "created": true
    # }
    def self.authenticate(user, passwd, subdomain)
      res = RestClient::Request.execute(
        method:   :post,
        user:     user,
        password: passwd,
        payload:  "subdomain=#{subdomain}",
        url:      API_BASE_URL + '/api-tokens/'
      )

      response = {
        'code': res.code,
        'body': JSON.parse(res.body)
      }
    rescue RestClient::Forbidden => err
      # RestClient::Forbidden
      #   On invalid user/password
      #   On invalid subdomain
      handle_restclient_error(403, err.response)
    rescue RestClient::BadRequest => err
      # RestClient::BadRequest
      #   When no subdomain is given
      handle_restclient_error(400, err.response)
    end

    # API_BASE_URL  /documents/
    # GET: 200 Ok, POST: 201 Created

    # multipart/form-data
    # {
    #     "name": "",
    #     "external_id": "external_id_goes_here",
    #     "file": /path/to/file/pdf.pdf,
    #     "file_from_url": null,
    #     "events_callback_url": "",
    #     "file_from_content": "",
    #     "file_from_content_name": "",
    #     "template": null,
    #     "integrations": []
    # }

    # RESPONSE
    # {
    #   "url": "https://{subdomain}.signrequest.com/api/v1/documents/{uuid}/",
    #   "team": {
    #     "name": "TeamName",
    #     "subdomain": "{subdomain}",
    #     "url": "https://{subdomain}.signrequest.com/api/v1/teams/{subdomain}/"
    #   },
    #   "uuid": "{uuid}",
    #   "user": null,
    #   "file_as_pdf": "https: //signrequest-pro.s3.amazonaws.com/docs/yyyy/mm/dd/abc123xyz/pdf.pdf?Signature=somethinghere&Expires=1483369044&AWSAccessKeyId=1234ABCD",
    #   "name": "pdf.pdf",
    #   "external_id": "external_id_goes_here",
    #   "file": "https: //signrequest-pro.s3.amazonaws.com/docs/yyyy/mm/dd/abc123xyz/pdf.pdf?Signature=somethinghere&Expires=1483369044&AWSAccessKeyId=1234ABCD",
    #   "file_from_url": null,
    #   "template": null,
    #   "pdf": null,
    #   "status": "co",
    #   "signrequest": null,
    #   "api_used": true,
    #   "signing_log": null,
    #   "security_hash": null,
    #   "integrations": []
    # }

    def self.create_document_from_file(token, file_path)
      res = RestClient::Request.execute(
        method:  :post,
        headers: {
          Authorization: "Token #{token}",
          content_type:  'multipart/form-data'
        },
        payload: {
          multipart:   true,                      # Required
          file:        File.new(file_path, 'rb')  # Required
        },
        url: API_BASE_URL + '/documents/'
      )

      response = {
        'code': res.code,
        'body': JSON.parse(res.body)
      }
    rescue RestClient::Unauthorized => err
      handle_restclient_error(401, err.response)
    rescue Errno::ENOENT => err
      handle_restclient_error(404, '{"Errno::ENOENT":"File not found."}')
    end

    # API_BASE_URL  /documents/
    # GET: 200 Ok, POST: 201 Created

    # application/json
    # {
    #     "name": "filename.pdf",
    #     "external_id": "this-is-my-id",
    #     "file": null,
    #     "file_from_url": "https://url.to.site/file.pdf",
    #     "events_callback_url": "",
    #     "file_from_content": "",
    #     "file_from_content_name": "",
    #     "template": null,
    #     "integrations": []
    # }

    # RESPONSE
    # {
    #     "url": "https://{subdomain}.signrequest.com/api/v1/documents/{uuid}/",
    #     "team": {
    #         "name": "TeamName",
    #         "subdomain": {subdomain},
    #         "url": "https://{subdomain}.signrequest.com/api/v1/teams/{subdomain}/"
    #     },
    #     "uuid": "{uuid}",
    #     "user": {
    #         "email": "user@email.com",
    #         "first_name": "User",
    #         "last_name": "Name",
    #         "display_name": "User Name (user@email.com)"
    #     },
    #     "file_as_pdf": "https://signrequest-pro.s3.amazonaws.com/docs/yyyy/mm/dd/something-goes-here/filename.pdf?Signature=stuffhere&Expires=1483368081&AWSAccessKeyId=ACCESSKEY",
    #     "name": "filename.pdf",
    #     "external_id": "this-is-my-id",
    #     "file": "https://signrequest-pro.s3.amazonaws.com/docs/yyyy/mm/dd/something-goes-here/filename.pdf?Signature=stuffhere&Expires=1483368081&AWSAccessKeyId=ACCESSKEY",
    #     "file_from_url": "https://url.to.site/file.pdf",
    #     "template": null,
    #     "pdf": null,
    #     "status": "co",
    #     "signrequest": null,
    #     "api_used": true,
    #     "signing_log": null,
    #     "security_hash": null,
    #     "integrations": []
    # }
    def self.create_document_from_url(token, file_url)
      res = RestClient::Request.execute(
        method: :post,
        headers: {
          Authorization: "Token #{token}",
          content_type:  :json
        },
        payload: {
          'file_from_url' => file_url, # Required
        },
        url: API_BASE_URL + '/documents/'
      )

      response = {
        'code': res.code,
        'body': JSON.parse(res.body)
      }
    rescue RestClient::Unauthorized => err
      handle_restclient_error(401, err.response)
    rescue RestClient::InternalServerError => err
      handle_restclient_error(500, '{"Error":"Internal Server Error."}')
    end

    # API_BASE_URL  /signrequests/
    # GET, POST

    # application/json
    # {
    #   "from_email": "",
    #   "from_email_name": "",
    #   "required_attachments": [],
    #   "disable_attachments": false,
    #   "disable_text_signatures": false,
    #   "disable_text": false,
    #   "disable_date": false,
    #   "disable_upload_signatures": false,
    #   "subject": "",
    #   "message": "",
    #   "who": null,
    #   "send_reminders": false,
    #   "signers": [],
    #   "document": null,
    #   "integration": null,
    #   "integration_data": ""
    # }

    # SIGNERS
    # {
    #     "email": "signee@example.com",
    #     "display_name": "The Signee (signee@example.com)",
    #     "first_name": "The",
    #     "last_name": "Signee",
    #     "attachments": [],
    #     "needs_to_sign": false,
    #     "language": "en",
    #     "force_language": false,
    #     "message": null,
    # }

    # RESPONSE
    # {
    #     "from_email": "sender@request.com",
    #     "from_email_name": "This is my name, I put what I want here",
    #     "required_attachments": [],
    #     "disable_attachments": false,
    #     "disable_text_signatures": false,
    #     "disable_text": false,
    #     "disable_date": false,
    #     "disable_upload_signatures": false,
    #     "subject": "Email subject.",
    #     "message": "Email body.",
    #     "who": "o",
    #     "send_reminders": false,
    #     "signers": [
    #         {
    #             "email": "sender@request.com",
    #             "display_name": "The Sender (sender@request.com)",
    #             "first_name": "The",
    #             "last_name": "Sender",
    #             "attachments": [],
    #             "email_viewed": false,
    #             "viewed": false,
    #             "signed": false,
    #             "downloaded": false,
    #             "signed_on": null,
    #             "needs_to_sign": false,
    #             "approve_only": false,
    #             "in_person": false,
    #             "order": 0,
    #             "emailed": false,
    #             "language": "en",
    #             "force_language": false,
    #             "verify_phone_number": null,
    #             "verify_bank_account": null,
    #             "declined": false,
    #             "declined_on": null,
    #             "message": null,
    #             "redirect_url": null,
    #             "after_document": null,
    #             "embed_url": null,
    #             "embed_url_user_id": null
    #         },
    #         {
    #             "email": "signer@email.com",
    #             "display_name": "signer@email.com",
    #             "first_name": "Some",
    #             "last_name": "User",
    #             "attachments": [],
    #             "email_viewed": false,
    #             "viewed": false,
    #             "signed": false,
    #             "downloaded": false,
    #             "signed_on": null,
    #             "needs_to_sign": true,
    #             "approve_only": false,
    #             "in_person": false,
    #             "order": 0,
    #             "emailed": false,
    #             "language": "en",
    #             "force_language": false,
    #             "verify_phone_number": null,
    #             "verify_bank_account": null,
    #             "declined": false,
    #             "declined_on": null,
    #             "message": "Personalize this for the user?",
    #             "redirect_url": null,
    #             "after_document": null,
    #             "embed_url": null,
    #             "embed_url_user_id": null
    #         }
    #     ],
    #     "uuid": "{uuid}",
    #     "url": "https://{subdomain}.signrequest.com/api/v1/signrequests/{uuid}/",
    #     "document": "https://{subdomain}.signrequest.com/api/v1/documents/{document_uuid}/"
    # }
    def self.create_sign_request(token, document_url, signers_array)
      res = RestClient::Request.execute(
        method: :post,
        headers: {
          Authorization: "Token #{token}",
          content_type:  :json
        },
        payload: {
          document:   document_url, # Required (document_uuid)
          signers:    signers_array  # Required (see above, email required)
        },
        url: API_BASE_URL + '/signrequests/'
      )

      response = {
        'code': res.code,
        'body': JSON.parse(res.body)
      }
    end

    # API_BASE_URL  /signrequests/{signrequest_uuid}/resend_signrequest_email/
    # POST: 201 Created
    def self.resend_sign_request(token, signrequest_uuid)
      res = RestClient::Request.execute(
        method: :post,
        headers: {
          Authorization: "Token #{token}",
          content_type: :json
        },
        url: API_BASE_URL + '/signrequests/' + signrequest_uuid +
          '/resend_signrequest_email/'
      )

      response = {
        'code': res.code,
        'body': JSON.parse(res.body)
      }
    end

    # API_BASE_URL  /signrequest_quick_create/
    # POST: 201 Created
    # POST: 201 Created

    # multipart/form-data
    # {
    #     "from_email": "",
    #     "from_email_name": "",
    #     "required_attachments": [],
    #     "disable_attachments": false,
    #     "disable_text_signatures": false,
    #     "disable_text": false,
    #     "disable_date": false,
    #     "disable_upload_signatures": false,
    #     "subject": "",
    #     "message": "",
    #     "who": null,
    #     "send_reminders": false,
    #     "signers": [],
    #     "integration": null,
    #     "integration_data": "",
    #     "name": "",
    #     "external_id": "",
    #     "file": null,
    #     "file_from_url": "",
    #     "events_callback_url": "",
    #     "file_from_content": "",
    #     "file_from_content_name": "",
    #     "template": null
    # }

    # SIGNERS
    # {
    #     "email": "signee@example.com",
    #     "display_name": "The Signee (signee@example.com)",
    #     "first_name": "The",
    #     "last_name": "Signee",
    #     "attachments": [],
    #     "needs_to_sign": false,
    #     "language": "en",
    #     "force_language": false,
    #     "message": null,
    # }
    def self.quick_create_signrequest_from_file(token, pdf_path, signers_array)
      res = RestClient::Request.execute(
        method: :post,
        headers: {
          Authorization: "Token #{token}",
          content_type: 'multipart/form-data'
        },
        payload: {
          multipart: true,                # Required
          file: File.new(pdf_path, 'rb'), # Required
          signers: signers_array          # Required
        },
        url: API_BASE_URL + '/signrequest_quick_create/'
      )

      response = {
        'code': res.code,
        'body': JSON.parse(res.body)
      }
    end

    # API_BASE_URL  /signrequest_quick_create/
    # POST: 201 Created

    # application/json
    # {
    #     "from_email": "",
    #     "from_email_name": "",
    #     "required_attachments": [],
    #     "disable_attachments": false,
    #     "disable_text_signatures": false,
    #     "disable_text": false,
    #     "disable_date": false,
    #     "disable_upload_signatures": false,
    #     "subject": "",
    #     "message": "",
    #     "who": null,
    #     "send_reminders": false,
    #     "signers": [],
    #     "integration": null,
    #     "integration_data": "",
    #     "name": "",
    #     "external_id": "",
    #     "file": null,
    #     "file_from_url": "",
    #     "events_callback_url": "",
    #     "file_from_content": "",
    #     "file_from_content_name": "",
    #     "template": null
    # }

    # SIGNERS
    # {
    #     "email": "signee@example.com",
    #     "display_name": "The Signee (signee@example.com)",
    #     "first_name": "The",
    #     "last_name": "Signee",
    #     "attachments": [],
    #     "needs_to_sign": false,
    #     "language": "en",
    #     "force_language": false,
    #     "message": null,
    # }
    def self.quick_create_signrequest_from_url(token, pdf_url, signers_array)
      RestClient::Request.execute(
        method: :post,
        headers: {
          Authorization: "Token #{token}",
          content_type: :json
        },
        payload: {
          file_from_url: pdf_url, # Required
          signers: signers_array  # Required
        },
        url: API_BASE_URL + '/signrequest_quick_create/'
      )

      response = {
        'code': res.code,
        'body': JSON.parse(res.body)
      }
    end
  end
end

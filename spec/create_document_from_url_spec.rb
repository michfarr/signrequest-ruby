require 'spec_helper'

describe SignRequest::API do
  describe '.create_document_from_url' do
    DocUrl  = Struct.new(:token, :url)

    valid   = DocUrl.new(ENV['SIGNREQUEST_TOKEN'], ENV['SIGNREQUEST_PDF_URL'])
    invalid = DocUrl.new('invalid',
                         'https://signrequest.com/api/v1/documents/its_a_trap/')

    context 'the document is created from a url' do
      response = SignRequest::API.create_document_from_url(valid.token,
                                                           valid.url)

      describe response do
        it { is_expected.to include(:code) }
        it { is_expected.to include(:body) }
      end

      describe response[:code] do
        it { is_expected.to eq 201 }
      end

      describe response[:body] do
        it { is_expected.to include('url') }
        it { is_expected.to include('team') }
        it { is_expected.to include('uuid') }
        it { is_expected.to include('user') }
        it { is_expected.to include('file_as_pdf') }
        it { is_expected.to include('name') }
        it { is_expected.to include('external_id') }
        it { is_expected.to include('file') }
        it { is_expected.to include('file_from_url') }
        it { is_expected.to include('template') }
        it { is_expected.to include('pdf') }
        it { is_expected.to include('status') }
        it { is_expected.to include('signrequest') }
        it { is_expected.to include('api_used') }
        it { is_expected.to include('signing_log') }
        it { is_expected.to include('security_hash') }
        it { is_expected.to include('integrations') }
      end
    end

    context 'the document creation fails' do
      context 'no token is provided' do
        response = SignRequest::API.create_document_from_url(
                     invalid.token,
                     valid.url
                   )

        describe response do
          it { is_expected.to include :code }
          it { is_expected.to include :body }
        end

        describe response[:code] do
          it { is_expected.to eq 401 }
        end

        describe response[:body] do
          it { is_expected.to match( 'detail' => 'Invalid token' ) }
        end
      end

      context 'url is invalid' do
        response = SignRequest::API.create_document_from_url(
                     valid.token,
                     invalid.url
                   )

        describe response do
          it { is_expected.to include :code }
          it { is_expected.to include :body }
        end

        describe response[:code] do
          it { is_expected.to eq 500 }
        end

        describe response[:body] do
          it { is_expected.to match( 'Error' => 'Internal Server Error.') }
        end
      end
    end
  end
end

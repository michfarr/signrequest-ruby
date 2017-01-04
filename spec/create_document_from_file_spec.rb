require 'spec_helper'

describe SignRequest::API do
  describe '.create_document_from_file' do
    DocFile = Struct.new(:token, :file_path)

    valid   = DocFile.new(ENV['SIGNREQUEST_TOKEN'], ENV['SIGNREQUEST_PDF_FILE'])
    invalid = DocFile.new('invalid', '/not/a/path')
    null    = DocFile.new(nil, nil)

    context 'the document creation is successful' do
      response = SignRequest::API.create_document_from_file(
                   valid.token,
                   valid.file_path
                 )

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

    context 'the document creation is unsuccessful' do
      context 'the token is invalid and authorization fails' do
        response = SignRequest::API.create_document_from_file(
                     invalid.token,
                     valid.file_path
                   )

        describe response do
          it { is_expected.to include :code }
          it { is_expected.to include :body }
        end

        describe response[:code] do
          it { is_expected.to eq 401 }
        end

        describe response[:body] do
          it { is_expected.to match( 'detail' => /^[A-Za-z\s]+.$/ ) }
        end
      end

      context 'the file is invalid' do
        response = SignRequest::API.create_document_from_file(
                     valid.token,
                     invalid.file_path
                   )

        describe response do
          it { is_expected.to include :code }
          it { is_expected.to include :body }
        end

        describe response[:code] do
          it { is_expected.to eq 404 }
        end

        describe response[:body] do
          it { is_expected.to match( 'Errno::ENOENT' => 'File not found.' ) }
        end
      end
    end
  end
end

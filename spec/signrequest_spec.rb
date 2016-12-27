require 'spec_helper'

describe SignRequest do
  it 'has a version number' do
    expect(SignRequest::VERSION).not_to be nil
  end

  describe '::API' do
    describe '.authenticate' do
      User = Struct.new(:username, :password, :subdomain)
      valid   = User.new('mike@codaisseur.com', 'gno4lqf', 'gemtesting')
      invalid = User.new('email', 'passwd', 'subdomain')
      null    = User.new(nil, nil, '')

      context 'when providing an invalid username and password combination' do
        response = SignRequest::API.authenticate(invalid.username,
                                                 invalid.password,
                                                 invalid.subdomain)

        it 'returns a response code of 403 Forbidden' do
          expect(response['code']).to eq(403)
        end

        it 'returns a response body indicating invalid credentials' do
          expect(response['body']['detail']).to eq(
            'Invalid username/password.'
          )
        end
      end

      context 'when providing a valid username and password combination' do
        context 'with an invalid subdomain' do
          response = SignRequest::API.authenticate(valid.username,
                                                   valid.password,
                                                   invalid.subdomain)

          it 'returns a response of 403' do
            expect(response['code']).to eq(403)
          end

          it 'returns a response body indicating its invalid state' do
            expect( response['body']['detail'] ).to eq(
              "A Team with this subdomain does not exist or you do not have the appropriate permissions."
            )
          end
        end

        context 'with valid credentials for basic authentication' do
          response = SignRequest::API.authenticate(valid.username,
                                                   valid.password,
                                                   valid.subdomain)

          it 'returns a response code of 201' do
            expect(response['code']).to eq(201)
          end

          it 'returns a response body with a token object, and a created object' do
            expect(response['body']).to match(
              'token' => a_string_matching(/^[0-9a-zA-Z]*$/),
              'created' => true
            )
          end
        end

        context 'with no subdomain' do
          response = SignRequest::API.authenticate(valid.username,
                                                   valid.password,
                                                   null.subdomain)
          it 'returns a response code of 400' do
            expect(response['code']).to eq(400)
          end

          it 'returns a response body indicating subdomain as origin of BadRequest' do
            expect(response['body']).to match(
              'subdomain' => a_collection_containing_exactly(
                a_string_matching(/This field may not be blank./)
              )
            )
          end
        end
      end
    end

    describe '.handle_restclient_error' do
    end

    describe '.valid_args?' do
      context 'when the payload contains the correct number of arguments' do
        it 'does not raise an error' do
          expect {
            SignRequest::API.valid_args?(1, ['this'])
          }.not_to raise_error
        end
      end

      context 'when the payload has an incorrect number of arguments' do
        it 'to raise an ArgumentError' do
          expect {
            SignRequest::API.valid_args?(4, ['this'])
          }.to raise_error(ArgumentError)
        end

        it 'gives an error message with number of args received and required' do
          expect {
            SignRequest::API.valid_args?(2, ['argument'])
          }.to raise_error("Payload requires 1 arguments: argument (Received 2)")
        end
      end
    end
  end
end

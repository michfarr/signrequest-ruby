require 'spec_helper'

describe SignRequest do
  it 'has a version number' do
    expect(SignRequest::VERSION).not_to be nil
  end

  describe SignRequest::API do
    describe '.authenticate' do
      User = Struct.new(:username, :password, :subdomain)
      valid   = User.new(ENV['SIGNREQUEST_USER'], ENV['SIGNREQUEST_PASS'], ENV['SIGNREQUEST_SUBDOMAIN'])
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
          expect(response['body']).to match(
            'detail' => a_string_matching(
              /^Invalid username\/password.$/
            )
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

          it 'returns a response body indicating ' do
            expect(response['body']).to match(
              'detail' => a_string_matching(
                /^A Team with this subdomain does not exist or you do not have the appropriate permissions.$/
              )
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

          it 'returns a response body bash with a token, and a created bool' do
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
                a_string_matching(/^This field may not be blank.$/)
              )
            )
          end
        end
      end
    end

    describe '.handle_restclient_error' do
      Err_Resp = Struct.new(:response)
      error_message = Err_Resp.new("{\"detail\":\"This is an error!\"}")

      response = SignRequest::API.handle_restclient_error(1000, error_message)

      it "returns the response['code']" do
        expect(response['code']).to eq(1000)
      end

      it "returns the response['body']" do
        expect(response['body']).to match(
          'detail' => a_string_matching('This is an error!')
        )
      end
    end

    describe '.valid_args?' do
      context 'the correct number of arguments are passed' do
        it 'does not raise an error' do
          expect {
            SignRequest::API.valid_args?(2, ['a', 'b'])
          }.not_to raise_error
        end
      end

      context 'an incorrect number of arguments are passed' do
        it 'raises an ArgumentError' do
          expect {
            SignRequest::API.valid_args?(3, %w(y x))
          }.to raise_error(ArgumentError)
        end

        it 'provides an error message' do
          expect {
            SignRequest::API.valid_args?(2, %w(x y z))
          }.to raise_error('Payload requires 3 arguments: x, y, z (Received 2)')
        end
      end
    end
  end
end

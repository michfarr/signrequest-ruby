require 'spec_helper'

describe SignRequest do
  it 'has a version number' do
    expect(SignRequest::VERSION).not_to be nil
  end

  describe SignRequest::API do
    describe '.authenticate' do
      User = Struct.new(:username, :password, :subdomain)
      valid   = User.new('', '', '')
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

          it 'returns a response body indicating ' do
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
  end
end

require 'spec_helper'

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

      describe response do
        it { is_expected.to include :code }
        it { is_expected.to include :body }
      end

      describe response[:code] do
        it { is_expected.to eq 403 }
      end

      describe response[:body] do
        it { is_expected.to match( 'detail' => a_string_matching(/^Invalid username\/password.$/)) }
      end
    end

    context 'when providing a valid username and password combination' do
      context 'with an invalid subdomain' do
        response = SignRequest::API.authenticate(valid.username,
                                                 valid.password,
                                                 invalid.subdomain)

        describe response do
          it { is_expected.to include :code }
          it { is_expected.to include :body }
        end

        describe response[:code] do
          it { is_expected.to eq 403 }
        end

        describe response[:body] do
          it { is_expected.to match( 'detail' => a_string_matching(
            /^A Team with this subdomain does not exist or you do not have the appropriate permissions.$/
          ))}
        end
      end

      # => Disable this for now so that I don't have 500 tokens.
      # context 'with valid credentials for basic authentication' do
      #   response = SignRequest::API.authenticate(valid.username,
      #                                            valid.password,
      #                                            valid.subdomain)
      #
      #   describe response do
      #     it { is_expected.to include :code }
      #     it { is_expected.to include :body }
      #   end
      #
      #   describe response[:code] do
      #     it { is_expected.to eq 201 }
      #   end
      #
      #   describe response[:body] do
      #     it { is_expected.to match(
      #       'token' => a_string_matching(/^[0-9a-zA-Z]*$/),
      #       'created' => true
      #     )}
      #   end
      # end

      context 'with no subdomain' do
        response = SignRequest::API.authenticate(valid.username,
                                                 valid.password,
                                                 null.subdomain)

        describe response do
          it { is_expected.to include :code }
          it { is_expected.to include :body }
        end

        describe response[:code] do
          it { is_expected.to eq 400 }
        end

        describe response[:body] do
          it { is_expected.to match(
            'subdomain' => a_collection_containing_exactly(
              (/^This field may not be blank.$/)
            )
          )}
        end
      end
    end
  end
end

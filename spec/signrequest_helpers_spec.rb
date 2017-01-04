require 'spec_helper'

describe SignRequest::API do
  describe '.handle_restclient_error' do
    Err_Resp = Struct.new(:response)
    error_message = Err_Resp.new('{"detail":"This is an error!"}')

    response = SignRequest::API.handle_restclient_error(1000, error_message.response)

    describe response do
      it { is_expected.to include :code }
      it { is_expected.to include :body }
    end

    describe response[:code] do
      it { is_expected.to eq 1000}
    end

    describe response[:body] do
      it { is_expected.to match( 'detail' => 'This is an error!') }
    end
  end
end

require 'spec_helper'

describe SignRequest do
  it 'has a version number' do
    expect(SignRequest::VERSION).not_to be nil
  end
end

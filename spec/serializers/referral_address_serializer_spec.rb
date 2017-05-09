# frozen_string_literal: true

require 'rails_helper'

describe ReferralAddressSerializer do
  describe 'as_json' do
    let(:address) { FactoryGirl.build(:address) }

    it "returns the attributes of a address with type as 'Other'" do
      expect(described_class.new(address).as_json).to eq(
        street_address: address.street_address,
        state: address.state,
        city: address.city,
        zip: address.zip,
        type: 'Other'
      )
    end
  end
end

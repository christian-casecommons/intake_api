# frozen_string_literal: true
require 'rails_helper'

describe 'Participants Addresses API', skip_auth: true do
  describe 'PUT /api/v1/participants/:id' do
    it 'adds an address if one did not exist before' do
      participant = FactoryGirl.create(
        :participant
      )
      new_address = FactoryGirl.build(:address)
      updated_params = {
        addresses: [new_address.as_json]
      }

      expect do
        put "/api/v1/participants/#{participant.id}", params: updated_params
      end.to change(Address, :count).by(1)

      expect(response.status).to eq(200)
      body = JSON.parse(response.body).with_indifferent_access
      expect(body).to match a_hash_including(
        addresses: array_including(
          a_hash_including(
            street_address: new_address.street_address,
            city: new_address.city,
            state: new_address.state,
            zip: new_address.zip
          )
        )
      )
    end

    it 'does nothing if an existing address has not changed' do
      address = FactoryGirl.create(:address)
      participant = FactoryGirl.create(
        :participant,
        first_name: 'Bart',
        addresses: [address]
      )

      updated_params = {
        first_name: 'Fred',
        addresses: [address.as_json]
      }

      expect do
        put "/api/v1/participants/#{participant.id}", params: updated_params
      end.to change(Address, :count).by(0)

      expect(response.status).to eq(200)
      body = JSON.parse(response.body).with_indifferent_access
      expect(body).to match a_hash_including(
        first_name: 'Fred',
        addresses: array_including(
          a_hash_including(
            street_address: address.street_address,
            city: address.city,
            state: address.state,
            zip: address.zip
          )
        )
      )
    end

    it 'deletes addresses that have been removed from the set' do
      participant = FactoryGirl.create(
        :participant,
        addresses: [
          FactoryGirl.create(:address)
        ]
      )

      updated_params = {
        first_name: 'Fred'
      }

      expect do
        put "/api/v1/participants/#{participant.id}", params: updated_params
      end.to change(Address, :count).by(-1)

      expect(response.status).to eq(200)
      body = JSON.parse(response.body).with_indifferent_access
      expect(body).to match a_hash_including(
        id: participant.id,
        first_name: 'Fred',
        addresses: []
      )
    end
  end
end

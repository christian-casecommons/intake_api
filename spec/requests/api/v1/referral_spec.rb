# frozen_string_literal: true
require 'rails_helper'

describe 'Referral API' do
  describe 'POST /api/v1/referrals' do
    it 'creates a referral' do
      referral_params = {
        ended_at: '2016-08-03T01:00:00.000Z',
        incident_date: '2016-08-02',
        location_type: 'Foster Home',
        method_of_referral: 'Phone',
        name: 'The Rocky Horror Show',
        reference: '123ABC',
        started_at: '2016-08-03T01:00:00.000Z'
      }

      post '/api/v1/referrals', params: referral_params

      expect(response.status).to eq(201)
      body = JSON.parse(response.body).with_indifferent_access
      expect(body).to include(
        incident_date: '2016-08-02',
        location_type: 'Foster Home',
        method_of_referral: 'Phone',
        name: 'The Rocky Horror Show',
        reference: '123ABC',
        ended_at: '2016-08-03T01:00:00.000Z',
        started_at: '2016-08-03T01:00:00.000Z',
        referral_address: include(
          address: include(
            street_address: nil,
            city: nil,
            state: nil,
            zip: nil
          )
        )
      )
      expect(body['id']).to_not eq nil
    end
  end

  describe 'GET /api/v1/referrals/:id' do
    it 'returns a JSON representation of the referral' do
      referral = Referral.create(
        ended_at: '2016-08-03T01:00:00.000Z',
        incident_date: '2016-08-02',
        location_type: 'Foster Home',
        method_of_referral: 'Phone',
        name: 'The Rocky Horror Show',
        reference: '123ABC',
        started_at: '2016-08-03T01:00:00.000Z'
      )

      address = ReferralAddress.create(
        referral: referral,
        address: Address.create(
          street_address: '123 Fake St',
          city: 'Fake City',
          state: 'NY',
          zip: '10010'
        )
      )

      get "/api/v1/referrals/#{referral.id}"

      expect(response.status).to eq(200)
      body = JSON.parse(response.body).with_indifferent_access
      expect(body).to include(
        id: referral.id,
        incident_date: '2016-08-02',
        location_type: 'Foster Home',
        method_of_referral: 'Phone',
        name: 'The Rocky Horror Show',
        reference: '123ABC',
        ended_at: '2016-08-03T01:00:00.000Z',
        started_at: '2016-08-03T01:00:00.000Z',
        referral_address: include(
          id: address.id,
          address: include(
            id: address.address_id,
            street_address: '123 Fake St',
            city: 'Fake City',
            state: 'NY',
            zip: 10_010,
            person_id: nil
          )
        )
      )
    end
  end

  describe 'PUT /api/v1/referrals/:id' do
    before { Address.destroy_all }
    it 'updates attributes of a referral' do
      referral = Referral.create(
        ended_at: '2016-08-03T01:00:00.000Z',
        incident_date: '2016-08-02',
        location_type: 'Foster Home',
        method_of_referral: 'Phone',
        name: 'The Rocky Horror Show',
        reference: '123ABC',
        started_at: '2016-08-03T01:00:00.000Z'
      )
      address = ReferralAddress.create(
        referral: referral,
        address: Address.create(
          street_address: '123 Fake St',
          city: 'Fake City',
          state: 'NY',
          zip: '10010'
        )
      )

      updated_params = {
        name: 'Some new name',
        referral_address_attributes: {
          id: address.id,
          address_attributes: {
            id: address.address_id,
            street_address: '123 Real St',
            city: 'Fake City',
            state: 'CA',
            zip: '10010'
          }
        }
      }

      put "/api/v1/referrals/#{referral.id}", params: updated_params

      expect(response.status).to eq(200)
      body = JSON.parse(response.body).with_indifferent_access
      expect(body).to include(
        ended_at: '2016-08-03T01:00:00.000Z',
        id: referral.id,
        incident_date: '2016-08-02',
        location_type: 'Foster Home',
        method_of_referral: 'Phone',
        name: 'Some new name',
        reference: '123ABC',
        started_at: '2016-08-03T01:00:00.000Z',
        referral_address: include(
          id: address.id,
          address: include(
            id: address.address_id,
            street_address: '123 Real St',
            city: 'Fake City',
            state: 'CA',
            zip: 10_010,
            person_id: nil
          )
        )
      )
      expect(Address.count).to eq 1
    end
  end
end

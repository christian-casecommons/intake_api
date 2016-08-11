# frozen_string_literal: true
require 'rails_helper'

describe 'People API' do
  describe 'POST /api/v1/people' do
    it 'creates a person' do
      params = {
        person: {
          first_name: 'Walter',
          last_name: 'White',
          gender: 'female',
          date_of_birth: '1990-03-30',
          ssn: '345-12-2345'
        }
      }
      post '/api/v1/people', params

      expect(response.status).to eq(201)
      body = JSON.parse(response.body)
      expect(body['id']).to_not eq nil
      expect(body['first_name']).to eq('Walter')
      expect(body['last_name']).to eq('White')
      expect(body['gender']).to eq('female')
      expect(body['date_of_birth']).to eq('1990-03-30')
      expect(body['ssn']).to eq('345-12-2345')
    end
  end

  describe 'GET /api/v1/people/:id' do
    it 'returns a JSON representation of the person' do
      person = Person.create(first_name: 'Walter', last_name: 'White')

      get "/api/v1/people/#{person.id}"

      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['first_name']).to eq('Walter')
      expect(body['last_name']).to eq('White')
    end
  end

  describe 'PUT /api/v1/people/:id' do
    it 'updates attributes of a person' do
      person = Person.create(first_name: 'Walter', last_name: 'White')

      put "/api/v1/people/#{person.id}", person: { first_name: 'Jesse' }

      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body['first_name']).to eq('Jesse')
      expect(body['last_name']).to eq('White')
    end
  end

  describe 'DELETE /api/v1/people/:id' do
    it 'deletes the person' do
      person = Person.create(first_name: 'Walter', last_name: 'White')

      delete "/api/v1/people/#{person.id}"

      expect(response.status).to eq(204)
      expect(response.body).to be_empty
    end
  end
end

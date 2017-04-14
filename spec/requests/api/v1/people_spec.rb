# frozen_string_literal: true
require 'rails_helper'

describe 'People API' do
  describe 'POST /api/v1/people' do
    let(:params) do
      {
        first_name: 'David',
        middle_name: 'Jon',
        last_name: 'Gilmour',
        name_suffix: 'esq',
        gender: 'male',
        date_of_birth: '1990-03-30',
        ssn: '345-12-2345',
        addresses: [
          {
            id: nil,
            street_address: '123 fake st',
            city: 'Fake City',
            state: 'NY',
            zip: '10010',
            type: 'Placement'
          },
          {
            id: nil,
            street_address: '711 capital Mall',
            city: 'Sacramento',
            state: 'CA',
            zip: '95822',
            type: 'Home'
          }
        ],
        phone_numbers: [
          { number: '917-901-8765', type: 'Home' },
          { number: '916-101-1234', type: 'Cell' }
        ],
        languages: %w(Hmong Japanese German),
        races: [
          { race: 'White', race_detail: 'Armenian' },
          { race: 'Asian' }
        ],
        ethnicity: { hispanic_latino_origin: 'Yes', ethnicity_detail: 'Mexican' }
      }
    end
    let(:body) { JSON.parse(response.body).with_indifferent_access }

    context 'remote authentication is enabled' do
      let(:auth_url) { 'http://test.com' }
      let(:auth_token) { 'fake_token' }
      let(:headers) { { 'Authorization' => auth_token } }

      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('AUTHENTICATION_URL').and_return(auth_url)
        allow(ENV).to receive(:fetch).with('AUTHENTICATION', false).and_return(true)
        faraday_double = double :faraday, status: http_status
        allow(Faraday).to receive(:get)
          .with("#{auth_url}/authn/validate?token=#{auth_token}")
          .and_return faraday_double
      end

      context 'the authorization token is not valid' do
        let(:http_status) { 403 }
        it 'responds with a 403' do
          post '/api/v1/people', params: params, headers: headers
          expect(response.status).to eq 403
        end
      end
    end

    it 'creates a person' do
      post '/api/v1/people', params: params
      expect(response.status).to eq(201)
      expect(body).to match a_hash_including(
        first_name: 'David',
        middle_name: 'Jon',
        last_name: 'Gilmour',
        name_suffix: 'esq',
        gender: 'male',
        date_of_birth: '1990-03-30',
        ssn: '345-12-2345',
        addresses: array_including(
          a_hash_including(
            street_address: '123 fake st',
            state: 'NY',
            city: 'Fake City',
            zip: '10010',
            type: 'Placement'
          ),
          a_hash_including(
            street_address: '711 capital Mall',
            city: 'Sacramento',
            state: 'CA',
            zip: '95822',
            type: 'Home'
          )
        ),
        phone_numbers: array_including(
          a_hash_including(
            number: '917-901-8765',
            type: 'Home'
          ),
          a_hash_including(
            number: '916-101-1234',
            type: 'Cell'
          )
        ),
        languages: array_including('Hmong', 'Japanese', 'German'),
        races: array_including(
          a_hash_including(
            race: 'White',
            race_detail: 'Armenian'
          ),
          a_hash_including(
            race: 'Asian'
          )
        ),
        ethnicity: a_hash_including(
          hispanic_latino_origin: 'Yes',
          ethnicity_detail: 'Mexican'
        )
      )
      expect(body[:id]).to_not be_nil
      expect(body[:addresses][0][:id]).to_not be_nil
      expect(body[:addresses][1][:id]).to_not be_nil
      expect(body[:phone_numbers][0][:id]).to_not be_nil
      expect(body[:phone_numbers][1][:id]).to_not be_nil
    end
  end

  describe 'GET /api/v1/people/:id' do
    let(:person) { Person.create(first_name: 'Walter', last_name: 'White') }
    let(:body) { JSON.parse(response.body).with_indifferent_access }

    it 'returns a JSON representation of the person' do
      get "/api/v1/people/#{person.id}"
      expect(response.status).to eq(200)
      expect(body[:first_name]).to eq('Walter')
      expect(body[:last_name]).to eq('White')
      expect(body[:phone_numbers]).to eq([])
    end
  end

  describe 'PUT /api/v1/people/:id' do
    let(:person) do
      person = Person.new(
        first_name: 'Walter',
        last_name: 'White',
        languages: %w(Hmong Japanese German)
      )
      person.addresses.build(street_address: '123 fake street')
      person.phone_numbers.build(number: '111-111-1111')
      person.phone_numbers.build(number: '222-222-2222')
      person
    end
    let(:existing_address) { person.addresses.first }
    let(:existing_phone_number) { person.phone_numbers.first }
    let(:body) { JSON.parse(response.body).with_indifferent_access }
    let(:params) do
      {
        first_name: 'Deborah',
        middle_name: 'Ann',
        last_name: 'Harry',
        name_suffix: 'md',
        gender: 'female',
        date_of_birth: '1990-03-30',
        ssn: '345-12-2345',
        addresses: [{
          id: existing_address.id,
          street_address: '123 fake st',
          city: 'Fake City',
          state: 'NY',
          zip: '10010',
          type: 'Other'
        }, {
          id: nil,
          street_address: '711 capital Mall',
          city: 'Sacramento',
          state: 'CA',
          zip: '95822',
          type: 'Home'
        }],
        phone_numbers: [{
          id: existing_phone_number.id,
          number: '333-333-3333',
          type: 'Home'
        }, {
          id: nil,
          number: '444-444-4444',
          type: 'Cell'
        }],
        languages: %w(Japanese English),
        races: [
          { race: 'White', race_detail: 'Armenian' },
          { race: 'Asian' }
        ],
        ethnicity: { hispanic_latino_origin: 'Yes', ethnicity_detail: 'Mexican' }
      }
    end

    before { person.save! }

    it 'responds with a status code 200' do
      put "/api/v1/people/#{person.id}", params: params
      expect(response.status).to eq(200)
    end

    it 'updates attributes of a person' do
      put "/api/v1/people/#{person.id}", params: params
      expect(body).to match a_hash_including(
        id: person.id,
        first_name: 'Deborah',
        middle_name: 'Ann',
        last_name: 'Harry',
        name_suffix: 'md',
        gender: 'female',
        date_of_birth: '1990-03-30',
        ssn: '345-12-2345',
        addresses: array_including(
          a_hash_including(
            id: existing_address.id,
            street_address: '123 fake st',
            state: 'NY',
            city: 'Fake City',
            zip: '10010',
            type: 'Other'
          ),
          a_hash_including(
            street_address: '711 capital Mall',
            city: 'Sacramento',
            state: 'CA',
            zip: '95822',
            type: 'Home'
          )
        ),
        phone_numbers: array_including(
          a_hash_including(
            id: existing_phone_number.id,
            number: '333-333-3333',
            type: 'Home'
          ),
          a_hash_including(
            number: '444-444-4444',
            type: 'Cell'
          )
        ),
        languages: array_including('Japanese', 'English'),
        races: array_including(
          a_hash_including(
            race: 'White',
            race_detail: 'Armenian'
          ),
          a_hash_including(
            race: 'Asian'
          )
        ),
        ethnicity: a_hash_including(
          hispanic_latino_origin: 'Yes',
          ethnicity_detail: 'Mexican'
        )
      )
      expect(body[:addresses][0][:id]).to_not be_nil
      expect(body[:addresses][1][:id]).to_not be_nil
      expect(body[:phone_numbers][0][:id]).to_not be_nil
      expect(body[:phone_numbers][1][:id]).to_not be_nil
    end

    it 'creates a new phone number and updates an existing phone number' do
      expect do
        put "/api/v1/people/#{person.id}", params: params
      end.to change(PhoneNumber, :count).by(1)
      expect do
        put "/api/v1/people/#{person.id}", params: params
      end.to change(PersonPhoneNumber, :count).by(1)
      expect(person.person_phone_numbers.count).to eq 2
      expect(person.phone_numbers.count).to eq 2
    end

    it 'creates a new person address and updates and existing person address' do
      expect do
        put "/api/v1/people/#{person.id}", params: params
      end.to change {
        person.person_addresses.count
      }.from(1).to(2)
    end
  end

  describe 'delete an existing address' do
    let(:person) do
      person = Person.new(
        first_name: 'James',
        last_name: 'Rosling',
        languages: %w(Hmong Japanese German)
      )
      person.addresses.build(
        [
          {
            street_address: '123 fake street',
            city: 'Sacramento',
            state: 'CA',
            zip: '95822',
            type: 'Home'
          }, {
            street_address: '123 roman street',
            city: 'Yolo',
            state: 'CA',
            zip: '32487',
            type: 'Work'
          }
        ]
      )
      person.phone_numbers.build(number: '111-111-1111')
      person
    end
    let(:existing_address) { person.addresses.first }
    let(:existing_phone_number) { person.phone_numbers.first }
    let(:params) do
      {
        first_name: 'Deborah',
        addresses: [{
          id: existing_address.id,
          street_address: '123 fake st',
          city: 'Fake City',
          state: 'NY',
          zip: '10010',
          type: 'Other'
        }, {
          id: nil,
          street_address: '711 capital Mall',
          city: 'Sacramento',
          state: 'CA',
          zip: '95822',
          type: 'Home'
        }],
        phone_numbers: [{
          number: '333-333-3333',
          type: 'Home'
        }]
      }
    end
    let(:body) { JSON.parse(response.body).with_indifferent_access }
    before { person.save! }

    it 'create a person and delete an existing address' do
      put "/api/v1/people/#{person.id}", params: params
      expect(body).to match a_hash_including(
        addresses: array_including(
          a_hash_including(
            id: existing_address.id,
            street_address: '123 fake st'
          ),
          a_hash_including(
            street_address: '711 capital Mall'
          )
        )
      )
      expect(body[:id]).to_not be_nil
      expect(body[:addresses][0][:id]).to_not be_nil
      expect(body[:addresses][1][:id]).to_not be_nil
      expect(body[:phone_numbers][0][:id]).to_not be_nil
      expect(person.person_addresses.count).to eq 2
      expect(person.addresses.count).to eq 2
    end
  end
end

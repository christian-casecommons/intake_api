# frozen_string_literal: true
require 'rails_helper'

describe 'People Search API', elasticsearch: true do
  describe 'GET /api/v1/people_search' do
    let!(:deborah) do
      Person.create!(first_name: 'Deborah', middle_name: 'Ann', last_name: 'Harry')
    end
    let!(:david) do
      Person.create!(first_name: 'David', middle_name: 'Jon', last_name: 'Gilmour')
    end
    before { PeopleRepo.client.indices.flush }
    let(:body) { JSON.parse(response.body) }

    it 'returns nothing when search doesnt match on first or last name' do
      get '/api/v1/people_search?search_term=Randy'
      assert_response :success
      expect(JSON.parse(response.body)).to be_empty
    end

    it 'returns records matching on first name' do
      get '/api/v1/people_search?search_term=Deborah Ann'
      assert_response :success
      expect(body).to match array_including(
        a_hash_including(
          'id' => deborah.id,
          'first_name' => 'Deborah',
          'middle_name' => 'Ann',
          'last_name' => 'Harry'
        )
      )
      expect(body).to_not match array_including(
        a_hash_including(
          'id' => david.id,
          'first_name' => 'David',
          'middle_name' => 'Jon',
          'last_name' => 'Gilmour'
        )
      )
    end

    it 'returns records prefix matching on first name' do
      get '/api/v1/people_search?search_term=Da'
      assert_response :success
      expect(body).to match array_including(
        a_hash_including(
          'id' => david.id,
          'first_name' => 'David',
          'middle_name' => 'Jon',
          'last_name' => 'Gilmour'
        )
      )
      expect(body).to_not match array_including(
        a_hash_including(
          'id' => deborah.id,
          'first_name' => 'Deborah',
          'middle_name' => 'Ann',
          'last_name' => 'Harry'
        )
      )
    end

    it 'does not return records not prefix matching on first name' do
      get '/api/v1/people_search?search_term=borah'
      assert_response :success
      expect(body).to_not match array_including(
        a_hash_including(
          'id' => deborah.id,
          'first_name' => 'Deborah',
          'middle_name' => 'Ann',
          'last_name' => 'Harry'
        )
      )
    end

    it 'returns records matching on last name' do
      get '/api/v1/people_search?search_term=Greg Harry'
      assert_response :success
      expect(body).to match array_including(
        a_hash_including(
          'id' => deborah.id,
          'first_name' => 'Deborah',
          'middle_name' => 'Ann',
          'last_name' => 'Harry'
        )
      )
      expect(body).to_not match array_including(
        a_hash_including(
          'id' => david.id,
          'first_name' => 'David',
          'middle_name' => 'Jon',
          'last_name' => 'Gilmour'
        )
      )
    end

    it 'returns records prefix matching on last name' do
      get '/api/v1/people_search?search_term=Gi'
      assert_response :success
      expect(body).to match array_including(
        a_hash_including(
          'id' => david.id,
          'first_name' => 'David',
          'middle_name' => 'Jon',
          'last_name' => 'Gilmour'
        )
      )
      expect(body).to_not match array_including(
        a_hash_including(
          'id' => deborah.id,
          'first_name' => 'Deborah',
          'middle_name' => 'Ann',
          'last_name' => 'Harry'
        )
      )
    end

    it 'does not return records not prefix matching on last name' do
      get '/api/v1/people_search?search_term=mour'
      assert_response :success
      expect(body).to_not match array_including(
        a_hash_including(
          'id' => david.id,
          'first_name' => 'David',
          'middle_name' => 'Jon',
          'last_name' => 'Gilmour'
        )
      )
    end
  end
end

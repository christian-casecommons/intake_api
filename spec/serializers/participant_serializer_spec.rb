# frozen_string_literal: true
require 'rails_helper'

describe ParticipantSerializer do
  describe 'as_json' do
    let(:person) { Person.create }
    let(:screening) { Screening.create }
    let(:participant) do
      Participant.new(
        first_name: 'Robert',
        last_name: 'Smith',
        gender: 'male',
        ssn: '111223333',
        date_of_birth: Date.parse('1955-01-31'),
        person: person,
        screening: screening
      )
    end

    before do
      participant.addresses.build(
        street_address: '1840 Broad rd',
        state: 'CA',
        city: 'sacramento',
        zip: '78495',
        type: 'Work'
      )
      participant.save!
    end

    it 'returns the attributes of a participant as a hash' do
      expect(described_class.new(participant).as_json).to eq(
        id: participant.id,
        first_name: 'Robert',
        last_name: 'Smith',
        gender: 'male',
        ssn: '111223333',
        date_of_birth: Date.parse('1955-01-31'),
        person_id: person.id,
        screening_id: screening.id,
        addresses: [
          {
            id: participant.addresses.ids.first,
            street_address: '1840 Broad rd',
            state: 'CA',
            city: 'sacramento',
            zip: '78495',
            type: 'Work'
          }
        ]
      )
    end
  end
end

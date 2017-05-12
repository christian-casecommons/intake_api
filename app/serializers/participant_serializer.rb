# frozen_string_literal: true

class ParticipantSerializer < ActiveModel::Serializer # :nodoc:
  attributes :id,
    :first_name,
    :middle_name,
    :last_name,
    :name_suffix,
    :gender,
    :ssn,
    :date_of_birth,
    :languages,
    :person_id,
    :races,
    :ethnicity,
    :screening_id,
    :roles,
    :relationships

  has_many :addresses
  has_many :phone_numbers
end

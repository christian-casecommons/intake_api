# frozen_string_literal: true

# PeopleRepo is the Repository object for accessing People ES index
class PeopleRepo
  include Elasticsearch::Persistence::Repository

  def initialize(options = {})
    index options[:index] || 'people'
    es_host = if Rails.env.test?
                ENV['TEST_ELASTICSEARCH_URL']
              else
                ENV['ELASTICSEARCH_URL']
              end
    client Elasticsearch::Client.new(host: es_host)
  end

  klass Person

  settings do
    mappings dynamic: 'strict' do
      indexes :id
      indexes :first_name
      indexes :middle_name
      indexes :last_name
      indexes :name_suffix
      indexes :gender
      indexes :ssn
      indexes :date_of_birth
      indexes :created_at
      indexes :updated_at
    end
  end

  def serialize(document)
    document.attributes
  end

  def deserialize(document)
    document['_source']
  end
end

# frozen_string_literal: true
class PersonRepository # :nodoc:
  def self.find(ids)
    ids_as_array = ids.is_a?(Array) ? ids : [ids]
    response = API.make_api_call('/api/v1/dora/people/_search', :post, search_query(ids_as_array))
    response.body.deep_symbolize_keys[:hits][:hits]
  end

  class << self
    private

    def search_query(ids)
      id_string = ids.join(' || ')
      {
        'query': {
          'bool': {
            'must': [
              {
                'match': {
                  'id': id_string
                }
              }
            ]
          }
        }
      }
    end
  end
end

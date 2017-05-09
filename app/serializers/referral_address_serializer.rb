# frozen_string_literal: true

class ReferralAddressSerializer < ActiveModel::Serializer # :nodoc:
  attributes :street_address,
    :state,
    :city,
    :zip,
    :type

  def type
    'Other'
  end
end

# frozen_string_literal: true

module Api
  module V1
    class ScreeningsController < ApplicationController # :nodoc:
      include AuthenticationConcern

      PERMITTED_PARAMS = [
        :additional_information,
        :ended_at,
        :id,
        :incident_county,
        :incident_date,
        :location_type,
        :communication_method,
        :name,
        :report_narrative,
        :reference,
        :screening_decision_detail,
        :screening_decision,
        :started_at,
        :assignee,
        cross_reports: [
          :agency_type,
          :agency_name
        ],
        allegations: [
          :perpetrator_id,
          :victim_id,
          allegation_types: []
        ]
      ].freeze

      def create
        screening = Screening.new(transformed_params)
        screening.build_screening_address
        screening.screening_address.build_address
        screening.save!
        render json: serialized_screening_json(screening), status: :created
      end

      def show
        screening = Screening.find(screening_params[:id])
        render json: serialized_screening_json(screening), status: :ok
      end

      def update
        screening = Screening.find(transformed_params[:id])
        screening.allegations.destroy_all
        screening.assign_attributes(transformed_params)
        screening.address.assign_attributes(address_params)
        screening.save!
        render json: serialized_screening_json(screening), status: :ok
      end

      def index
        screenings = ScreeningsRepo.search_es_by(
          screening_decision_details,
          screening_decisions
        ).results
        render json: screenings.as_json(
          include: ['participants.addresses', 'address', 'participants.phone_numbers']
        ), status: :ok
      end

      def history_of_involvements
        screening_id = screening_params[:id]
        people_ids = Screening.find(screening_params[:id]).participants.pluck(:person_id)
        screenings = Screening.joins(:participants)
                              .where(participants: { person_id: people_ids })
                              .where.not(id: screening_id)
                              .uniq
        render json: screenings.as_json(
          include: %w(participants allegations)
        ), status: :ok
      end

      private

      def address_params
        params.require(:address).permit(
          :street_address,
          :city,
          :state,
          :zip
        )
      end

      def transformed_params
        screening_params.tap do |params|
          params[:allegations_attributes] = params.delete(:allegations) || []
          params[:cross_reports_attributes] = params.delete(:cross_reports) || []
        end
      end

      def screening_params
        params.permit(*PERMITTED_PARAMS)
      end

      def screening_decision_details
        params[:screening_decision_details]
      end

      def screening_decisions
        params[:screening_decisions]
      end

      def serialized_screening_json(screening)
        ScreeningSerializer.new(screening).as_json(include:
        [
          'participants.addresses',
          'participants.phone_numbers',
          'address',
          'allegations',
          'cross_reports'
        ])
      end
    end
  end
end

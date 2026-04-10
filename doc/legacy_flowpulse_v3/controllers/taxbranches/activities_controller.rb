module Taxbranches
  class ActivitiesController < ApplicationController
    OPEN_STATUSES = %w[recorded reviewed].freeze

    before_action :set_taxbranch
    before_action :set_lead

    def new
      if @taxbranch.questionnaire_source_path.present? && @taxbranch.post.present?
        redirect_to post_path(@taxbranch.post)
        return
      end

      if @taxbranch.post.present?
        redirect_to post_path(@taxbranch.post)
        return
      end

      @activity = build_activity
    end

    def create
      @activity = find_open_activity || build_activity
      @activity.assign_attributes(activity_params)
      @activity.payload = normalized_payload(@activity.payload)

      if @activity.save
        if @taxbranch.datacontact_form_step?
          redirect_to datacontact_step_path and return
        end

        redirect_to dashboard_home_path(tab: "academy"), notice: "Attivita registrata."
      else
        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique
      @activity = find_open_activity
      if @activity.present?
        @activity.assign_attributes(activity_params)
        @activity.payload = normalized_payload(@activity.payload)
        @activity.save

        if @taxbranch.datacontact_form_step?
          redirect_to datacontact_step_path and return
        end

        redirect_to dashboard_home_path(tab: "academy"), notice: "Attivita registrata."
      else
        redirect_to dashboard_home_path(tab: "academy"), alert: "Impossibile registrare l'attivita in questo momento."
      end
    end

    private

    def set_taxbranch
      @taxbranch = Taxbranch.find(params[:taxbranch_id] || params[:id])
    end

    def set_lead
      @lead = Current.user&.lead
      return if @lead.present?

      redirect_to new_session_path, alert: "Devi essere autenticato."
    end

    def build_activity(attrs = {})
      @lead.activities.new(
        {
          domain: Current.domain,
          taxbranch: @taxbranch,
          kind: "step_completed",
          status: "recorded",
          occurred_at: Time.current,
          source: "dashboard_home",
          source_ref: @taxbranch.slug
        }.merge(attrs)
      )
    end

    def activity_params
      params.fetch(:activity, {}).permit(:kind, :status, :occurred_at, :source, :source_ref, :score_total, :score_max, :level_code, payload: {})
    end

    def normalized_payload(value)
      return {} unless value.is_a?(Hash)

      value.compact_blank
    end

    def find_open_activity
      @lead.activities
           .where(taxbranch_id: @taxbranch.id, status: OPEN_STATUSES)
           .order(occurred_at: :desc, id: :desc)
           .first
    end

    def datacontact_step_path
      datacontact = @lead.datacontacts.order(updated_at: :desc, id: :desc).first
      route_params = {
        step_taxbranch_id: @taxbranch.id,
        activity_id: @activity.id,
        return_to: dashboard_home_path(tab: "academy")
      }

      if datacontact.present?
        edit_datacontact_path(datacontact, route_params)
      else
        new_datacontact_path(route_params)
      end
    end
  end
end

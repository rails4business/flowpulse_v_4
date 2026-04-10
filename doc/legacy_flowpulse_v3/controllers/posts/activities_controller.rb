module Posts
  class ActivitiesController < ApplicationController
    before_action :set_post
    before_action :set_taxbranch
    before_action :set_lead
    before_action :set_activity, only: :show

    OPEN_STATUSES = %w[recorded reviewed].freeze

    def ensure
      @activity = find_open_activity
      @activity ||= create_open_activity!

      if @taxbranch&.datacontact_form_step?
        redirect_to datacontact_step_path and return
      end

      if params[:in_dashboard].to_s == "1"
        redirect_to dashboard_home_path(
          tab: params[:tab].presence || "academy",
          open_activity_modal: 1,
          activity_id: @activity.id,
          post_id: @post.slug
        )
      else
        redirect_to post_activity_path(@post, @activity)
      end
    rescue ActiveRecord::RecordNotUnique
      @activity = find_open_activity
      if @activity.present?
        if params[:in_dashboard].to_s == "1"
          redirect_to dashboard_home_path(
            tab: params[:tab].presence || "academy",
            open_activity_modal: 1,
            activity_id: @activity.id,
            post_id: @post.slug
          )
        else
          redirect_to post_activity_path(@post, @activity)
        end
      else
        redirect_to post_path(@post), alert: "Impossibile creare l'attivita in questo momento."
      end
    end

    def show
      payload = @activity.payload.is_a?(Hash) ? @activity.payload : {}
      @questionnaire_snapshot = payload["questionnaire_snapshot"].is_a?(Hash) ? payload["questionnaire_snapshot"] : {}
      @answers_detailed = build_answers_detailed(payload)
      @questionnaire_scoring = @taxbranch&.scoring_config || {}
      @activity_level_info = view_context.questionnaire_level_info(
        level_code: @activity.level_code,
        score_total: @activity.score_total,
        scoring: @questionnaire_scoring
      )
    end

    private

    def set_post
      @post = Post.includes(:taxbranch).friendly.find(params[:post_id] || params[:id])
    end

    def set_taxbranch
      @taxbranch = @post.taxbranch
    end

    def set_lead
      @lead = Current.user&.lead
      return if @lead.present?

      redirect_to new_session_path, alert: "Devi essere autenticato."
    end

    def set_activity
      @activity = @lead.activities.find(params[:id])
      return if @activity.taxbranch_id == @taxbranch&.id

      redirect_to dashboard_home_path(tab: "academy"), alert: "Attivita non valida per questo contenuto."
    end

    def find_open_activity
      @lead.activities
           .where(taxbranch_id: @taxbranch.id, status: OPEN_STATUSES)
           .order(occurred_at: :desc, id: :desc)
           .first
    end

    def create_open_activity!
      @lead.activities.new(
        {
          domain: Current.domain,
          taxbranch: @taxbranch,
          kind: "step_completed",
          status: "recorded",
          occurred_at: Time.current,
          source: "post_activity_ensure",
          source_ref: @post.slug
        }
      )
      .tap(&:save!)
    end

    def datacontact_step_path
      datacontact = @lead.datacontacts.order(updated_at: :desc, id: :desc).first
      return_to = dashboard_home_path(tab: params[:tab].presence || "academy")
      route_params = {
        step_taxbranch_id: @taxbranch.id,
        activity_id: @activity.id,
        return_to: return_to
      }

      if datacontact.present?
        edit_datacontact_path(datacontact, route_params)
      else
        new_datacontact_path(route_params)
      end
    end

    def build_answers_detailed(payload)
      detailed = Array(payload["answers_detailed"]).select { |entry| entry.is_a?(Hash) }
      return detailed if detailed.present?

      answers = payload["answers"].is_a?(Hash) ? payload["answers"] : {}
      return [] if answers.blank?

      question_index = Array(@questionnaire_snapshot["questions"]).select { |q| q.is_a?(Hash) }.index_by { |q| q["code"].to_s }
      answers.map do |code, raw_value|
        value = raw_value.is_a?(Array) ? raw_value.map(&:to_s) : raw_value.to_s
        question = question_index[code.to_s] || {}
        {
          "code" => code.to_s,
          "question" => question["movement"].to_s,
          "kind" => question["kind"].to_s,
          "value" => value,
          "label" => value
        }
      end
    end
  end
end

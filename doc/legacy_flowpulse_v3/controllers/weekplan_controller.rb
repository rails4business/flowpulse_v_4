class WeekplanController < ApplicationController
  layout "weekplan"

  def home
    @lead = Lead.find_by(id: params[:lead_id]) || Current.user&.lead
    return redirect_to root_path, alert: "Lead non trovato" unless @lead

    @lead_domain = Domain.where(taxbranch_id: @lead.taxbranches.select(:id)).first
    @week_start = begin
      if params[:year].present? && params[:week].present?
        Date.commercial(params[:year].to_i, params[:week].to_i, 1)
      elsif params[:year].present? && params[:month].present?
        Date.new(params[:year].to_i, params[:month].to_i, 1).beginning_of_week(:monday)
      elsif params[:week].present?
        Date.parse(params[:week]).beginning_of_week(:monday)
      elsif params[:on].present?
        Date.parse(params[:on]).beginning_of_week(:monday)
      elsif params[:month].present?
        Date.new(Date.current.year, params[:month].to_i, 1).beginning_of_week(:monday)
      else
        Date.current.beginning_of_week(:monday)
      end
    rescue ArgumentError
      Date.current.beginning_of_week(:monday)
    end
    @week_end = @week_start.end_of_week(:monday)
    @week_events =
      Eventdate
        .where(lead_id: @lead.id)
        .where(date_start: @week_start.beginning_of_day..@week_end.end_of_day)
        .order(:date_start)
    @slot_instances =
      SlotInstance
        .joins(:slot_template)
        .where(slot_templates: { lead_id: @lead.id })
        .where(date_start: @week_start.beginning_of_day..@week_end.end_of_day)
        .order(:date_start)
  end
end

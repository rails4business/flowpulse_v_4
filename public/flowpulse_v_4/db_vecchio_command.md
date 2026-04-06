bin/rails action_text:install
bin/rails active_storage:install

bin/rails g scaffold Activity booking:references certificate:references domain:references enrollment:references eventdate:references lead:references service:references taxbranch:references channel:string format:string group_size:integer kind:string level_code:string location_address:text location_name:string location_type:string mode:string occurred_at:datetime payload:jsonb score_max:integer score_total:integer source:string source_ref:string status:string center_taxbranch_id:integer

bin/rails g scaffold Book title:string slug:string description:text folder_md:string index_file:string access_mode:integer active:boolean price_dash:decimal{10,2} price_euro:decimal{10,2}

bin/rails g scaffold BookDomain book:references domain:references

bin/rails g scaffold Booking commitment:references enrollment:references eventdate:references invited_by_lead_id:bigint requested_by_lead_id:bigint mycontact_id:bigint service:references journey_role:string meta:jsonb mode:integer notes:text participant_role:integer price_dash:decimal{16,8} price_euro:decimal{10,2} status:integer

bin/rails g scaffold Certificate datacontact:references domain:references domain_membership:references enrollment:references journey:references lead:references service:references taxbranch:references issued_by_enrollment_id:integer expires_at:datetime issued_at:datetime meta:jsonb role_name:string status:integer

bin/rails g scaffold Commitment eventdate:references taxbranch:references template_commitment_id:bigint area:string commitment_kind:integer compensation_dash:decimal{16,8} compensation_euro:decimal{8,2} duration_minutes:integer energy:integer importance:integer meta:jsonb notes:text position:integer role_count:integer role_name:string urgency:integer

bin/rails g scaffold Datacontact lead:references billing_address:string billing_city:string billing_country:string billing_name:string billing_zip:string date_of_birth:date email:string first_name:string fiscal_code:string last_name:string meta:jsonb phone:string place_of_birth:string referent_lead_id:integer socials:text vat_number:string

bin/rails g scaffold Domain taxbranch:references title:string host:string provider:string language:string description:text favicon_url:string horizontal_logo_url:string square_logo_url:string operative_roles:jsonb

bin/rails g scaffold DomainMembership domain:references lead:references domain_active_role:string primary:boolean status:integer

bin/rails g scaffold Enrollment journey:references invited_by_lead_id:bigint requested_by_lead_id:bigint mycontact_id:bigint service:references certified_at:datetime journey_role:string meta:jsonb mode:integer notes:text participant_role:string phase:integer price_dash:decimal{16,8} price_euro:decimal{10,2} request_kind:integer role_name:string status:integer target_role:string

bin/rails g scaffold Eventdate domain:references domain_membership:references journey:references lead:references taxbranch:references child_journey_id:bigint parent_eventdate_id:bigint allows_invite:boolean allows_request:boolean date_start:datetime date_end:datetime description:text event_type:integer journey_role:string kind_event:integer location:string max_participants:integer meta:jsonb mode:integer position:integer status:integer time_duration:integer unit_duration:integer visibility:integer

bin/rails g scaffold Journey lead:references service:references taxbranch:references template_journey_id:bigint allows_invite:boolean allows_request:boolean end_at:datetime end_taxbranch_id:integer energy:integer importance:integer journey_roles:jsonb journey_type:integer journeys_status:integer kind:integer meta:jsonb mode:string notes:text phase:string price_estimate_dash:decimal{16,8} price_estimate_euro:decimal{8,2} progress:integer slug:string start_at:datetime title:string urgency:integer

bin/rails g scaffold Lead email:string name:string surname:string username:string token:string phone:string parent_id:integer referral_lead_id:integer meta:jsonb

bin/rails g scaffold Mycontact datacontact:references lead:references approved_by_referent_at:datetime original:boolean status_contact:string

bin/rails g scaffold Payment contact_id:bigint parent_payment_id:bigint payable_type:string payable_id:bigint amount_dash:decimal{16,8} amount_euro:decimal{10,2} currency:string external_id:string kind:integer meta:jsonb method:integer notes:text paid_at:datetime refund_amount_euro:decimal{10,2} refund_due_at:datetime status:integer

bin/rails g scaffold Post lead:references taxbranch_id:integer title:string slug:string description:text content:text content_md:text banner_url:string horizontal_cover_url:string thumb_url:string url_media_content:string vertical_cover_url:string mermaid:text meta:jsonb

bin/rails g scaffold Service lead:references taxbranch:references included_in_service_id:integer name:string slug:string description:text content_md:text image_url:string allowed_roles:jsonb builders_roles:jsonb drivers_roles:jsonb output_roles:jsonb verifier_roles:jsonb allows_invite:boolean allows_request:boolean auto_certificate:boolean enrollable_from_phase:integer enrollable_until_phase:integer max_tickets:integer min_tickets:integer n_eventdates_planned:integer open_by_journey:boolean price_enrollment_euro:decimal{8,2} price_ticket_dash:decimal{16,8} require_booking_verification:boolean require_enrollment_verification:boolean service_phase:integer meta:jsonb

bin/rails g scaffold Session user:references ip_address:string user_agent:string

bin/rails g scaffold SlotTemplate lead:references taxbranch:references color_hex:string day_of_week:integer description:text jsonb:string repeat_end:date repeat_every:integer repeat_rule:integer repeat_start:date seasons:string time_end:time time_start:time title:string

bin/rails g scaffold SlotInstance slot_template:references date_end:datetime date_start:datetime notes:text status:integer

bin/rails g scaffold TagPositioning lead:references taxbranch:references category:string name:string metadata:jsonb

bin/rails g scaffold Taxbranch lead:references link_child_taxbranch_id:bigint address_privacy:string ancestry:string execution_mode:string generaimpresa_md:text home_nav:boolean meta:jsonb notes:string order_des:boolean performed_by_roles:jsonb permission_access_roles:jsonb phase:integer position:integer positioning_tag_public:boolean private_address:text public_address:text published_at:datetime questionnaire_config:jsonb scheduled_eventdate_id:integer service_certificable:boolean slug:string slug_category:string slug_label:string status:integer target_roles:jsonb visibility:integer x_coordinated:integer y_coordinated:integer

bin/rails g scaffold User lead:references active_certificate_id:integer approved_by_lead_id:bigint approved_at:datetime email_address:string invites_count:integer invites_limit:integer last_active_at:datetime password_digest:string referrer_id:integer state_registration:integer superadmin:boolean superadmin_mode_active:boolean

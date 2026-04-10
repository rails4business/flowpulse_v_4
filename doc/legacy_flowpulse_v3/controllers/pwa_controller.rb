class PwaController < ApplicationController
  allow_unauthenticated_access

  def manifest
    render "pwa/manifest", formats: :json, layout: false
  end

  def service_worker
    response.headers["Content-Type"] = "application/javascript"
    render file: Rails.root.join("app/views/pwa/service-worker.js"), layout: false
  end
end

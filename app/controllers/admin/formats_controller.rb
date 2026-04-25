module Admin
  class FormatsController < ApplicationController
    before_action :require_superadmin

    def index
      @format_columns = [
        { key: :line, label: "Line" },
        { key: :station, label: "Station" },
        { key: :experience, label: "Experience" },
        { key: :children, label: "Children" },
        { key: :subchildren, label: "Subchildren" }
      ]

      @format_rows = [
        {
          name: "service / blog / category / post",
          values: {
            line: "service",
            station: "blog",
            experience: "category",
            children: "post",
            subchildren: nil
          }
        },
        {
          name: "percorso / course / module / lesson",
          values: {
            line: "percorso",
            station: "course",
            experience: "module",
            children: "lesson",
            subchildren: nil
          }
        },
        {
          name: "trail / quiz / flow / question",
          values: {
            line: "trail",
            station: "quiz",
            experience: "flow",
            children: "question",
            subchildren: nil
          }
        },
        {
          name: "service / profiling / profile / item",
          values: {
            line: "service",
            station: "profilazione",
            experience: "profile",
            children: "item",
            subchildren: nil
          }
        },
        {
          name: "path / book / category / chapter / page",
          values: {
            line: "path",
            station: "libro",
            experience: "category",
            children: "chapter",
            subchildren: "page"
          }
        }
      ]
    end
  end
end

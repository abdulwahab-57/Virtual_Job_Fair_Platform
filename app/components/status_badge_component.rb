# frozen_string_literal: true

class StatusBadgeComponent < ViewComponent::Base
  DEFAULT_COLOR_MAP = {
    "Reviewed"     => "bg-green-100 text-green-800 border-green-200",
    "Not Reviewed" => "bg-red-100 text-red-800 border-red-200"
  }.freeze

  def initialize(status:, data: {}, color_map: DEFAULT_COLOR_MAP)
    @status    = status
    @data      = data
    @color_map = color_map
  end

  def color_classes
    @color_map.fetch(@status, "bg-slate-100 text-slate-700 border-slate-200")
  end

  def data_attrs
    @data.map { |k, v| "data-#{k}=\"#{ERB::Util.html_escape(v.to_s)}\"" }.join(" ").html_safe
  end
end

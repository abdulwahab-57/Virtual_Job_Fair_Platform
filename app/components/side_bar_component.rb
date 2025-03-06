# frozen_string_literal: true

class SideBarComponent < ViewComponent::Base
  def initialize(tabs:, home_path:)
    @tabs = tabs
    @home_path = home_path
  end

  def svg_icon(name)
    asset_path("icons/#{name}.svg")
  end
end

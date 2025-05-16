# frozen_string_literal: true

class SideBarComponent < ViewComponent::Base
  include InlineSvg::ActionView::Helpers

  def initialize(tabs:, home_path:)
    @tabs = if tabs.present?
              tabs.map(&:symbolize_keys)
    else
              # Default empty array to prevent nil errors
              []
    end
    @home_path = home_path
  end

  def svg_icon(name)
    begin
      inline_svg("icons/#{name}.svg", class: "w-5 h-5 stroke-current")
    rescue StandardError => e
      # fallback to a default icon
      inline_svg("icons/home.svg", class: "w-5 h-5 stroke-current")
    end
  end

  def request
    controller.request
  end
end

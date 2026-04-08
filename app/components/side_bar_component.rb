# frozen_string_literal: true

class SideBarComponent < ViewComponent::Base
  include InlineSvg::ActionView::Helpers

  def initialize(tabs:, home_path:)
    @tabs = tabs
    @home_path = home_path
  end

  def svg_icon(name)
    inline_svg("icons/#{name}.svg", class: "w-5 h-5 stroke-current")
  end

  def request
    controller.request
  end
end

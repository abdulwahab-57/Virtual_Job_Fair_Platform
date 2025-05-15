# frozen_string_literal: true

class VirtualBoothComponentPreview < ViewComponent::Preview
  def default
    render(VirtualBoothComponent.new(meeting: "meeting"))
  end
end

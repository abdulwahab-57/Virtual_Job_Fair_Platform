# frozen_string_literal: true

class Table::PaginationComponent < ViewComponent::Base
  include Pagy::Frontend

  def initialize(pagy:)
    @pagy = pagy
  end
end

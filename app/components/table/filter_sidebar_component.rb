# frozen_string_literal: true

class Table::FilterSidebarComponent < ViewComponent::Base
  renders_one :form_content

  def initialize(title: "FILTERS")
    @title = title.upcase
  end
end

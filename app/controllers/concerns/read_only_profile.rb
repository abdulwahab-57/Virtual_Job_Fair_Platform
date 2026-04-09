module ReadOnlyProfile
  extend ActiveSupport::Concern

  included do
    before_action :set_read_only, only: [:edit]
  end

  private

  def set_read_only
    @read_only = true
  end
end

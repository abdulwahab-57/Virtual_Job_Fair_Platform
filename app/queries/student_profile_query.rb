class StudentProfileQuery
  INCLUDES = {
    student_profile: [
      :educations,
      :projects,
      :activities_honors,
      :skills,
      :interests,
      :location_preferences
    ]
  }.freeze

  def initialize(search_params = {})
    @search_params = search_params.presence || {}
  end

  # Exposed to the view for search_form_for and sort_link helpers
  def ransack_object
    @ransack_object ||= base_scope.ransack(@search_params)
  end

  # Returns an AR relation — Pagy paginates on top; records are never fully loaded here
  def results
    ransack_object
      .result(distinct: true)
      .includes(INCLUDES)
  end

  private

  def base_scope
    User.where(user_type: "student")
  end
end

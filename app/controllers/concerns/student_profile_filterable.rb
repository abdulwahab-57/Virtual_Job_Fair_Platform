module StudentProfileFilterable
  extend ActiveSupport::Concern

  DEGREE_OPTIONS = [
    "BS (Computer Science)",
    "BS (Artificial Intelligence)",
    "BS (Software Engineering)",
    "BS (Business Analytics)",
    "BS (Electrical Engineering)",
    "Bachelor of Business Administration"
  ].freeze

  PER_PAGE = 50

  private

  def set_users
    page = [ params[:page].to_i, 1 ].max

    filtered_scope = apply_student_filters(User.where(user_type: "student"))

    @total_count = filtered_scope.distinct.count
    @total_pages = [ (@total_count.to_f / PER_PAGE).ceil, 1 ].max
    @page        = page
    @per_page    = PER_PAGE

    ids = filtered_scope.distinct
                        .order(id: :desc)
                        .offset((page - 1) * PER_PAGE)
                        .limit(PER_PAGE)
                        .pluck(:id)

    @users = User.where(id: ids)
                 .includes(student_profile: :educations)
                 .order(id: :desc)

    @degree_options          = DEGREE_OPTIONS
    @graduation_year_options = Education
      .where(degree: DEGREE_OPTIONS)
      .where.not(graduation_year: nil)
      .distinct
      .pluck(:graduation_year)
      .sort
      .reverse
  end

  def apply_student_filters(scope)
    if params[:status].present?
      scope = scope.joins(:student_profile)
                   .where(student_profiles: { status: Array(params[:status]) })
    end

    if params[:degree].present?
      scope = scope.joins(student_profile: :educations)
                   .where(educations: { degree: Array(params[:degree]) })
    end

    if params[:graduation_year].present?
      scope = scope.joins(student_profile: :educations)
                   .where(educations: { graduation_year: Array(params[:graduation_year]) })
    end

    scope
  end
end

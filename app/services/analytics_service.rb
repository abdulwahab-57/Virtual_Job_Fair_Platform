class AnalyticsService
  # Calculate profile completion percentage for a given user.
  def self.calculate_profile_completion(user)
    user_type = if user.respond_to?(:user_type) && user.user_type.present?
                  user.user_type
    elsif user.respond_to?(:student_profile) && user.student_profile.present?
                  "student"
    elsif user.respond_to?(:recruiter_profile) && user.recruiter_profile.present?
                  "recruiter"
    else
                  nil
    end

    case user_type
    when "student"
      profile = user.student_profile
      return 0 unless profile

      fields = [
        profile.date_of_birth.present?,
        profile.email_personal.present?,
        profile.phone_number.present?,
        profile.address.present?,
        profile.linkedin_url.present?,
        user.profile_picture.attached?,
        profile.educations.any?,
        profile.projects.any?,
        profile.skills.any?
      ]

      completed = fields.count(true)
      (completed.to_f / fields.size * 100).round
    when "recruiter"
      profile = user.recruiter_profile
      return 0 unless profile

      fields = [
        profile.company_name.present?,
        profile.industry.present?,
        profile.about_company.present?,
        profile.office_location.present?,
        profile.company_email.present?,
        profile.company_website.present?,
        profile.employee_count.present?
      ]

      completed = fields.count(true)
      (completed.to_f / fields.size * 100).round
    else
      0
    end
  end

  # Get student status distribution.
  def self.student_status_distribution
    statuses = StudentProfile.group(:status).count

    if statuses.empty?
      return { labels: [ "No Data" ], values: [ 0 ] }
    end

    statuses_with_labels = {}
    statuses.each do |status, count|
      key = status.present? ? status : "Not Specified"
      statuses_with_labels[key] = count
    end

    {
      labels: statuses_with_labels.keys,
      values: statuses_with_labels.values
    }
  end

  # Get profile completion distribution split by students and recruiters.
  def self.profile_completion_distribution
    students = User.where(user_type: "student").to_a
    recruiters = User.where(user_type: "recruiter").to_a

    {
      students: completion_distribution(students),
      recruiters: completion_distribution(recruiters)
    }
  end

  # Calculate completion bucket distribution [0-25%, 26-50%, 51-75%, 76-100%] for a set of users.
  def self.completion_distribution(users)
    distribution = [ 0, 0, 0, 0 ]

    users.each do |user|
      completion = calculate_profile_completion(user)
      case completion
      when 0..25
        distribution[0] += 1
      when 26..50
        distribution[1] += 1
      when 51..75
        distribution[2] += 1
      when 76..100
        distribution[3] += 1
      end
    end

    distribution
  end

  # Get top skills across all students.
  def self.top_skills_data(limit = 10)
    skill_counts = Skill.group(:skill_list).count
                        .sort_by { |_, count| -count }
                        .take(limit)

    return { labels: [], values: [] } if skill_counts.empty?

    {
      labels: skill_counts.map { |skill, _| skill },
      values: skill_counts.map { |_, count| count }
    }
  end

  # Get education timeline data — graduation counts per year.
  def self.education_timeline_data
    graduation_years = Education.where.not(graduation_year: nil)
                                .group(:graduation_year)
                                .order(:graduation_year)
                                .count

    return { labels: [], values: [] } if graduation_years.empty?

    min_year = graduation_years.keys.min
    max_year = graduation_years.keys.max

    if min_year == max_year
      return { labels: [ min_year ], values: [ graduation_years[min_year] ] }
    end

    all_years = (min_year..max_year).to_a

    {
      labels: all_years,
      values: all_years.map { |year| graduation_years[year] || 0 }
    }
  end

  # Get industry distribution for recruiters.
  def self.industry_distribution_data
    industries = RecruiterProfile.where.not(industry: [ nil, "" ])
                                 .group(:industry)
                                 .count
                                 .sort_by { |_, count| -count }

    return { labels: [], values: [] } if industries.empty?

    if industries.size > 6
      top_industries = industries.take(5)
      other_count = industries.drop(5).sum { |_, count| count }
      industries = top_industries + [ [ "Other", other_count ] ]
    end

    {
      labels: industries.map { |industry, _| industry },
      values: industries.map { |_, count| count }
    }
  end

  # Additional analytics for a student user.
  def self.student_additional_analytics(student)
    {
      education_timeline: student_education_timeline(student),
      projects_count: student.student_profile&.projects&.count || 0,
      activities_count: student.student_profile&.activities_honors&.count || 0,
      interests_count: student.student_profile&.interests&.count || 0,
      location_preferences_count: student.student_profile&.location_preferences&.count || 0
    }
  end

  # Get a student's education timeline sorted by year.
  def self.student_education_timeline(student)
    educations = student.student_profile&.educations || []
    educations.map do |education|
      {
        year: education.graduation_year,
        institution: education.institution_name,
        degree: education.degree
      }
    end.sort_by { |e| e[:year] || 0 }
  end

  # Additional analytics for a recruiter user.
  def self.recruiter_additional_analytics(recruiter)
    {
      company_info: {
        company_name: recruiter.recruiter_profile&.company_name,
        industry: recruiter.recruiter_profile&.industry,
        website: recruiter.recruiter_profile&.company_website,
        employee_count: recruiter.recruiter_profile&.employee_count
      },
      potential_matches: calculate_student_matches(recruiter),
      company_industry_position: industry_position(recruiter)
    }
  end

  # Calculate potential student matches for a recruiter based on industry keyword.
  def self.calculate_student_matches(recruiter)
    industry = recruiter.recruiter_profile&.industry
    return 0 unless industry.present?

    students_with_matching_skills = 0

    User.where(user_type: "student").each do |student|
      student_skills = student.student_profile&.skills&.pluck(:skill_list) || []
      if student_skills.any? { |skill| skill.to_s.downcase.include?(industry.downcase) }
        students_with_matching_skills += 1
      end
    end

    students_with_matching_skills
  end

  # Get a recruiter's industry position relative to all recruiters.
  def self.industry_position(recruiter)
    industry = recruiter.recruiter_profile&.industry
    return nil unless industry.present?

    {
      industry: industry,
      similar_recruiters: RecruiterProfile.where(industry: industry).count,
      total_recruiters: RecruiterProfile.count
    }
  end
end

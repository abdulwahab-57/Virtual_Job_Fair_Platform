module EnhancedAnalyticsHelper
  # Get the top skills across all students
  def top_skills_data(limit = 10)
    skill_counts = Skill.group(:skill_list).count
                       .sort_by { |_, count| -count }
                       .take(limit)

    # Handle empty data set
    if skill_counts.empty?
      return { labels: [], values: [] }
    end

    {
      labels: skill_counts.map { |skill, _| skill },
      values: skill_counts.map { |_, count| count }
    }
  end

  # Get education timeline data - number of graduations per year
  def education_timeline_data
    graduation_years = Education.where.not(graduation_year: nil)
                               .group(:graduation_year)
                               .order(:graduation_year)
                               .count

    # Handle the case when there are no graduation years
    if graduation_years.empty?
      return { labels: [], values: [] }
    end

    # Handle the case when there's only one graduation year
    min_year = graduation_years.keys.min
    max_year = graduation_years.keys.max

    if min_year == max_year
      return {
        labels: [ min_year ],
        values: [ graduation_years[min_year] ]
      }
    end

    # Get a continuous range of years for multiple years
    all_years = (min_year..max_year).to_a

    {
      labels: all_years,
      values: all_years.map { |year| graduation_years[year] || 0 }
    }
  end

  # Get industry distribution for recruiters
  def industry_distribution_data
    industries = RecruiterProfile.where.not(industry: [ nil, "" ])
                               .group(:industry)
                               .count
                               .sort_by { |_, count| -count }

    # Handle empty data set
    if industries.empty?
      return { labels: [], values: [] }
    end

    # Handle "Other" category for small counts
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

  # Get student status distribution
  def student_status_distribution
    statuses = StudentProfile.group(:status).count

    # Handle empty data set
    if statuses.empty?
      return { labels: [ "No Data" ], values: [ 0 ] }
    end

    # Replace nil with "Not Specified"
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

  # Get profile completion distribution
  def profile_completion_distribution
    students = User.where(user_type: "student").to_a
    recruiters = User.where(user_type: "recruiter").to_a

    student_distribution = completion_distribution(students)
    recruiter_distribution = completion_distribution(recruiters)

    {
      students: student_distribution,
      recruiters: recruiter_distribution
    }
  end

  # Helper to calculate completion distribution for a set of users
  def completion_distribution(users)
    distribution = [ 0, 0, 0, 0 ] # [0-25%, 26-50%, 51-75%, 76-100%]

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

  # Additional student analytics
  def student_additional_analytics(student)
    {
      education_timeline: student_education_timeline(student),
      skills_breakdown: student_skills_breakdown(student),
      projects_count: student.student_profile&.projects&.count || 0,
      activities_count: student.student_profile&.activities_honors&.count || 0,
      interests_count: student.student_profile&.interests&.count || 0,
      location_preferences_count: student.student_profile&.location_preferences&.count || 0
    }
  end

  # Get a student's education timeline
  def student_education_timeline(student)
    educations = student.student_profile&.educations || []
    educations.map do |education|
      {
        year: education.graduation_year,
        institution: education.institution_name,
        degree: education.degree
      }
    end.sort_by { |e| e[:year] || 0 }
  end

  # Get a breakdown of a student's skills by category
  def student_skills_breakdown(student)
    skills = student.student_profile&.skills || []

    # Handle empty data set
    if skills.empty?
      return { labels: [], values: [] }
    end

    # Categorize skills (this is a simplified example - in reality, you might use a more sophisticated categorization)
    categories = {
      "Programming" => [ "Java", "Python", "JavaScript", "Ruby", "C++", "C#", "PHP" ],
      "Web Development" => [ "HTML", "CSS", "React", "Angular", "Vue.js", "Node.js", "Django", "Rails" ],
      "Data Science" => [ "SQL", "R", "Python", "Machine Learning", "Data Analysis", "Tableau", "Power BI" ],
      "Design" => [ "Photoshop", "Illustrator", "UI/UX", "Figma", "Adobe XD" ],
      "Soft Skills" => [ "Communication", "Leadership", "Teamwork", "Problem Solving", "Critical Thinking" ],
      "Other" => []
    }

    categorized = Hash.new(0)

    skills.each do |skill|
      category = "Other"

      categories.each do |cat, skills_list|
        if skills_list.any? { |s| skill.skill_list.to_s.downcase.include?(s.downcase) }
          category = cat
          break
        end
      end

      categorized[category] += 1
    end

    # If no categories were found, return empty arrays
    if categorized.empty?
      return { labels: [], values: [] }
    end

    {
      labels: categorized.keys,
      values: categorized.values
    }
  end

  # Additional recruiter analytics
  def recruiter_additional_analytics(recruiter)
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

  # Calculate potential student matches based on industry
  def calculate_student_matches(recruiter)
    industry = recruiter.recruiter_profile&.industry
    return 0 unless industry.present?

    # Simple matching logic based on students having skills related to the recruiter's industry
    # In a real implementation, this would be more sophisticated
    students_with_matching_skills = 0

    User.where(user_type: "student").each do |student|
      student_skills = student.student_profile&.skills&.pluck(:skill_list) || []
      # Check if any skill is related to the industry (simplified example)
      if student_skills.any? { |skill| skill.to_s.downcase.include?(industry.downcase) }
        students_with_matching_skills += 1
      end
    end

    students_with_matching_skills
  end

  # Get the recruiter's industry position compared to others
  def industry_position(recruiter)
    industry = recruiter.recruiter_profile&.industry
    return nil unless industry.present?

    # Count recruiters in the same industry
    similar_recruiters = RecruiterProfile.where(industry: industry).count

    # Position out of total recruiters
    {
      industry: industry,
      similar_recruiters: similar_recruiters,
      total_recruiters: RecruiterProfile.count
    }
  end
end

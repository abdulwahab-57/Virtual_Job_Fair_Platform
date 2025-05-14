module AnalyticsHelper
  # Formats a percentage with one decimal place
  def format_percentage(percentage)
    number_to_percentage(percentage, precision: 1)
  end

  # Create a simple progress bar
  def progress_bar(percentage, options = {})
    color = options[:color] || "blue"

    # Map color names to their hex codes
    color_map = {
      "blue" => "#3b82f6",
      "green" => "#10b981",
      "red" => "#ef4444",
      "yellow" => "#f59e0b",
      "purple" => "#8b5cf6",
      "pink" => "#ec4899"
    }

    # Get the hex color or default to blue
    bg_color = color_map[color] || color_map["blue"]

    content_tag :div, class: "w-full bg-gray-200 rounded-full h-2.5" do
      content_tag :div, "",
        class: "h-2.5 rounded-full",
        style: "width: #{percentage}%; background-color: #{bg_color};"
    end
  end

  # Calculate profile completion percentage
  def calculate_profile_completion(user)
    # Handle missing user_type attribute by checking the user's associations
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

      # Calculate completion percentage based on filled fields
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

      # Calculate completion percentage based on filled fields
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
end

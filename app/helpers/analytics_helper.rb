module AnalyticsHelper
  # Formats a percentage with one decimal place
  def format_percentage(percentage)
    number_to_percentage(percentage, precision: 1)
  end

  # View-layer delegate so templates can call calculate_profile_completion(user)
  # directly without knowing about the service layer.
  def calculate_profile_completion(user)
    AnalyticsService.calculate_profile_completion(user)
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

end

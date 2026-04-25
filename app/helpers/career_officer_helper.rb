module CareerOfficerHelper
  INITIALS_COLOR_CLASSES = [
    "bg-blue-100 text-blue-800",
    "bg-amber-100 text-amber-800",
    "bg-violet-100 text-violet-800",
    "bg-rose-100 text-rose-800",
    "bg-teal-100 text-teal-800",
    "bg-orange-100 text-orange-800"
  ].freeze

  def student_initials(full_name)
    full_name.to_s.split.first(2).map { |word| word[0].upcase }.join
  end

  def student_initials_color(user_id)
    INITIALS_COLOR_CLASSES[user_id.to_i % INITIALS_COLOR_CLASSES.length]
  end
end

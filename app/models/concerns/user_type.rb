module UserType
  extend ActiveSupport::Concern

  included do
    # Check if the user is a student
    def student?
      user_type == "student"
    end

    # Check if the user is a recruiter
    def recruiter?
      user_type == "recruiter"
    end

    # Check if the user is a career officer
    def career_officer?
      user_type == "career_officer"
    end

    # Override Devise's `active_for_authentication?` method
    def active_for_authentication?
      if recruiter?
        # Recruiter can only log in if both recruiter and career officer have confirmed
        super && career_officer_confirmed?
      else
        super
      end
    end

    # Custom confirmation logic for recruiters
    def confirm!
      return if confirmed? # Prevent duplicate confirmations

      self.confirmed_at = Time.current
      save

      send_career_officer_confirmation_request if recruiter?
    end

    # Method to handle career officer's confirmation
    def career_officer_confirm!
      return unless recruiter? && confirmed?

      update(career_officer_confirmed: true)

      send_confirmation_notification if fully_confirmed?
    end

    # Check if both recruiter and career officer have confirmed
    def fully_confirmed?
      confirmed? && career_officer_confirmed?
    end

    # Check if the career officer has confirmed
    def career_officer_confirmed?
      self[:career_officer_confirmed] == true
    end

    # Send confirmation request to career officers
    def send_career_officer_confirmation_request
      Rails.logger.info "Career officer confirmation request triggered for recruiter: #{email}"

      career_officers = User.where(user_type: "career_officer")
                            .where.not(confirmed_at: nil)

      if career_officers.empty?
        Rails.logger.warn "No confirmed career officers found!"
      end

      career_officers.each do |officer|
        Rails.logger.info "Sending email to: #{officer.email}"
        ApplicationMailer.career_officer_approval_request(self, officer).deliver_later
      end
    end
  end
end

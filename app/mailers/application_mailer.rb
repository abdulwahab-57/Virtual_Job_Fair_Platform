class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  def career_officer_approval_request(recruiter, officer)
    @recruiter = recruiter
    @officer = officer
    @approval_link = confirm_recruiter_url(approval_token: recruiter.generate_approval_token)

    Rails.logger.info "Sending approval request email to: #{@officer.email} for recruiter: #{@recruiter.email}"

    mail(to: @officer.email, subject: "Recruiter Approval Request")
  end
end

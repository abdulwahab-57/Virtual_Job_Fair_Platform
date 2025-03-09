class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  def career_officer_approval_request(recruiter, officer)
    @recruiter = recruiter
    @officer = officer
    @approval_link = Rails.application.routes.url_helpers.confirm_recruiter_url(approval_token: recruiter.generate_approval_token)
    mail(to: @officer.email, subject: "Recruiter Approval Request")
  end
end

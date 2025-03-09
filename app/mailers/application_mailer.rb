# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  def career_officer_approval_request(recruiter, officer)
    @recruiter = recruiter
    @officer = officer
    mail(to: @officer.email, subject: "Recruiter Approval Request")
  end
end

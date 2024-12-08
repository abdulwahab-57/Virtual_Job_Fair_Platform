class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      case params[:user][:user_type]
      when "student"
        student = Student.create!(
          roll_number: params[:user][:roll_number],
          graduation_year: params[:user][:graduation_year]
        )
        resource.profile = student
      when "recruiter"
        recruiter = Recruiter.create!(
          company_name: params[:user][:company_name],
          designation: params[:user][:designation]
        )
        resource.profile = recruiter
      when "careerOffice"
        career_office = CareerOffice.create!(
          institution_name: params[:user][:institution_name],
          department: params[:user][:department]
        )
        resource.profile = career_office
      end
      resource.save
    end
  end
end

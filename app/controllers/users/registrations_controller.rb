class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      case params[:user][:user_type]
      when "student"
        resource.profile = Student.create!(roll_number: params[:user][:roll_number], graduation_year: params[:user][:graduation_year])
      when "recruiter"
        resource.profile = Recruiter.create!(company_name: params[:user][:company_name], designation: params[:user][:designation])
      when "careerOffice"
        resource.profile = CareerOffice.create!(institution_name: params[:user][:institution_name], department: params[:user][:department])
      end
      resource.save
    end
  end
end

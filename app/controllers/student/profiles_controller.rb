class Student::ProfilesController < Student::BaseController
  before_action :set_user, only: [ :show, :edit, :update ]
  def show
    @header_text= "My Profile"
  end

  def edit
    @header_text= "Edit My Profile"

    @form_action=student_profile_path(@user.id)
  end

  def update
    ActiveRecord::Base.transaction do
      if @user.update!(user_params)
        redirect_to student_profile_path(@user.id), notice: "Profile updated successfully."
      else
        render :edit, alert: "Failed to update the profile."
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render :edit, alert: "Failed to update the profile: #{e.message}"
  end

  private
  def set_user
    @user = User.select(:id, :full_name, :email, :profile_picture_url).includes(student_profile: [ :educations, :projects, :activities_honors, :skills, :interests, :location_preferences ]).find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :full_name,
      :email,
      :profile_picture,
      student_profile_attributes: [
        :id, :date_of_birth, :phone_number, :email_personal, :address, :linkedin_url,
        location_preferences_attributes: [ :id, :location, :_destroy ],
        educations_attributes: [ :id, :institution_name, :degree_title, :field_of_study, :graduation_year ],
        projects_attributes: [ :id, :project_name, :description ],
        activities_honors_attributes: [ :id, :title, :organization ],
        skills_attributes: [ :id, :title, :skill_list ],
        interests_attributes: [ :id, :interest_list ]
      ]
    )
  end
end

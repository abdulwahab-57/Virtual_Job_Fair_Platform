class CareerOfficer::StudentProfilesController < CareerOfficer::BaseController
  before_action :set_users, only: [ :index ]
  before_action :set_user, only: [ :show, :edit, :update, :update_status ]

  def index
    @header_text= "Student Profiles"
  end

  def show
    @header_text= "Student Profile"

    @edit_profile_path = edit_career_officer_student_profile_path(params[:id])
    render "student/profiles/show"
  end

  def edit
    @header_text= "Edit Student Profile"

    @form_action=career_officer_student_profile_path(@user.id)
    render "student/profiles/edit"
  end

  def update
    ActiveRecord::Base.transaction do
      if @user.update!(user_params)
        redirect_to career_officer_student_profile_path(@user.id), notice: "Profile updated successfully."
      else
        render :edit, alert: "Failed to update the profile."
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render :edit, alert: "Failed to update the profile: #{e.message}"
  end

  def update_status
    if @user.student_profile.update(status: params[:status])
      render json: {
        success: true,
        message: "Status updated successfully",
        status: @user.student_profile.status,
        updated_at: @user.student_profile.updated_at,
        redirect_url: "/career_officer/student_profiles"
      }
    else
      render json: {
        success: false,
        message: "Failed to update status",
        errors: @user.student_profile.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def set_users
     @users = User.where(user_type: "student").select(:id, :full_name, :email, :profile_picture_url).includes(:student_profile)
  end

  def set_user
    @user = User.find(params[:id])
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

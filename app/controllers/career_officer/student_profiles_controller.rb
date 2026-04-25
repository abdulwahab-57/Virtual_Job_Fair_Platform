class CareerOfficer::StudentProfilesController < CareerOfficer::BaseController
  include Pagy::Backend
  include PurgesMissingProfilePicture

  before_action :set_users, only: [ :index ]
  before_action :set_user, only: [ :show, :edit, :update, :update_status ]
  before_action :purge_missing_profile_picture, only: [ :show, :edit ]

  def index
    @header_text = "Student Profiles"
  end

  def show
    @header_text = "Student Profile"

    @edit_profile_path = edit_career_officer_student_profile_path(params[:id])
    render "student/profiles/show"
  end

  def edit
    @header_text = "Edit Student Profile"
    @form_action = career_officer_student_profile_path(@user.id)

    # Same pre-building as Student::ProfilesController#edit — the shared view
    # relies on these slots existing so it never calls .build itself.
    sp = @user.student_profile
    sp.location_preferences.build while sp.location_preferences.size < 3
    sp.educations.build            while sp.educations.size < 2
    sp.projects.build              while sp.projects.size < 5
    sp.activities_honors.build     while sp.activities_honors.size < 3
    sp.skills.build                while sp.skills.size < 2
    sp.interests.build             if sp.interests.empty?

    render "student/profiles/edit"
  end

  def update
    ActiveRecord::Base.transaction do
      if user_params[:profile_picture].present? && @user.profile_picture.attached?
        @user.profile_picture.purge
      end

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

  def download_profiles
    @user_ids = params[:user_ids].is_a?(Array) ? params[:user_ids] : [ params[:user_ids] ].compact

    if @user_ids.blank?
      flash[:alert] = "No profiles selected for download"
      redirect_back(fallback_location: career_officer_student_profiles_path)
      return
    end

    @users = User.includes(student_profile: [ :educations, :projects, :activities_honors, :skills, :interests, :location_preferences ]).where(id: @user_ids)

    respond_to do |format|
      format.html { redirect_to career_officer_student_profiles_path, alert: "PDF format required" }
      format.pdf do
        html = render_to_string(
          template: "career_officer/student_profiles/download_profiles",
          layout: "pdf",
          formats: [ :html ]
        )

        pdf = Grover.new(html, style_tag_options: [ { path: "app/assets/builds/tailwind.css" } ]).to_pdf

        send_data pdf,
          filename: "student_profiles_#{Date.today.strftime('%Y%m%d')}.pdf",
          type: "application/pdf",
          disposition: "attachment"
      end
    end
  end

  private

  def set_users
    query = StudentProfileQuery.new(params[:q])
    @q    = query.ransack_object
    @pagy, @users = pagy(query.results, items: 50)

    @degree_options          = Education::DEGREE_OPTIONS
    @graduation_year_options = Education.available_graduation_years
  end

  def set_user
    @user = User.includes(student_profile: [ :educations, :projects, :activities_honors, :skills, :interests, :location_preferences ]).find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :full_name,
      :email,
      :profile_picture,
      student_profile_attributes: [
        :id, :date_of_birth, :phone_number, :email_personal, :address, :linkedin_url,
        location_preferences_attributes: [ :id, :location, :_destroy ],
        educations_attributes: [ :id, :institution_name, :degree, :graduation_year ],
        projects_attributes: [ :id, :project_name, :description ],
        activities_honors_attributes: [ :id, :title, :organization ],
        skills_attributes: [ :id, :title, :skill_list ],
        interests_attributes: [ :id, :interest_list ]
      ]
    )
  end
end

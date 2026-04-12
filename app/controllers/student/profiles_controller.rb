class Student::ProfilesController < Student::BaseController
  include PurgesMissingProfilePicture

  before_action :set_user, only: [ :show, :edit, :update ]
  # Tell the browser never to cache the edit page. Without this, hitting the
  # Back button after a successful save shows the old cached form (which has
  # no IDs for newly created records), and resubmitting it creates duplicates.
  before_action :no_cache, only: [ :edit ]
  # Purge the profile picture DB record if the backing file is missing from
  # storage (e.g. manually deleted, or local dev without production files).
  # Keeps DB and storage in sync automatically without crashing the view.
  before_action :purge_missing_profile_picture, only: [ :show, :edit ]
  def show
    @header_text= "My Profile"
  end

  def edit
    @header_text = "Edit My Profile"
    @form_action = student_profile_path(@user.id)

    # Pre-build empty slots for every fixed-length nested section so the view
    # never calls .build itself.  Calling .build inside the view mutates the
    # in-memory association; when the same object is then re-rendered (e.g.
    # after a validation failure) or processed by a later fields_for block,
    # the ghost records get submitted without an id and Rails creates duplicate
    # rows instead of updating the existing ones.
    sp = @user.student_profile
    sp.location_preferences.build while sp.location_preferences.size < 3
    sp.educations.build            while sp.educations.size < 2
    sp.projects.build              while sp.projects.size < 5
    sp.activities_honors.build     while sp.activities_honors.size < 3
    sp.skills.build                while sp.skills.size < 2
    sp.interests.build             if sp.interests.empty?
  end

  def update
    ActiveRecord::Base.transaction do
      # Purge the old profile picture if a new one is being uploaded
      if user_params[:profile_picture].present? && @user.profile_picture.attached?
        @user.profile_picture.purge
      end

      # Store original model for comparison
      original_email = @user.student_profile.email_personal
      new_email = user_params.dig(:student_profile_attributes, :email_personal)

      if @user.update!(user_params)
        # Check if personal email was updated and if it's a non-NU email
        if new_email &&
           new_email != original_email &&
           !new_email.match?(/\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+\.nu\.edu\.pk\z/)
          redirect_to student_profile_path(@user.id),
                      notice: "Profile updated successfully. Note: We recommend using your NU email address (campus.nu.edu.pk)."
        else
        redirect_to student_profile_path(@user.id), notice: "Profile updated successfully."
        end
      else
        render :edit, alert: "Failed to update the profile."
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render :edit, alert: "Failed to update the profile: #{e.message}"
  end

  private

  def no_cache
    response.headers["Cache-Control"] = "no-store"
  end

  def set_user
    @user = User.select(:id, :full_name, :email).includes(student_profile: [ :educations, :projects, :activities_honors, :skills, :interests, :location_preferences ]).find(current_user.id)
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

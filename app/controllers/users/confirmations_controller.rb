class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      if resource.recruiter?
        Rails.logger.info "Recruiter confirmed: #{resource.email}"
        resource.send_career_officer_confirmation_request
        set_flash_message!(:notice, :recruiter_confirmed)
      else
        set_flash_message!(:notice, :confirmed)
      end
      redirect_to after_confirmation_path_for(resource_name, resource)
    else
      Rails.logger.error "Confirmation errors: #{resource.errors.full_messages}"
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  def confirm_recruiter
    recruiter = User.find_by_approval_token(params[:approval_token])

    if recruiter
      Rails.logger.info "Recruiter found: #{recruiter.email}"
      Rails.logger.info "Career officer confirmed before update: #{recruiter.career_officer_confirmed?}"

      unless recruiter.career_officer_confirmed?
        recruiter.update(career_officer_confirmed: true) # Update the database column
        Rails.logger.info "Career officer confirmed after update: #{recruiter.career_officer_confirmed?}"
        set_flash_message!(:notice, :recruiter_fully_confirmed)
      else
        set_flash_message!(:alert, :already_confirmed)
      end
    else
      set_flash_message!(:alert, :invalid_token)
    end

    redirect_to new_user_session_path
  end
end

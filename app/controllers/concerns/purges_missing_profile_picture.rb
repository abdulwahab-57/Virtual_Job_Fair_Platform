module PurgesMissingProfilePicture
  extend ActiveSupport::Concern

  # Purges the profile picture DB record when the backing file is missing
  # from storage (e.g. manually deleted, or local dev without production
  # files). Call as a before_action on any action that renders the picture
  # so the view sees attached? == false and shows the placeholder instead
  # of raising ActiveStorage::FileNotFoundError.
  def purge_missing_profile_picture
    return unless @user.profile_picture.attached?
    return if ActiveStorage::Blob.service.exist?(@user.profile_picture.blob.key)

    @user.profile_picture.purge
  end
end

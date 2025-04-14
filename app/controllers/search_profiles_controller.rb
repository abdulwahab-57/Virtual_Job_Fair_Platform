class SearchProfilesController < ApplicationController
  def index
    @search_results = User.where("name LIKE ?", "%#{params[:query]}%")
  end
end

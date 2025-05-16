class GithubAnalyzerController < Recruiter::BaseController
  before_action :authenticate_user!
  before_action :authorize_recruiter

  def index
    @analyses = GithubAnalysis.includes(student: { user: :student_profile })
                            .order(total_score: :desc)
                            .page(params[:page]).per(10)
    @total_pages = @analyses.total_pages
    @current_page = @analyses.current_page
  end

  def view_report
    @analysis = GithubAnalysis.find(params[:id])
    authorize_recruiter_view!(@analysis)
  end

  def download_report
    @analysis = GithubAnalysis.find(params[:id])
    authorize_recruiter_view!(@analysis)

    respond_to do |format|
      format.pdf do
        render pdf: "github_analysis_#{@analysis.id}",
               template: "github_analyzer/report",
               layout: "pdf",
               disposition: "attachment"
      end
    end
  end

  def evaluate
    @analysis = GithubAnalysis.find(params[:id])
    authorize_recruiter_view!(@analysis)

    if @analysis.update(evaluation: params[:evaluation])
      redirect_to github_analyzer_rankings_path, notice: "Evaluation updated successfully"
    else
      redirect_to github_analyzer_rankings_path, alert: "Failed to update evaluation"
    end
  end

  def analyze_github
    @analysis = GithubAnalysis.find(params[:id])
    authorize_recruiter_view!(@analysis)

    begin
      github_data = fetch_github_data(@analysis.github_url)
      update_analysis_scores(@analysis, github_data)
      redirect_to github_analyzer_view_report_path(@analysis), notice: "GitHub analysis updated successfully"
    rescue => e
      redirect_to github_analyzer_view_report_path(@analysis), alert: "Failed to analyze GitHub: #{e.message}"
    end
  end

  private

  def authorize_recruiter
    redirect_to root_path, alert: "Access denied!" unless current_user.user_type == "recruiter"
  end

  def authorize_recruiter_view!(analysis)
    unless analysis && current_user.user_type == "recruiter"
      redirect_to root_path, alert: "Unauthorized access"
    end
  end

  def fetch_github_data(github_url)
    # This is a placeholder for GitHub API integration
    # You would typically use the GitHub API to fetch real data
    {
      commits_count: rand(10..100),
      commit_frequency: rand(1..50),
      code_quality: rand(1..50),
      repo_activity: rand(1..50),
      collaboration: rand(1..50)
    }
  end

  def update_analysis_scores(analysis, github_data)
    analysis.update!(
      commits_count: github_data[:commits_count],
      commit_frequency_score: github_data[:commit_frequency],
      code_quality_score: github_data[:code_quality],
      repo_activity_score: github_data[:repo_activity],
      collaboration_score: github_data[:collaboration],
      report_details: github_data
    )
  end
end

class GithubAnalysis < ApplicationRecord
  belongs_to :student
  has_one :user, through: :student

  validates :total_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 200 }
  validates :commit_frequency_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 50 }
  validates :code_quality_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 50 }
  validates :repo_activity_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 50 }
  validates :collaboration_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 50 }
  validates :commits_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :evaluation, inclusion: { in: %w[excellent good needs_improvement], allow_nil: true }
  validates :github_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }

  before_validation :calculate_total_score
  before_validation :normalize_github_url

  private

  def calculate_total_score
    self.total_score = [
      commit_frequency_score,
      code_quality_score,
      repo_activity_score,
      collaboration_score
    ].sum
  end

  def normalize_github_url
    return unless github_url.present?
    self.github_url = github_url.strip.downcase
    self.github_url = "https://github.com/#{github_url}" unless github_url.start_with?("http")
  end
end

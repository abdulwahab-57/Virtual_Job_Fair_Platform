# Ransack + Pagy Student Profiles Search Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the manual `StudentProfileFilterable` concern with a Ransack-backed `StudentProfileQuery` object and Pagy pagination, giving career officers text search, multi-select filters, and sortable table columns.

**Architecture:** A `StudentProfileQuery` object owns the base scope, eager loading, distinct deduplication, and Ransack invocation. The controller delegates to it in three lines inside `set_users`. Pagy paginates the resulting AR relation. The concern is deleted entirely.

**Tech Stack:** Rails 7.2, Ransack 4.x, Pagy 9.x, PostgreSQL, Minitest

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `Gemfile` | Modify | Add ransack + pagy |
| `app/models/education.rb` | Modify | DEGREE_OPTIONS constant, ransackable_attributes, available_graduation_years |
| `app/models/user.rb` | Modify | ransackable_attributes, ransackable_associations |
| `app/models/student_profile.rb` | Modify | ransackable_attributes, ransackable_associations |
| `config/initializers/pagy.rb` | Create | Pagy defaults |
| `app/helpers/application_helper.rb` | Modify | Include Pagy::Frontend |
| `app/queries/student_profile_query.rb` | Create | Query object — base scope, includes, distinct, Ransack |
| `app/controllers/career_officer/student_profiles_controller.rb` | Modify | Remove concern, add Pagy::Backend, slim set_users |
| `app/controllers/concerns/student_profile_filterable.rb` | Delete | Replaced entirely by query object |
| `app/views/career_officer/student_profiles/index.html.erb` | Modify | Ransack form, sort_link headers, pagy_nav |
| `test/models/education_test.rb` | Modify | Tests for new class methods + constant |
| `test/models/user_test.rb` | Modify | Tests for ransackable declarations |
| `test/models/student_profile_test.rb` | Modify | Tests for ransackable declarations |
| `test/queries/student_profile_query_test.rb` | Create | Unit tests for query object |

---

## Task 1: Add Gems

**Files:**
- Modify: `Gemfile`

- [ ] **Step 1: Add ransack and pagy to Gemfile**

Open `Gemfile`. After the line `gem "jwt", "~> 1.5", ">= 1.5.4"` at the bottom, add:

```ruby
gem "ransack", "~> 4.2"
gem "pagy", "~> 9.0"
```

- [ ] **Step 2: Install gems**

```bash
bundle install
```

Expected: Both gems resolve and install without conflicts. `Gemfile.lock` updates.

- [ ] **Step 3: Commit**

```bash
git add Gemfile Gemfile.lock
git commit -m "feat: add ransack and pagy gems"
```

---

## Task 2: Education Model — Constants and Query Method

**Files:**
- Modify: `app/models/education.rb`
- Modify: `test/models/education_test.rb`

The `DEGREE_OPTIONS` constant currently lives in the `StudentProfileFilterable` concern. It belongs on `Education` since it describes education data. Moving it here gives every caller a single authoritative source.

- [ ] **Step 1: Write failing tests**

Open `test/models/education_test.rb`. Add these tests (preserve any existing tests):

```ruby
require "test_helper"

class EducationTest < ActiveSupport::TestCase
  test "DEGREE_OPTIONS is a frozen non-empty array of strings" do
    assert Education::DEGREE_OPTIONS.frozen?
    assert Education::DEGREE_OPTIONS.any?
    assert Education::DEGREE_OPTIONS.all? { |d| d.is_a?(String) }
  end

  test "ransackable_attributes includes degree and graduation_year" do
    attrs = Education.ransackable_attributes
    assert_includes attrs, "degree"
    assert_includes attrs, "graduation_year"
    refute_includes attrs, "institution_name"
    refute_includes attrs, "student_profile_id"
  end

  test "available_graduation_years returns integers sorted descending" do
    StudentProfile.delete_all
    User.where(user_type: "student").delete_all

    user = User.new(
      full_name: "Test Student", email: "test@cfd.nu.edu.pk",
      password: "password123", password_confirmation: "password123",
      user_type: "student", confirmed_at: Time.current
    )
    sp = user.build_student_profile(email_personal: "test@gmail.com")
    user.save!(validate: false)

    sp.educations.create!(degree: Education::DEGREE_OPTIONS.first, graduation_year: 2024)
    sp.educations.create!(degree: Education::DEGREE_OPTIONS.first, graduation_year: 2025)
    sp.educations.create!(degree: "Unknown Degree", graduation_year: 2023)

    years = Education.available_graduation_years
    assert_equal [2025, 2024], years
    refute_includes years, 2023
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
bin/rails test test/models/education_test.rb
```

Expected: 3 failures — `uninitialized constant Education::DEGREE_OPTIONS`, `NoMethodError: ransackable_attributes`, `NoMethodError: available_graduation_years`.

- [ ] **Step 3: Implement the changes in Education model**

Replace the entire contents of `app/models/education.rb` with:

```ruby
class Education < ApplicationRecord
  belongs_to :student_profile

  DEGREE_OPTIONS = [
    "BS (Computer Science)",
    "BS (Artificial Intelligence)",
    "BS (Software Engineering)",
    "BS (Business Analytics)",
    "BS (Electrical Engineering)",
    "Bachelor of Business Administration"
  ].freeze

  validates :institution_name, allow_blank: true, length: { maximum: 80 }
  validates :degree, allow_blank: true, length: { maximum: 50 }
  validates :graduation_year, allow_blank: true,
            numericality: {
              only_integer: true,
              greater_than: 1900,
              less_than_or_equal_to: -> { Date.current.year + 10 }
            }

  def self.ransackable_attributes(auth_object = nil)
    %w[degree graduation_year]
  end

  def self.available_graduation_years
    where(degree: DEGREE_OPTIONS)
      .where.not(graduation_year: nil)
      .distinct
      .pluck(:graduation_year)
      .sort
      .reverse
  end
end
```

- [ ] **Step 4: Run tests — expect them to pass**

```bash
bin/rails test test/models/education_test.rb
```

Expected: 3 tests pass, 0 failures.

- [ ] **Step 5: Commit**

```bash
git add app/models/education.rb test/models/education_test.rb
git commit -m "feat: add DEGREE_OPTIONS, ransackable_attributes, available_graduation_years to Education"
```

---

## Task 3: User and StudentProfile — Ransackable Declarations

**Files:**
- Modify: `app/models/user.rb`
- Modify: `app/models/student_profile.rb`
- Modify: `test/models/user_test.rb`
- Modify: `test/models/student_profile_test.rb`

Ransack 2.x+ requires explicit allowlists. Without these methods, Ransack raises `ArgumentError` when any attribute or association is used in a search.

- [ ] **Step 1: Write failing tests for User**

Open `test/models/user_test.rb`. Add:

```ruby
test "ransackable_attributes includes full_name and email only" do
  attrs = User.ransackable_attributes
  assert_includes attrs, "full_name"
  assert_includes attrs, "email"
  refute_includes attrs, "encrypted_password"
  refute_includes attrs, "user_type"
end

test "ransackable_associations includes student_profile" do
  assocs = User.ransackable_associations
  assert_includes assocs, "student_profile"
  refute_includes assocs, "recruiter_profile"
end
```

- [ ] **Step 2: Write failing tests for StudentProfile**

Open `test/models/student_profile_test.rb`. Add:

```ruby
test "ransackable_attributes includes status only" do
  attrs = StudentProfile.ransackable_attributes
  assert_includes attrs, "status"
  refute_includes attrs, "email_personal"
  refute_includes attrs, "phone_number"
end

test "ransackable_associations includes educations" do
  assocs = StudentProfile.ransackable_associations
  assert_includes assocs, "educations"
  refute_includes assocs, "projects"
end
```

- [ ] **Step 3: Run tests to verify they fail**

```bash
bin/rails test test/models/user_test.rb test/models/student_profile_test.rb
```

Expected: 4 failures — `NoMethodError: ransackable_attributes` on both models.

- [ ] **Step 4: Add ransackable declarations to User**

In `app/models/user.rb`, add these two methods immediately before the `private` line (around line 165):

```ruby
  def self.ransackable_attributes(auth_object = nil)
    %w[full_name email]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[student_profile]
  end

  private
```

- [ ] **Step 5: Add ransackable declarations to StudentProfile**

In `app/models/student_profile.rb`, add these two methods at the bottom, before the final `end`:

```ruby
  def self.ransackable_attributes(auth_object = nil)
    %w[status]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[educations]
  end
end
```

- [ ] **Step 6: Run tests — expect them to pass**

```bash
bin/rails test test/models/user_test.rb test/models/student_profile_test.rb
```

Expected: 4 tests pass, 0 failures.

- [ ] **Step 7: Commit**

```bash
git add app/models/user.rb app/models/student_profile.rb \
        test/models/user_test.rb test/models/student_profile_test.rb
git commit -m "feat: add ransackable_attributes and ransackable_associations to User and StudentProfile"
```

---

## Task 4: Pagy Initializer and ApplicationHelper

**Files:**
- Create: `config/initializers/pagy.rb`
- Modify: `app/helpers/application_helper.rb`

- [ ] **Step 1: Create the Pagy initializer**

Create `config/initializers/pagy.rb` with this content:

```ruby
Pagy::DEFAULT[:items] = 50
Pagy::DEFAULT[:size]  = 9
```

`items` sets 50 records per page (matches the existing PER_PAGE constant). `size` sets 9 page-number links in the navigation bar.

- [ ] **Step 2: Add Pagy::Frontend to ApplicationHelper**

Replace the entire contents of `app/helpers/application_helper.rb` with:

```ruby
module ApplicationHelper
  include Pagy::Frontend
end
```

- [ ] **Step 3: Verify the app boots without error**

```bash
bin/rails runner "puts Pagy::DEFAULT[:items]"
```

Expected output: `50`

- [ ] **Step 4: Commit**

```bash
git add config/initializers/pagy.rb app/helpers/application_helper.rb
git commit -m "feat: add Pagy initializer and include Pagy::Frontend in ApplicationHelper"
```

---

## Task 5: StudentProfileQuery Object

**Files:**
- Create: `app/queries/student_profile_query.rb`
- Create: `test/queries/student_profile_query_test.rb`

- [ ] **Step 1: Create the queries directory and test file**

```bash
mkdir -p app/queries test/queries
```

- [ ] **Step 2: Write failing tests**

Create `test/queries/student_profile_query_test.rb`:

```ruby
require "test_helper"

class StudentProfileQueryTest < ActiveSupport::TestCase
  test "results only returns students, not other user types" do
    # Create a career officer user without hitting domain validations
    officer = User.new(
      full_name: "Officer", email: "officer@example.com",
      password: "password123", user_type: "career_officer",
      confirmed_at: Time.current
    )
    officer.save!(validate: false)

    query = StudentProfileQuery.new({})
    result_ids = query.results.pluck(:id)

    refute_includes result_ids, officer.id
  ensure
    officer&.destroy
  end

  test "ransack_object is memoised — same object returned on second call" do
    query = StudentProfileQuery.new({})
    assert_same query.ransack_object, query.ransack_object
  end

  test "results returns an ActiveRecord::Relation" do
    query = StudentProfileQuery.new({})
    assert_kind_of ActiveRecord::Relation, query.results
  end

  test "initializing with nil search params does not raise" do
    assert_nothing_raised { StudentProfileQuery.new(nil).results }
  end

  test "results filters by status when q[student_profile_status_in] param given" do
    # Create two students with different statuses, bypassing validations
    reviewed_user = User.new(
      full_name: "Reviewed Student", email: "reviewed@cfd.nu.edu.pk",
      password: "password123", user_type: "student", confirmed_at: Time.current
    )
    reviewed_user.save!(validate: false)
    sp1 = reviewed_user.build_student_profile(email_personal: "reviewed@gmail.com")
    sp1.save!(validate: false)
    sp1.update_column(:status, "Reviewed")

    not_reviewed_user = User.new(
      full_name: "NotReviewed Student", email: "notreviewed@cfd.nu.edu.pk",
      password: "password123", user_type: "student", confirmed_at: Time.current
    )
    not_reviewed_user.save!(validate: false)
    sp2 = not_reviewed_user.build_student_profile(email_personal: "notreviewed@gmail.com")
    sp2.save!(validate: false)
    sp2.update_column(:status, "Not Reviewed")

    query = StudentProfileQuery.new({ "student_profile_status_in" => ["Reviewed"] })
    result_ids = query.results.pluck(:id)

    assert_includes result_ids, reviewed_user.id
    refute_includes result_ids, not_reviewed_user.id
  ensure
    reviewed_user&.destroy
    not_reviewed_user&.destroy
  end
end
```

- [ ] **Step 3: Run tests to verify they fail**

```bash
bin/rails test test/queries/student_profile_query_test.rb
```

Expected: Errors — `uninitialized constant StudentProfileQuery`.

- [ ] **Step 4: Create the query object**

Create `app/queries/student_profile_query.rb`:

```ruby
class StudentProfileQuery
  INCLUDES = {
    student_profile: [
      :educations,
      :projects,
      :activities_honors,
      :skills,
      :interests,
      :location_preferences
    ]
  }.freeze

  def initialize(search_params = {})
    @search_params = search_params.presence || {}
  end

  # Exposed to the view for search_form_for and sort_link helpers
  def ransack_object
    @ransack_object ||= base_scope.ransack(@search_params)
  end

  # Returns an AR relation — Pagy paginates on top; records are never fully loaded here
  def results
    ransack_object
      .result(distinct: true)
      .includes(INCLUDES)
  end

  private

  def base_scope
    User.where(user_type: "student")
  end
end
```

- [ ] **Step 5: Run tests — expect them to pass**

```bash
bin/rails test test/queries/student_profile_query_test.rb
```

Expected: 5 tests pass, 0 failures.

- [ ] **Step 6: Commit**

```bash
git add app/queries/student_profile_query.rb test/queries/student_profile_query_test.rb
git commit -m "feat: add StudentProfileQuery object with Ransack integration"
```

---

## Task 6: Controller Refactor

**Files:**
- Modify: `app/controllers/career_officer/student_profiles_controller.rb`
- Create: `test/controllers/career_officer/student_profiles_controller_test.rb`

- [ ] **Step 1: Write failing controller tests**

Create `test/controllers/career_officer/student_profiles_controller_test.rb`:

```ruby
require "test_helper"

class CareerOfficer::StudentProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @career_officer = User.new(
      full_name: "Career Officer", email: "co@example.com",
      password: "password123", user_type: "career_officer",
      confirmed_at: Time.current
    )
    @career_officer.save!(validate: false)
    sign_in @career_officer
  end

  teardown do
    @career_officer&.destroy
  end

  test "GET index responds with 200" do
    get career_officer_student_profiles_path
    assert_response :success
  end

  test "GET index with text search param responds with 200" do
    get career_officer_student_profiles_path,
        params: { q: { full_name_or_email_cont: "test" } }
    assert_response :success
  end

  test "GET index with status filter param responds with 200" do
    get career_officer_student_profiles_path,
        params: { q: { student_profile_status_in: ["Reviewed"] } }
    assert_response :success
  end

  test "GET index with degree filter param responds with 200" do
    get career_officer_student_profiles_path,
        params: { q: { student_profile_educations_degree_in: ["BS (Computer Science)"] } }
    assert_response :success
  end

  test "GET index with sort param responds with 200" do
    get career_officer_student_profiles_path,
        params: { q: { s: "full_name asc" } }
    assert_response :success
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
bin/rails test test/controllers/career_officer/student_profiles_controller_test.rb
```

Expected: Failures — controller still includes `StudentProfileFilterable` which uses old params (`status[]`, not `q[...]`), and `Pagy::Backend` is not yet included.

- [ ] **Step 3: Update the controller**

Replace the entire contents of `app/controllers/career_officer/student_profiles_controller.rb` with:

```ruby
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
```

- [ ] **Step 4: Run tests — expect them to pass**

```bash
bin/rails test test/controllers/career_officer/student_profiles_controller_test.rb
```

Expected: 5 tests pass, 0 failures.

- [ ] **Step 5: Commit**

```bash
git add app/controllers/career_officer/student_profiles_controller.rb \
        test/controllers/career_officer/student_profiles_controller_test.rb
git commit -m "feat: refactor StudentProfilesController to use StudentProfileQuery and Pagy"
```

---

## Task 7: Delete StudentProfileFilterable Concern

**Files:**
- Delete: `app/controllers/concerns/student_profile_filterable.rb`

The concern's only remaining reference was `include StudentProfileFilterable` in the controller, which is already removed. `DEGREE_OPTIONS` now lives on `Education`.

- [ ] **Step 1: Delete the file**

```bash
rm app/controllers/concerns/student_profile_filterable.rb
```

- [ ] **Step 2: Verify nothing references it**

```bash
grep -r "StudentProfileFilterable" app/ test/
```

Expected: No output — no remaining references.

- [ ] **Step 3: Run the full test suite to confirm nothing broke**

```bash
bin/rails test
```

Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add -u app/controllers/concerns/student_profile_filterable.rb
git commit -m "refactor: delete StudentProfileFilterable concern — replaced by StudentProfileQuery"
```

---

## Task 8: Update the Index View

**Files:**
- Modify: `app/views/career_officer/student_profiles/index.html.erb`

Replace the filter form, table headers, and pagination block. The table body, selection summary, and status modal are unchanged.

- [ ] **Step 1: Replace the entire view**

Replace the entire contents of `app/views/career_officer/student_profiles/index.html.erb` with:

```erb
<div class="max-w-[1121px] mx-auto min-h-screen px-4 sm:px-6" data-controller="table-actions">
  <div>
    <!-- Selection Summary -->
    <div data-table-actions-target="selectionSummary" class="hidden flex flex-wrap items-center gap-3 bg-gray-100 rounded-lg p-2">
      <div class="bg-[#1499DC] text-white px-2 py-1 rounded text-sm font-medium">
        <span data-table-actions-target="selectedCount">0</span> selected
      </div>

      <select data-table-actions-target="actionsSelect" data-action="change->table-actions#performAction" class="flex items-center bg-white border border-gray-300 rounded-md px-3 py-1 text-sm hover:bg-gray-50">
        <option value="" disabled selected>Actions</option>
        <option value="download_profiles">Download Profiles</option>
      </select>

      <button data-table-actions-target="clearSelection" data-action="click->table-actions#clearSelectedRows" class="text-gray-500 hover:text-gray-700">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
        </svg>
      </button>
    </div>

    <!-- Table section -->
    <div class="p-6 bg-white rounded-md shadow-sm">

      <!-- Ransack filter form -->
      <%= search_form_for @q, url: career_officer_student_profiles_path, method: :get,
            html: { class: "flex flex-wrap items-center justify-between gap-4 border border-slate-200 bg-gradient-to-r from-emerald-50 via-white to-slate-50 px-4 py-3 mb-4 rounded-xl shadow-sm" } do |f| %>

        <%# Text search — matches full_name OR email %>
        <div class="flex items-center gap-2 rounded-full border border-emerald-100 bg-white/90 px-3 py-1 shadow-sm">
          <%= f.search_field :full_name_or_email_cont,
                placeholder: "Search name or email...",
                class: "text-sm text-slate-700 focus:outline-none bg-transparent" %>
        </div>

        <div class="flex flex-wrap items-center gap-3 text-sm text-slate-700">

          <%# Status checkboxes %>
          <div class="flex items-center gap-3 rounded-full border border-emerald-100 bg-white/90 px-3 py-1 shadow-sm">
            <% [["Reviewed", "text-emerald-600 focus:ring-emerald-500"], ["Not Reviewed", "text-rose-500 focus:ring-rose-400"]].each_with_index do |(status, css), i| %>
              <% if i > 0 %><span class="h-4 w-px bg-slate-200"></span><% end %>
              <label class="flex items-center gap-2">
                <%= f.check_box :student_profile_status_in,
                      { multiple: true,
                        checked: Array(params.dig(:q, :student_profile_status_in)).include?(status),
                        class: "h-4 w-4 border-slate-300 rounded #{css}" },
                      status, nil %>
                <span class="font-medium"><%= status %></span>
              </label>
            <% end %>
          </div>
          <span class="text-xs text-slate-500">Leave unchecked to show all</span>

          <%# Graduation Year dropdown %>
          <details class="group relative">
            <summary class="cursor-pointer list-none rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 shadow-sm hover:border-emerald-200 hover:bg-emerald-50 focus:outline-none">
              Graduation Year
            </summary>
            <div class="absolute left-0 z-20 mt-2 w-56 rounded-lg border border-slate-200 bg-white p-3 shadow-lg">
              <div class="max-h-56 overflow-y-auto space-y-2 text-sm text-slate-700">
                <% @graduation_year_options.each do |year| %>
                  <label class="flex items-center gap-2">
                    <%= f.check_box :student_profile_educations_graduation_year_in,
                          { multiple: true,
                            checked: Array(params.dig(:q, :student_profile_educations_graduation_year_in)).include?(year.to_s),
                            class: "h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-slate-300 rounded" },
                          year, nil %>
                    <span><%= year %></span>
                  </label>
                <% end %>
              </div>
            </div>
          </details>

          <%# Degree dropdown %>
          <details class="group relative">
            <summary class="cursor-pointer list-none rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 shadow-sm hover:border-emerald-200 hover:bg-emerald-50 focus:outline-none">
              Degree
            </summary>
            <div class="absolute left-0 z-20 mt-2 w-72 rounded-lg border border-slate-200 bg-white p-3 shadow-lg">
              <div class="max-h-56 overflow-y-auto space-y-2 text-sm text-slate-700">
                <% @degree_options.each do |degree| %>
                  <label class="flex items-start gap-2">
                    <%= f.check_box :student_profile_educations_degree_in,
                          { multiple: true,
                            checked: Array(params.dig(:q, :student_profile_educations_degree_in)).include?(degree),
                            class: "mt-1 h-4 w-4 text-emerald-600 focus:ring-emerald-500 border-slate-300 rounded" },
                          degree, nil %>
                    <span><%= degree %></span>
                  </label>
                <% end %>
              </div>
            </div>
          </details>
        </div>

        <div class="flex items-center gap-2">
          <%= f.submit "Apply Filters",
                class: "cursor-pointer rounded-full bg-emerald-600 px-4 py-2 text-sm font-semibold text-white hover:bg-emerald-700" %>
          <%= link_to "Clear", career_officer_student_profiles_path,
                class: "rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 hover:bg-slate-50" %>
        </div>
      <% end %>

      <div class="bg-white rounded-lg shadow-sm">
        <!-- Table -->
        <div class="overflow-x-auto">
          <table class="min-w-[900px] w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-8">
                  <input type="checkbox" class="h-4 w-4 text-[#1499DC] focus:ring-[#1499DC] border-gray-300 rounded"
                    data-table-actions-target="checkboxAll"
                    data-action="change->table-actions#toggleAll">
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <%= sort_link @q, :full_name, "Student Name" %>
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <%= sort_link @q, :email, "Email" %>
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <%= sort_link @q, :student_profile_status, "Status" %>
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  <%= sort_link @q, :updated_at, "Last Updated" %>
                </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-56">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200" data-table-actions-target="tableBody">
              <% @users.each do |user| %>
                <% profile = user.student_profile %>
                <% primary_education = profile&.educations&.find { |e| e.degree.to_s.match?(/\ABS \(|\ABachelor of Business Administration/) } %>
                <% primary_degree = primary_education&.degree %>
                <% graduation_year = primary_education&.graduation_year %>
                <tr class="hover:bg-gray-50"
                  data-status="<%= profile&.status.to_s.downcase.gsub(' ', '-') %>"
                  data-user-id="<%= user.id %>"
                  data-degree="<%= primary_degree %>"
                  data-grad-year="<%= graduation_year %>">
                  <td class="px-6 py-4 whitespace-nowrap">
                    <input type="checkbox" class="h-4 w-4 text-[#1499DC] focus:ring-[#1499DC] border-gray-300 rounded"
                      data-table-actions-target="checkboxRow"
                      data-action="change->table-actions#checkRowSelection">
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= user.full_name %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= user.email %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <span data-action="click->table-actions#openStatusModal"
                      class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full
                      <%= profile&.status == 'Not Reviewed' ? 'bg-red-100 text-red-800' : 'bg-gray-100 text-gray-800' %> cursor-pointer">
                      <%= profile&.status %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= profile&.updated_at&.strftime("%b %d, %Y") %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 flex items-center gap-2 w-56">
                    <%= link_to "View", career_officer_student_profile_path(user.id), class: "text-white bg-[#1499DC] border hover:border-[#1499DC] px-2 py-1 rounded text-xs" %>
                    <%= link_to "Edit", edit_career_officer_student_profile_path(user.id), class: "text-white bg-[#272F33] border hover:border-[#272F33] px-2 py-1 rounded text-xs" %>
                    <%= link_to "PDF", download_profiles_career_officer_student_profiles_path(format: :pdf, user_ids: [ user.id ]), class: "text-white bg-[#0f7d1a] border hover:border-[#0f7d1a] px-2 py-1 rounded text-xs" %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>

        <!-- Pagy pagination -->
        <div class="flex flex-wrap items-center justify-between gap-3 border-t border-slate-200 px-4 py-3 text-sm text-slate-600">
          <span>Showing <%= @pagy.from %>–<%= @pagy.to %> of <%= @pagy.count %></span>
          <%== pagy_nav(@pagy) %>
        </div>
      </div>
    </div>
  </div>

  <!-- Status Change Modal (unchanged) -->
  <div data-table-actions-target="statusModal" class="fixed inset-0 bg-black bg-opacity-50 z-50 hidden flex items-center justify-center">
    <div class="bg-white rounded-lg shadow-xl p-6 w-96">
      <h2 class="text-lg font-semibold mb-4">Change status</h2>
      <div class="space-y-2">
        <button data-action="click->table-actions#changeStatus" data-status="Reviewed" class="w-full text-left px-4 py-2 hover:bg-gray-100 rounded flex items-center">
          <span class="w-4 h-4 mr-2 rounded-full bg-gray-100"></span>
          Reviewed
        </button>
        <button data-action="click->table-actions#changeStatus" data-status="Not Reviewed" class="w-full text-left px-4 py-2 hover:bg-gray-100 rounded flex items-center">
          <span class="w-4 h-4 mr-2 rounded-full bg-red-100"></span>
          Not Reviewed
        </button>
      </div>
      <div class="mt-4 flex justify-end space-x-2">
        <button data-action="click->table-actions#closeStatusModal" class="px-4 py-2 bg-gray-200 text-gray-700 rounded">
          Cancel
        </button>
        <button data-action="click->table-actions#applyStatus" class="px-4 py-2 bg-indigo-600 text-white rounded">
          Apply
        </button>
      </div>
    </div>
  </div>
</div>
```

- [ ] **Step 2: Run the full test suite**

```bash
bin/rails test
```

Expected: All tests pass.

- [ ] **Step 3: Start the server and smoke-test manually**

```bash
bin/dev
```

Open the career officer student profiles index in the browser. Verify:
- The filter form renders with text search, status checkboxes, graduation year dropdown, degree dropdown
- Typing a name in the search field and clicking "Apply Filters" filters the table
- Clicking "Clear" resets all filters
- Table column headers are clickable and toggle sort order (▲/▼ arrows appear)
- The pagination bar shows "Showing X–Y of Z" and renders page links
- Row checkboxes, bulk download, and the status modal still work

- [ ] **Step 4: Commit**

```bash
git add app/views/career_officer/student_profiles/index.html.erb
git commit -m "feat: migrate student profiles index to Ransack search form, sort links, and Pagy pagination"
```

---

## Completion Checklist

- [ ] `bin/rails test` passes with no failures
- [ ] Career officer can search by name/email
- [ ] Career officer can filter by status, degree, graduation year (multi-select)
- [ ] Table columns sort on click
- [ ] Pagination shows correct counts and navigates correctly
- [ ] "Clear" link resets all filters
- [ ] Bulk download and status modal still work
- [ ] No N+1 queries (verify with `bullet` gem or check logs — each page load should show a fixed number of queries regardless of result count)

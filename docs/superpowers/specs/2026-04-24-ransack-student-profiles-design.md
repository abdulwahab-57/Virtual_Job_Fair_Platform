# Ransack Search & Filtering — Career Officer Student Profiles

**Date:** 2026-04-24
**Status:** Approved

---

## Overview

Replace the manual `StudentProfileFilterable` concern with a Ransack-backed `StudentProfileQuery` object and Pagy pagination. Career officers gain text search, multi-select filters, and sortable table columns. The controller shrinks to ~4 lines in `set_users`; all query logic centralises in one testable class.

---

## Goals

- Text search across student name and email
- Multi-select filtering by status, degree, and graduation year
- Sortable table columns (name, email, status, last updated)
- Pagy pagination (replaces manual offset/limit)
- No N+1 queries
- Easy to add new filters without touching the controller or view structure

---

## Out of Scope

- Search on the `download_profiles` action (fetches by explicit `user_ids`)
- Recruiter or other role profile searches
- Saved/persisted search queries
- Async / Turbo-powered live search

---

## Gems Added

```ruby
gem "ransack"
gem "pagy", "~> 9.0"
```

Run `bundle install` after adding.

---

## Architecture

### Data Flow

```
Request params[:q]
  → StudentProfileQuery.new(params[:q])
    → base_scope: User.where(user_type: "student")
    → .ransack(@params)          # @q — exposed to view for form + sort links
    → .result(distinct: true)   # distinct prevents duplicate rows from education joins
    → .includes(INCLUDES)       # eager loads all associations
  → pagy(@query.results)        # Pagy paginates the AR relation
  → @pagy, @users               # view receives paginated collection + metadata
```

### Files Changed

| File | Change |
|------|--------|
| `Gemfile` | Add `ransack`, `pagy` |
| `app/queries/student_profile_query.rb` | **New** — query object |
| `config/initializers/pagy.rb` | **New** — Pagy config |
| `app/models/user.rb` | Add `ransackable_attributes`, `ransackable_associations` |
| `app/models/student_profile.rb` | Add `ransackable_attributes`, `ransackable_associations` |
| `app/models/education.rb` | Add `ransackable_attributes`, `DEGREE_OPTIONS`, `available_graduation_years` |
| `app/controllers/career_officer/student_profiles_controller.rb` | Remove concern, add `Pagy::Backend`, slim `set_users` |
| `app/helpers/application_helper.rb` | Add `include Pagy::Frontend` |
| `app/views/career_officer/student_profiles/index.html.erb` | Replace filter form, add sort links, replace pagination |
| `app/controllers/concerns/student_profile_filterable.rb` | **Deleted** |

---

## Component Designs

### 1. Model Layer

**`app/models/user.rb`** — add:
```ruby
def self.ransackable_attributes(auth_object = nil)
  %w[full_name email]
end

def self.ransackable_associations(auth_object = nil)
  %w[student_profile]
end
```

**`app/models/student_profile.rb`** — add:
```ruby
def self.ransackable_attributes(auth_object = nil)
  %w[status]
end

def self.ransackable_associations(auth_object = nil)
  %w[educations]
end
```

**`app/models/education.rb`** — add:
```ruby
DEGREE_OPTIONS = [
  "BS (Computer Science)",
  "BS (Artificial Intelligence)",
  "BS (Software Engineering)",
  "BS (Business Analytics)",
  "BS (Electrical Engineering)",
  "Bachelor of Business Administration"
].freeze

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
```

`DEGREE_OPTIONS` moves from the deleted concern to `Education` — it describes education data and belongs on the model.

---

### 2. Query Object

**`app/queries/student_profile_query.rb`**
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

  # Exposed to view for search_form_for and sort_link helpers
  def ransack_object
    @ransack_object ||= base_scope.ransack(@search_params)
  end

  # Returns AR relation — Pagy paginates on top, no memory bloat
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

**Key decisions:**

| Decision | Reason |
|----------|--------|
| `distinct: true` | Education joins produce duplicate User rows when a student has multiple matching educations |
| `presence \|\| {}` | Guards against nil params on direct URL hits |
| Memoised `ransack_object` | Called twice (controller + results); one object, one SQL parse |
| `INCLUDES` constant | Single definition of all eager-loaded associations; reusable if extracted later |
| Pagy excluded from query object | Pagy::Backend is controller infrastructure; keeping it out makes the object usable in jobs/exports/tests without HTTP context |

---

### 3. Controller

**`app/controllers/career_officer/student_profiles_controller.rb`**

Remove `include StudentProfileFilterable`. Add `include Pagy::Backend`.

Replace `set_users` with:
```ruby
def set_users
  query = StudentProfileQuery.new(params[:q])
  @q    = query.ransack_object
  @pagy, @users = pagy(query.results, items: 50)

  @degree_options          = Education::DEGREE_OPTIONS
  @graduation_year_options = Education.available_graduation_years
end
```

All other actions (`show`, `edit`, `update`, `update_status`, `download_profiles`) are unchanged.

---

### 4. Pagy Initializer

**`config/initializers/pagy.rb`**
```ruby
Pagy::DEFAULT[:items] = 50
Pagy::DEFAULT[:size]  = [1, 4, 4, 1]
```

---

### 5. Application Helper

**`app/helpers/application_helper.rb`**
```ruby
module ApplicationHelper
  include Pagy::Frontend
  # existing helpers remain unchanged
end
```

---

### 6. View Layer

**`app/views/career_officer/student_profiles/index.html.erb`**

#### Filter Form
```erb
<%= search_form_for @q, url: career_officer_student_profiles_path, method: :get do |f| %>

  <%# Text search: full_name OR email contains the term %>
  <div>
    <%= f.label :full_name_or_email_cont, "Search" %>
    <%= f.search_field :full_name_or_email_cont, placeholder: "Name or email..." %>
  </div>

  <%# Status multi-select %>
  <div>
    <p>Status</p>
    <% ["Reviewed", "Not Reviewed"].each do |status| %>
      <label>
        <%= f.check_box :student_profile_status_in,
            { multiple: true,
              checked: Array(params.dig(:q, :student_profile_status_in)).include?(status) },
            status, nil %>
        <%= status %>
      </label>
    <% end %>
  </div>

  <%# Degree multi-select %>
  <div>
    <p>Degree</p>
    <% @degree_options.each do |degree| %>
      <label>
        <%= f.check_box :student_profile_educations_degree_in,
            { multiple: true,
              checked: Array(params.dig(:q, :student_profile_educations_degree_in)).include?(degree) },
            degree, nil %>
        <%= degree %>
      </label>
    <% end %>
  </div>

  <%# Graduation Year multi-select %>
  <div>
    <p>Graduation Year</p>
    <% @graduation_year_options.each do |year| %>
      <label>
        <%= f.check_box :student_profile_educations_graduation_year_in,
            { multiple: true,
              checked: Array(params.dig(:q, :student_profile_educations_graduation_year_in)).include?(year.to_s) },
            year, nil %>
        <%= year %>
      </label>
    <% end %>
  </div>

  <%= f.submit "Apply Filters" %>
  <%= link_to "Clear", career_officer_student_profiles_path %>
<% end %>
```

#### Sortable Table Headers
```erb
<thead>
  <tr>
    <th><%= sort_link @q, :full_name, "Name" %></th>
    <th><%= sort_link @q, :email, "Email" %></th>
    <th><%= sort_link @q, :student_profile_status, "Status" %></th>
    <th><%= sort_link @q, :updated_at, "Last Updated" %></th>
    <th>Actions</th>
  </tr>
</thead>
```

#### Pagy Navigation
```erb
<%== pagy_nav(@pagy) %>
```

---

### Ransack Predicate Reference

| Form field | Ransack predicate | Behaviour |
|------------|------------------|-----------|
| Text search | `full_name_or_email_cont` | Case-insensitive ILIKE on both columns |
| Status | `student_profile_status_in` | Matches any selected status value |
| Degree | `student_profile_educations_degree_in` | Matches any selected degree across joined educations |
| Graduation Year | `student_profile_educations_graduation_year_in` | Matches any selected year across joined educations |
| Sort | Ransack `s` param via `sort_link` | Toggles asc/desc on the selected column |

---

## Security

- `ransackable_attributes` and `ransackable_associations` are explicitly allowlisted on every model — Ransack 2.x+ blocks any attribute not in these lists, preventing arbitrary column exposure.
- Filter values flow through Ransack's parameterised queries; no raw SQL interpolation.
- Existing `user_params` strong params on `update` are untouched.

---

## Extending Filters Later

To add a new filter (e.g., filter by `location_preferences.location`):

1. Add `ransackable_attributes` to `LocationPreference` model
2. Add `ransackable_associations` returning `%w[location_preferences]` to `StudentProfile`
3. Add the checkbox block to the view using predicate `student_profile_location_preferences_location_in`

No changes to the controller or query object required.

---

## Testing Approach

- **`StudentProfileQuery` unit tests** — instantiate with mock params, assert `results` returns correct users, assert `distinct: true` collapses duplicates
- **Controller request specs** — verify `params[:q]` flows through to filtered results, verify pagination headers present
- **Model unit tests** — verify `ransackable_attributes` allowlists are correct, verify `Education.available_graduation_years` returns sorted years

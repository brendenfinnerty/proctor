# DX Survey Application — Role-Based Branching

This project extends DX’s basic survey app to support **role-based branching**.  
Respondents now only see the questions relevant to their role (e.g. Data Engineer, Frontend Engineer, Product Manager).

---

## 🚀 Features

- Define **branching rules** per role using an admin matrix (Questions × Roles)
- Collect respondent **role** before survey and show/hide questions accordingly
- Store responses tagged with role for downstream analysis
- Simple **analytics dashboard** comparing responses across roles
- Fully editable through the Rails admin UI

---

## 🧩 Architecture Overview

| Layer                              | Purpose                                                                   |
| ---------------------------------- | ------------------------------------------------------------------------- |
| `BranchRule` model                 | Maps `(survey_id, question_id, role)` → `visible` flag                    |
| `Question#visible_for_role?`       | Central logic to decide if a question shows                               |
| `SurveysController`                | Handles role-aware `take`, `submit`, `branching`, and `analytics` actions |
| `views/surveys/branching.html.erb` | Admin matrix to toggle visibility                                         |
| `views/surveys/take.html.erb`      | Respondent view filtered by selected role                                 |

---

## ⚙️ Setup

```bash
# 1. Install Ruby gems
bundle install

# 2. Install JavaScript dependencies
npm install

# 3. Create & migrate the database
bin/rails db:create db:migrate

# 4. Load demo data
bin/rails db:seed

# 5. Run the app
bin/dev
```

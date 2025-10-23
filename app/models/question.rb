class Question < ApplicationRecord
  belongs_to :survey
  has_many   :responses,    dependent: :destroy

  # link questions to branching rules
  has_many   :branch_rules, dependent: :destroy

  validates :content, presence: true
  validates :question_type, presence: true

  # define question types
  QUESTION_TYPES = ['text', 'long_text', 'multiple_choice', 'checkbox', 'rating'].freeze

  # ensure position is maintained within a survey
  acts_as_list scope: :survey

  # serialize options as an array
  serialize :options, Array

  # ensure options are present for question types that need them
  validate :validate_options_for_question_type

  # --- Branching logic ---

  # default policy: if no rule exists for this role, show the question.
  # flip the default to `false` if you prefer "hidden unless allowed".
  def visible_for_role?(role)
    return true if role.blank?
    rule = branch_rules_by_role(role)
    rule.nil? ? true : rule.visible
  end

  # tiny cache-friendly finder for a single role
  def branch_rules_by_role(role)
    branch_rules.find { |r| r.role == role }
  end

  private

  def validate_options_for_question_type
    if ['multiple_choice', 'checkbox'].include?(question_type) && (options.nil? || options.empty?)
      errors.add(:options, "can't be blank for #{question_type} questions")
    end
  end
end
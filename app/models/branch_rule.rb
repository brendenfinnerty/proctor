class BranchRule < ApplicationRecord
  belongs_to :survey
  belongs_to :question

  validates :role, presence: true
  validates :question_id, uniqueness: { scope: [:survey_id, :role] }

  validate :question_belongs_to_survey
  private
  def question_belongs_to_survey
    errors.add(:question_id, "must belong to survey") if question&.survey_id != survey_id
  end
end
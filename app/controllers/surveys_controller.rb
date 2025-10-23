class SurveysController < ApplicationController
  ROLES = ["Data Engineer", "Frontend Engineer", "Product Manager"].freeze

  before_action :set_survey, only: [:show, :edit, :update, :destroy, :take, :submit, :branching, :update_branching, :analytics]

  def index
    @surveys = Survey.all
  end

  def show; end

  def new
    @survey = Survey.new
  end

  def create
    @survey = Survey.new(survey_params)
    if @survey.save
      redirect_to @survey, notice: 'Survey was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @survey.update(survey_params)
      redirect_to @survey, notice: 'Survey was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @survey.destroy
    redirect_to surveys_url, notice: 'Survey was successfully destroyed.'
  end

  # --- Respondent flow ---

  def take
    @role = params[:role].presence
    @questions = @survey.questions.order(:position).includes(:branch_rules)
    @questions = @questions.select { |q| q.visible_for_role?(@role) } if @role.present?
  end

  def submit
    role = params[:role].presence

    if params[:responses].present?
      visible_ids =
        if role.present?
          @survey.questions.includes(:branch_rules)
                 .select { |q| q.visible_for_role?(role) }
                 .map(&:id).map(&:to_s)
        else
          @survey.questions.pluck(:id).map(&:to_s)
        end

      params[:responses].each do |response_params|
        qid = response_params[:question_id].to_s
        next unless visible_ids.include?(qid)

        raw = response_params[:value]
        value = raw.is_a?(Array) ? raw.join(",") : raw

        @survey.responses.create(
          question_id: qid,
          value:       value,
          role:        role
        )
      end

      redirect_to surveys_path, notice: 'Thank you for completing the survey!'
    else
      redirect_to take_survey_path(@survey, role: role), alert: 'Please answer at least one question.'
    end
  end

  # --- Admin: Branching configuration ---

  def branching
    @roles     = ROLES
    @questions = @survey.questions.order(:position).includes(:branch_rules)
  end

  def update_branching
    visibility = params.fetch(:visibility, {}) # { "Role" => { "question_id" => "1"/"0" } }
    bool_cast  = ActiveModel::Type::Boolean.new

    ActiveRecord::Base.transaction do
      visibility.each do |role, by_qid|
        by_qid.each do |qid, vis|
          BranchRule
            .find_or_initialize_by(survey_id: @survey.id, question_id: qid, role: role)
            .update!(visible: bool_cast.cast(vis))
        end
      end
    end

    redirect_to branching_survey_path(@survey), notice: "Branching updated"
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = "Could not save branching: #{e.message}"
    @roles     = ROLES
    @questions = @survey.questions.order(:position).includes(:branch_rules)
    render :branching, status: :unprocessable_entity
  end

  # --- Analytics

  def analytics
    @roles = ROLES
    @by_role = @survey.responses.group(:role).count

    tracked_types = %w[multiple_choice rating]
    @questions = @survey.questions.where(question_type: tracked_types).order(:position)

    @distributions = @questions.each_with_object({}) do |q, h|
      h[q.id] = @survey.responses
                       .where(question_id: q.id)
                       .group(:role, :value)
                       .count
    end
  end

  private

  def set_survey
    @survey = Survey.find(params[:id])
  end

  def survey_params
    params.require(:survey).permit(:title, :description)
  end
end
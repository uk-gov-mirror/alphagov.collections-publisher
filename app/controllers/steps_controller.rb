class StepsController < ApplicationController
  before_action :require_gds_editor_permissions!

  def new
    @step = step_by_step_page.steps.new
  end

  def create
    step_params = params.require(:step).permit!
    @step = step_by_step_page.steps.new(step_params)

    if @step.save
      update_downstream

      redirect_to step_by_step_page_path(step_by_step_page.id), notice: 'Step was successfully created.'
    else
      render :new
    end
  end

  def edit
    step
  end

  def update
    step_params = params.require(:step).permit!

    if step.update(step_params)
      update_downstream

      redirect_to step_by_step_page_path(step_by_step_page.id), notice: 'Step was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if step.destroy
      update_downstream

      redirect_to step_by_step_page_path(step_by_step_page.id), notice: 'Step was successfully deleted.'
    else
      redirect_to step_by_step_page_path
    end
  end

private

  def update_downstream
    StepByStepDraftUpdateWorker.perform_async(step_by_step_page.id)
  end

  def step_by_step_page
    @step_by_step_page ||= StepByStepPage.find(params[:step_by_step_page_id])
  end

  def step
    @step ||= step_by_step_page.steps.find(params[:id])
  end

  def step_params
    params.require(:step).permit(:title, :logic, :optional, :contents)
  end
end

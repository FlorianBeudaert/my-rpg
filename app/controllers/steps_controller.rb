class StepsController < ApplicationController
def create
  current_user = User.find(session[:user_id])
  if current_user.is_admin == true
    @step = Step.new(step_params)
    @step.step_order = Quest.find(@step.quest_id).steps.count + 1
    if @step.save
      redirect_to admin_quest_path(@step.quest_id), notice: 'Step was successfully created.'
    else
      redirect_to admin_quest_path(@step.quest_id), alert: 'Step creation failed!' if @step.quest_id
    end
  else
    redirect_to admin_quests_path, alert: 'You are not an admin!'
  end
end

def delete
  current_user = User.find(session[:user_id])
  if current_user.is_admin == true
    step = Step.find_by(id: params[:id])
    if step && step.quest_id
      quest_id = step.quest_id
      step.destroy
      redirect_to admin_quest_path(quest_id), notice: 'Step was successfully deleted.'
    else
      redirect_to admin_quests_path, alert: 'Step not found or it does not belong to a quest!'
    end
  else
    redirect_to admin_quests_path, alert: 'You are not an admin!'
  end
end

  private

  def step_params
    params.require(:step).permit(:question, :answer, :quest_id, :fake_answer_1, :fake_answer_2, :fake_answer_3)
  end
end
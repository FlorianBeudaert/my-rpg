class QuestsController < ApplicationController
  def panel
    @quests = Quest.all
    @quest = Quest.new
  end

  def create
    current_user = User.find(session[:user_id])
    if current_user.is_admin == true
      @quest = Quest.new(quest_params)
      if @quest.save
        redirect_to admin_quests_path, notice: 'Quest was successfully created.'
      else
        redirect_to admin_quests_path, alert: 'Quest creation failed!'
      end
    else
      redirect_to admin_quests_path, alert: 'You are not an admin!'
      end
  end

  def delete
    current_user = User.find(session[:user_id])
    if current_user.is_admin == true
      Quest.find(params[:id]).destroy
      redirect_to admin_quests_path, notice: 'Quest was successfully deleted.'
    else
      redirect_to admin_quests_path, alert: 'You are not an admin!'
    end
  end


  def list
    @quests = Quest.all
  end

  def choose
    current_user = User.find(session[:user_id])
    chosen_quest = Quest.find(params[:id])

    if current_user.quest_in_progress == 0 && !current_user.completed_quests.include?(chosen_quest)
      current_user.quest_in_progress = params[:id]
      current_user.quest_step = 1
      current_user.save
      redirect_to quests_list_path, notice: 'Quest was successfully chosen.'
    else
      redirect_to quests_list_path, alert: 'You cannot choose this quest!'
    end
  end

  def cancel
    current_user = User.find(session[:user_id])
    if current_user.quest_in_progress == params[:id].to_i
      current_user.quest_in_progress = 0
      current_user.quest_step = 0
      if current_user.save
        redirect_to quests_list_path, notice: 'Quest was successfully cancelled.'
      else
        redirect_to quests_list_path, alert: 'Failed to cancel quest!'
      end
    end
  end

  def show
    @quest = Quest.find(params[:id])
  end

  private

  def quest_params
    params.require(:quest).permit(:name, :experience, :question, :answer)
  end
end
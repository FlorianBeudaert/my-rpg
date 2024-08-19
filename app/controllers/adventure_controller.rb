class AdventureController < ApplicationController
  def index
    @user = User.find(session[:user_id])
    @quests = Quest.all
    @steps = Step.all

    if @user.quest_in_progress != 0
      @quest_in_progress = Quest.find(@user.quest_in_progress)
    end

    def step
      @user = User.find(session[:user_id])
      if @user.quest_in_progress != 0
        @quest_in_progress = Quest.find(@user.quest_in_progress)
        @current_step = @quest_in_progress.steps.find_by(step_order: @user.quest_step)
      end
    end

    def answer
      @user = User.find(session[:user_id])
      @current_step = Step.find(params[:step_id])
      @quest_in_progress = Quest.find(@user.quest_in_progress)

      xp_bonus = 1
      if @user.inventory
        @user.inventory.each do |key, item|
          if item["equipped"] == true
            xp_bonus += item["xp_bonus"].to_f
          end
        end
      end

      if @current_step.answer == params[:answer]
        if @current_step == @quest_in_progress.steps.order(step_order: :desc).first
          @user.experiences += @quest_in_progress.experience * xp_bonus
          @user.check_experience
          @user.quest_in_progress = 0
          @user.quest_step = 0
          @user.quest_completeds.create(quest_id: @quest_in_progress.id)
          @user.save
          if(xp_bonus > 1)
            redirect_to congratulations_adventure_path, notice: 'Correct answer! You have completed the quest! (+' + @quest_in_progress.experience.to_s + 'XP x ' + xp_bonus.to_s + 'XP bonus = ' + (@quest_in_progress.experience * xp_bonus).to_s + 'XP)'
          else
            redirect_to congratulations_adventure_path, notice: 'Correct answer! You have completed the quest! (+' + @quest_in_progress.experience.to_s + 'XP)'
          end
        else
          xp = rand(@current_step.quest.experience * 0.25) + 1
          @user.experiences += xp * xp_bonus
          @user.check_experience
          @user.quest_step += 1
          @user.save
          if(xp_bonus > 1)
            redirect_to adventure_step_path, notice: 'Correct answer! Next question! (+' + xp.to_s + 'XP x ' + xp_bonus.to_s + 'XP bonus = ' + (xp * xp_bonus).to_s + 'XP)'
          else
            redirect_to adventure_step_path, notice: 'Correct answer! Next question! (+' + xp.to_s + 'XP)'
          end
        end
      else
        redirect_to adventure_step_path, alert: 'Wrong answer!'
      end
    end


    def fight
      @user = User.find(session[:user_id])

      if @user.quest_in_progress != 0
        @quest_in_progress = Quest.find(@user.quest_in_progress)
        @current_step = @quest_in_progress.steps.find_by(step_order: @user.quest_step)
      end


      # ALGORITHM NPC ADAPTATION TO USER LEVEL, LIFE AND STRENGTH AND STEP
      @npclife = 10
      @npcstrength = 10

      #CALCUL DES STATS A AJOUTER AU NPC
      points = 0
      # CHAQUE LEVEL = +3 POINT
      points += @user.level * 3
      # VIE DU USER = +0.4% DE MA VIE EN POINT (arondie si c'est en virgule)
      points += (@user.life * 0.4).round
      # FORCE DU USER = +0.4% DE MA FORCE EN POINT (arondie si c'est en virgule)
      points += (@user.strength * 0.4).round
      # AJOUT des point total répartie aleatoirement entre les stats du NPC
      points.times do
        if rand(2) == 1
          @npclife += 3
        else
          @npcstrength += 1
        end
      end

      @userlife = @user.life
      @userstrength = @user.strength

      if @user.inventory
        @user.inventory.each do |key, item|
          if item["equipped"] == true
            @userlife += item["life"].to_i
            @userstrength += item["strength"].to_i
          end
        end
      end

      if session[:npclife].nil?
        session[:npclife] = @npclife
        session[:npcstrength] = @npcstrength
      end

      if session[:userlife].nil?
        session[:userlife] = @userlife
        session[:userstrength] = @userstrength
      end

      if session[:turn].nil?
        session[:turn] = "user"
      end
    end

    def attack
      @user = User.find(session[:user_id])
      xp_bonus = 1
      if @user.inventory
        @user.inventory.each do |key, item|
          if item["equipped"] == true
            xp_bonus += item["xp_bonus"].to_f
          end
        end
      end

      userstrength = session[:userstrength]
      npclife = session[:npclife]

      newnpclife = npclife -= userstrength

      session[:npclife] = newnpclife
      session[:turn] = "npc"

      @user = User.find(session[:user_id])

      if @user.quest_in_progress != 0
        @quest_in_progress = Quest.find(@user.quest_in_progress)
        @current_step = @quest_in_progress.steps.find_by(step_order: @user.quest_step)
      end

      if newnpclife <= 0
        @user.quest_step += 1
        xp = rand(@current_step.quest.experience * 0.25) + 1
        @user.experiences += xp
        @user.check_experience

        if @current_step == @quest_in_progress.steps.order(step_order: :desc).first
          @user.experiences += @quest_in_progress.experience * xp_bonus
          @user.check_experience
          @user.quest_in_progress = 0
          @user.quest_step = 0
          @user.quest_completeds.create(quest_id: @quest_in_progress.id)
          if(xp_bonus > 1)
            redirect_to congratulations_adventure_path, notice: 'You have won the fight! You have completed the quest! (+' + @quest_in_progress.experience.to_s + 'XP x ' + xp_bonus.to_s + 'XP bonus = ' + (@quest_in_progress.experience * xp_bonus).to_s + 'XP)'
          else
            redirect_to congratulations_adventure_path, notice: 'You have won the fight! You have completed the quest! (+' + @quest_in_progress.experience.to_s + 'XP)'
          end
        else
          if(xp_bonus > 1)
            redirect_to adventure_step_path, notice: 'You have won the fight! Next question! (+' + xp.to_s + 'XP x ' + xp_bonus.to_s + 'XP bonus = ' + (xp * xp_bonus).to_s + 'XP)'
          else
            redirect_to adventure_step_path, notice: 'You have won the fight! Next question! (+' + xp.to_s + 'XP)'
          end
        end

        session.delete(:npclife)
        session.delete(:npcstrength)
        session.delete(:userlife)
        session.delete(:userstrength)
        session.delete(:turn)

      else
        redirect_to adventure_fight_path
      end
      @user.save
    end

    def npc_attack
      userlife = session[:userlife]
      npcstrength = session[:npcstrength]

      randomstrength = rand(npcstrength * 0.7) + 1
      newuserlife = userlife -= randomstrength

      session[:userlife] = newuserlife
      session[:turn] = "user"

      @user = User.find(session[:user_id])

      if newuserlife <= 0
        @user.quest_step = 1
        @user.save
        session.delete(:npclife)
        session.delete(:npcstrength)
        session.delete(:userlife)
        session.delete(:userstrength)
        session.delete(:turn)
        redirect_to adventure_step_path, alert: 'You have lost the fight! You have to start the quest again!'
      else
        redirect_to adventure_fight_path
      end
    end
  end

  def congratulations
    @user = User.find(session[:user_id])
    @random_items = generate_random_items
  end

  def generate_random_items
    type = ["Sword", "Shield", "Helmet"]
    items = [
      { type: type.sample, strength: rand(1..10), life: rand(1..10), xp_bonus: rand(0.1..2.0).round(1), equipped: false },
      { type: type.sample, strength: rand(1..10), life: rand(1..10), xp_bonus: rand(0.1..2.0).round(1), equipped: false },
      { type: type.sample, strength: rand(1..10), life: rand(1..10), xp_bonus: rand(0.1..2.0).round(1), equipped: false }
    ]
    items.sample(3)
  end

  def add_item
    @user = User.find(session[:user_id])
    item = params[:item]
    if @user.inventory.empty?
      new_item_id = 1
    else
      new_item_id = @user.inventory.keys.map(&:to_i).max + 1
    end
    @user.inventory[new_item_id.to_s] = item
    @user.save
    redirect_to adventure_path, notice: 'Item added to your inventory!'
  end
end
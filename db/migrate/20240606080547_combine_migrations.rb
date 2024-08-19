class CombineMigrations < ActiveRecord::Migration[7.1]
  def change

    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.boolean :is_admin, default: false
      t.integer :experiences, default: 0
      t.integer :level, default: 1
      t.json :inventory, default: {}
      t.integer :life, default: 10
      t.integer :strength, default: 10
      t.integer :points, default: 10
      t.integer :used_points, default: 0
      t.integer :quest_in_progress, default: 0
      t.integer :quest_step, default: 0
    end

    create_table :quests do |t|
      t.string :name
      t.integer :experience
    end

    create_table :steps do |t|
      t.string :question
      t.string :answer
      t.string :fake_answer_1
      t.string :fake_answer_2
      t.string :fake_answer_3
      t.integer :quest_id
      t.integer :step_order
    end

    create_table :quest_completeds do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quest, null: false, foreign_key: true
    end

    User.create(name: "Admin", email: "admin@gmail.com", password: "test", is_admin: true, level: 1, points: 1000)
    User.create(name: "User", email: "test@gmail.com", password: "test")
    User.create(name: "User2", email: "test2@gmail.com", password: "test", level: 10, points: 40)
    User.create(name: "User3", email: "test3@gmail.com", password: "test", level: 20, points: 70)

    Quest.create(name: "Capitals", experience: 10)
    Quest.create(name: "Math", experience: 150)

    Step.create(question: "What is the capital of France?", answer: "Paris", fake_answer_1: "London", fake_answer_2: "Berlin", fake_answer_3: "Madrid", quest_id: 1, step_order: 1)
    Step.create(question: "What is the capital of Germany?", answer: "Berlin", fake_answer_1: "Paris", fake_answer_2: "London", fake_answer_3: "Madrid", quest_id: 1, step_order: 2)
    Step.create(question: "What is the capital of Spain?", answer: "Madrid", fake_answer_1: "Paris", fake_answer_2: "London", fake_answer_3: "Berlin", quest_id: 1, step_order: 3)
    Step.create(question: "What is 2 + 2?", answer: "4", fake_answer_1: "3", fake_answer_2: "5", fake_answer_3: "6", quest_id: 2, step_order: 1)
    Step.create(question: "What is 3 * 3?", answer: "9", fake_answer_1: "6", fake_answer_2: "12", fake_answer_3: "15", quest_id: 2, step_order: 2)
    Step.create(question: "What is 10 - 5?", answer: "5", fake_answer_1: "3", fake_answer_2: "7", fake_answer_3: "10", quest_id: 2, step_order: 3)
    Step.create(question: "What is 100 / 10?", answer: "10", fake_answer_1: "5", fake_answer_2: "15", fake_answer_3: "20", quest_id: 2, step_order: 4)
  end
end
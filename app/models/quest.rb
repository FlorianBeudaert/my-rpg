class Quest < ApplicationRecord
  has_many :steps
  has_many :quest_completeds
  has_many :completed_quests, through: :quest_completeds, source: :quest

  validates :name, presence: true
  validates :experience, presence: true
end

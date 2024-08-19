class User < ApplicationRecord
  has_many :quest_completeds
  has_many :completed_quests, through: :quest_completeds, source: :quest
  serialize :items, JSON
  has_secure_password
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def check_experience
    while self.experiences >= 100
      self.level += 1
      self.points += 3
      self.experiences -= 100
    end
    self.save if self.changed?
  end
end
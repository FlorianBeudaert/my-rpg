class Step < ApplicationRecord
  belongs_to :quest

  validates :question, presence: true
  validates :answer, presence: true
  validates :fake_answer_1, presence: true
  validates :fake_answer_2, presence: true
  validates :fake_answer_3, presence: true
  validates :quest_id, presence: true

  before_create :set_step_order

  private

  def set_step_order
    self.step_order = quest.steps.count + 1
  end
end

class Hostname < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  before_save :convert_name_to_lowercase

  private

  def convert_name_to_lowercase
    self.name = name.downcase
  end
end

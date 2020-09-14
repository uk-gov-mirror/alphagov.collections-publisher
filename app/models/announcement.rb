class Announcement < ApplicationRecord
  belongs_to :coronavirus_page
  validates :text, :href, presence: true
  validates :coronavirus_page, presence: true
  validate :published_at_format

  def published_at_format
    unless published_at.is_a?(Time)
      errors.add(:published_at, "must be a valid date")
    end
  end
end

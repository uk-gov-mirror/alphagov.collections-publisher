# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  slug        :string(255)      not null
#  title       :string(255)      not null
#  description :string(255)
#  parent_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#  content_id  :string(255)      not null
#  state       :string(255)      not null
#  dirty       :boolean          default(FALSE), not null
#
# Indexes
#
#  index_tags_on_slug_and_parent_id  (slug,parent_id) UNIQUE
#  tags_parent_id_fk                 (parent_id)
#

require 'securerandom'

class Tag < ActiveRecord::Base
  include AASM
  include ActiveModel::Dirty

  belongs_to :parent, class_name: 'Tag'
  has_many :children, class_name: 'Tag', foreign_key: :parent_id

  has_many :tag_associations, foreign_key: :from_tag_id
  has_many :reverse_tag_associations, foreign_key: :to_tag_id,
           class_name: "TagAssociation"

  validates :slug, :title, :content_id, presence: true
  validates :slug, uniqueness: { scope: ["parent_id"] }, format: { with: /\A[a-z0-9-]*\z/ }
  validate :parent_is_not_a_child
  validate :slug_change_once_published

  before_validation :generate_content_id, on: :create

  scope :only_parents, -> { where('parent_id IS NULL') }
  scope :only_children, -> { where('parent_id IS NOT NULL') }
  scope :in_alphabetical_order, -> { order('title ASC') }

  aasm column: :state, no_direct_assignment: true do
    state :draft, initial: true
    state :published

    event :publish do
      transitions from: :draft, to: :published
    end
  end

  def can_have_children?
    parent_id.blank?
  end

  def draft_children
    children.draft
  end

  def has_parent?
    parent.present?
  end

  def base_path
    base = has_parent? ? "/#{parent.slug}" : ''
    "#{base}/#{slug}"
  end

  def to_param
    content_id
  end

  def mark_as_dirty!
    update_columns(:dirty => true)
  end

  def mark_as_clean!
    update_columns(:dirty => false)
  end

private

  def parent_is_not_a_child
    if parent.present? && parent.parent_id.present?
      errors.add(:parent, 'is a child tag')
    end
  end

  def generate_content_id
    self.content_id ||= SecureRandom.uuid
  end

  def slug_change_once_published
    if slug_changed? && state == 'published'
      errors.add(:slug, 'cannot change a slug once published')
    end
  end
end

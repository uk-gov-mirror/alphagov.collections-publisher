class Coronavirus::SubSection < ApplicationRecord
  HEADER_PATTERN = PatternMaker.call(
    "starts_with hashes then perhaps_spaces then capture(title) and nothing_else",
    hashes: "#+",
    title: '\w.+',
  )

  LINK_PATTERN = PatternMaker.call(
    "starts_with perhaps_spaces within(sq_brackets,capture(label)) then perhaps_spaces and within(brackets,capture(url))",
    label: '\s*\w.+',
    url: '\s*(\b(https?)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]\s*',
  )

  self.table_name = "coronavirus_sub_sections"

  belongs_to :page, foreign_key: "coronavirus_page_id"
  validates :title, :content, presence: true
  validates :page, presence: true
  validate :content_is_valid
  validate :featured_link_must_be_in_content

  def featured_link_must_be_in_content
    if featured_link.present? && !content.include?(featured_link)
      errors.add(:featured_link, "does not exist in accordion content")
    end
  end

  def content_is_valid
    if content
      content.lines.each do |line|
        unless is_header_or_link?(line)
          errors.add(:content, "Unable to parse markdown: #{line}")
        end
      end
    end
  end

  def is_header_or_link?(text)
    HEADER_PATTERN =~ text || LINK_PATTERN =~ text
  end
end

require "rails_helper"

RSpec.describe Announcement, type: :model do
  let(:announcement) { create :announcement }

  describe "validations" do
    it "should belong to a coronavirus_page" do
      should validate_presence_of(:coronavirus_page)
    end

    it "fails if coronavirus_page does not exist" do
      announcement.coronavirus_page = nil

      expect(announcement).not_to be_valid
    end

    it "is created with valid attributes" do
      expect(announcement).to be_valid
      expect(announcement.save).to eql true
      expect(announcement).to be_persisted
    end

    it "requires text" do
      announcement.text = ""

      expect(announcement).not_to be_valid
      expect(announcement.errors).to have_key(:text)
    end

    it "requires an href" do
      announcement.href = ""

      expect(announcement).not_to be_valid
      expect(announcement.errors).to have_key(:href)
    end

    it "requires a published at time" do
      announcement.published_at = ""

      expect(announcement).not_to be_valid
      expect(announcement.errors).to have_key(:published_at)
    end
  end

  describe "position" do
    it "should default to position 1 if it is the first announcement to have been added" do
      coronavirus_page = create(:coronavirus_page)
      expect(coronavirus_page.announcements.count).to eq 0

      announcement = create(:announcement, coronavirus_page: coronavirus_page)
      expect(announcement.position).to eq 1
    end

    it "should increment if there are existing announcements" do
      coronavirus_page = create(:coronavirus_page)
      create(:announcement, coronavirus_page: coronavirus_page)
      expect(coronavirus_page.announcements.count).to eq 1

      announcement = create(:announcement, coronavirus_page: coronavirus_page)
      expect(announcement.position).to eq 2
    end
  end
end

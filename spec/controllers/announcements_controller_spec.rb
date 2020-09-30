require "rails_helper"

RSpec.describe AnnouncementsController, type: :controller do
  render_views

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :of_known_type }
  let(:slug) { coronavirus_page.slug }
  let(:announcement) { create :announcement, coronavirus_page: coronavirus_page }
  let!(:live_stream) { create :live_stream, :without_validations }
  let(:text) { Faker::Lorem.sentence }
  let(:href) { Faker::Internet.url(host: "example.com") }
  let(:published_at) { { "day" => "12", "month" => "12", "year" => "1980" } }
  let(:announcement_params) do
    {
      text: text,
      href: href,
      published_at: published_at,
    }
  end
  let(:invalid_announcement_params) do
    {
      text: "",
      href: href,
      published_at: published_at,
    }
  end
  let(:raw_content_url) { coronavirus_page.raw_content_url }
  let(:raw_content_url_regex) { Regexp.new(raw_content_url) }
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }
  let(:raw_content) { File.read(fixture_path) }

  describe "GET /coronavirus/:coronavirus_page_slug/announcements/new" do
    before do
      stub_user.permissions << "Unreleased feature"
    end
    it "renders successfully" do
      get :new, params: { coronavirus_page_slug: slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /coronavirus/:coronavirus_page_slug/announcements" do
    before do
      stub_user.permissions << "Unreleased feature"
    end
    before do
      stub_request(:get, raw_content_url_regex)
        .to_return(body: raw_content)
      stub_coronavirus_publishing_api
      live_stream
    end

    it "redirects to coronavirus page on success" do
      post :create, params: { coronavirus_page_slug: slug, announcement: announcement_params }
      expect(subject).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
      expect(flash.now[:errors]).to be_nil
    end

    it "adds attributes to new announcement" do
      post :create, params: { coronavirus_page_slug: slug, announcement: announcement_params }
      published_at_time = Time.zone.local(published_at["year"], published_at["month"], published_at["day"])
      announcement = Announcement.last
      expect(announcement.text).to eq(text)
      expect(announcement.href).to eq(href)
      expect(announcement.published_at).to eq(published_at_time)
    end

    it "does not create an announcement with blank text" do
      post :create, params: { coronavirus_page_slug: slug, announcement: invalid_announcement_params }
      expect(subject).not_to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end
  end

  describe "GET /coronavirus/:coronavirus_page_slug/announcements/:id/edit" do
    before do
      stub_user.permissions << "Unreleased feature"
    end
    it "renders successfully" do
      get :edit, params: { id: announcement, coronavirus_page_slug: slug }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /coronavirus/:coronavirus_page_slug/announcement" do
    before do
      stub_user.permissions << "Unreleased feature"
      stub_request(:get, raw_content_url_regex)
        .to_return(body: raw_content)
      stub_coronavirus_publishing_api
      live_stream
    end
    let(:params) do
      {
        id: announcement,
        coronavirus_page_slug: slug,
        announcement: announcement_params,
      }
    end

    subject { patch :update, params: params }
    
    it "redirects to coronavirus page on success" do
      expect(subject).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end

    it "updates the announcements" do
      announcement
      expect { subject }.not_to(change { Announcement.count })
    end

    it "changes the attributes of the announcement" do
      subject
      published_at_time = Time.zone.local(published_at["year"], published_at["month"], published_at["day"])
      announcement.reload
      expect(announcement.text).to eq(text)
      expect(announcement.href).to eq(href)
      expect(announcement.published_at).to eq(published_at_time)
    end
  end

  describe "DELETE /coronavirus/:coronavirus_page_slug/announcement/:id" do
    before do
      stub_user.permissions << "Unreleased feature"
      stub_request(:get, raw_content_url_regex)
        .to_return(body: raw_content)
      stub_coronavirus_publishing_api
    end
    let(:params) do
      {
        id: announcement,
        coronavirus_page_slug: slug,
        announcement: announcement_params,
      }
    end
    subject { delete :destroy, params: params }

    it "redirects to the coronavirus page on success" do
      expect(subject).to redirect_to(coronavirus_page_path(coronavirus_page.slug))
    end

    it "deletes the announcement" do
      announcement
      expect { subject }.to change { Announcement.count }.by(-1)
    end
  end
end

require "rails_helper"

RSpec.describe CoronavirusPagesController, type: :controller do
  render_views

  let(:stub_user) { create :user, :coronovirus_editor, name: "Name Surname" }
  let(:coronavirus_page) { create :coronavirus_page, :of_known_type }
  let!(:live_stream) { create :live_stream, :without_validations }
  let(:slug) { coronavirus_page.slug }
  let(:raw_content_url) { CoronavirusPages::Configuration.page(slug)[:raw_content_url] }
  let(:raw_content_url_regex) { Regexp.new(raw_content_url) }
  let(:all_content_urls) do
    CoronavirusPages::Configuration.all_pages.map do |config|
      config.second[:raw_content_url]
    end
  end
  let(:raw_content) { File.read(fixture_path) }
  let(:stub_all_content_urls) do
    all_content_urls.each do |url|
      stub_request(:get, Regexp.new(url))
        .to_return(status: 200, body: raw_content)
    end
  end
  let(:fixture_path) { Rails.root.join "spec/fixtures/coronavirus_landing_page.yml" }

  describe "GET /coronavirus" do
    it "renders page successfully" do
      stub_all_content_urls
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /coronavirus/:slug/prepare" do
    subject { get :prepare, params: { slug: slug } }
    it "renders page successfuly" do
      stub_request(:get, raw_content_url_regex)
        .to_return(status: 200)
      expect(subject).to have_http_status(:success)
    end

    it "does not create a new coronavirus page" do
      coronavirus_page # ensure any creation during initialization doesn't get counted
      expect { subject }.not_to(change { CoronavirusPage.count })
    end

    context "with unknown slug" do
      let(:slug) { :unknown }
      it "redirects to index" do
        expect(subject).to redirect_to(coronavirus_pages_path)
      end
    end

    context "with a new known coronavirus page" do
      let(:coronavirus_page) { build :coronavirus_page, :of_known_type }

      it "renders page successfuly" do
        stub_request(:get, raw_content_url_regex)
          .to_return(status: 200, body: raw_content)
        expect(subject).to have_http_status(:success)
      end

      it "creates a new coronavirus page" do
        stub_request(:get, raw_content_url_regex)
          .to_return(status: 200, body: raw_content)
        coronavirus_page # ensure any creation during initialization doesn't get counted
        expect { subject }.to (change { CoronavirusPage.count }).by(1)
      end
    end
  end

  describe "GET /coronavirus/:slug" do
    before do
      stub_user.permissions << "Unreleased feature"
    end

    it "renders page successfuly" do
      get :show, params: { slug: coronavirus_page.slug }
      expect(response).to have_http_status(:success)
    end

    it "redirects to index with an unknown slug" do
      get :show, params: { slug: "unknown" }
      expect(response).to redirect_to(coronavirus_pages_path)
    end
  end

  describe "GET /coronavirus/:coronavirus_page_slug/reorder" do
    before do
      stub_user.permissions << "Unreleased feature"
    end

    it "renders page successfuly" do
      get :reorder, params: { slug: coronavirus_page.slug }
      expect(response).to have_http_status(:success)
    end
  end
end

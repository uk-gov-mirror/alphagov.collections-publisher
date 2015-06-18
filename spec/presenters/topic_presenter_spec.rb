require 'rails_helper'

RSpec.describe TopicPresenter do
  describe "rendering for publishing-api" do
    context "for a top-level topic" do
      let(:topic) {
        create(:topic, {
          :slug => 'working-at-sea',
          :title => 'Working at sea',
          :description => 'The sea, the sky, the sea, the sky...',
        })
      }
      let(:presenter) { TopicPresenter.new(topic) }
      let(:presented_data) { presenter.render_for_publishing_api }

      it "includes the base fields" do
        expect(presented_data).to include({
          :content_id => topic.content_id,
          :format => 'topic',
          :title => 'Working at sea',
          :description => 'The sea, the sky, the sea, the sky...',
          :locale => 'en',
          :need_ids => [],
          :publishing_app => 'collections-publisher',
          :rendering_app => 'collections',
          :redirects => [],
          :update_type => "major",
        })
      end

      it "is valid against the schema", :schema_test => true do
        expect(presented_data).to be_valid_against_schema('topic')
      end

      it "returns the base_path for the topic" do
        expect(presenter.base_path).to eq("/working-at-sea")
      end

      it "sets public_updated_at based on the topic update time" do
        the_past = 3.hours.ago
        Timecop.freeze the_past do
          topic.touch
        end
        expect(presented_data[:public_updated_at]).to eq(the_past.iso8601)
      end

      it "includes the base route" do
        expect(presented_data[:routes]).to eq([
          {:path => "/working-at-sea", :type => "exact"},
        ])
      end

      it "has no links" do
        expect(presented_data[:links]).to eq({})
      end
    end

    context "for a subtopic" do
      let(:parent) { create(:topic, :slug => 'oil-and-gas') }
      let(:topic) {
        create(:topic, {
          :parent => parent,
          :slug => 'offshore',
          :title => 'Offshore',
          :description => 'Oil rigs, pipelines etc.',
        })
      }
      let(:presenter) { TopicPresenter.new(topic) }
      let(:presented_data) { presenter.render_for_publishing_api }

      it "returns the base_path for the subtopic" do
        expect(presenter.base_path).to eq("/oil-and-gas/offshore")
      end

      it "includes the base fields" do
        expect(presented_data).to include({
          :content_id => topic.content_id,
          :format => 'topic',
          :title => 'Offshore',
          :description => 'Oil rigs, pipelines etc.',
          :locale => 'en',
          :need_ids => [],
          :publishing_app => 'collections-publisher',
          :rendering_app => 'collections',
          :redirects => [],
          :update_type => "major",
        })
      end

      it "is valid against the schema", :schema_test => true do
        expect(presented_data).to be_valid_against_schema('topic')
      end

      it "sets public_updated_at based on the topic update time" do
        the_past = 3.hours.ago
        Timecop.freeze the_past do
          topic.touch
        end
        expect(presented_data[:public_updated_at]).to eq(the_past.iso8601)
      end

      it "includes routes for latest, and email_signups in addition to base route" do
        expect(presented_data[:routes]).to eq([
          {:path => "/oil-and-gas/offshore", :type => "exact"},
          {:path => "/oil-and-gas/offshore/latest", :type => "exact"},
          {:path => "/oil-and-gas/offshore/email-signup", :type => "exact"},
        ])
      end

      it "includes a link to its parent" do
        expect(presented_data[:links]).to have_key("parent")
        expect(presented_data[:links]["parent"]).to eq([parent.content_id])
      end
    end
  end
end

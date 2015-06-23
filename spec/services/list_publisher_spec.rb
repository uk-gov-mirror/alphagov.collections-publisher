require "rails_helper"

RSpec.describe ListPublisher do
  describe '#perform' do
    before { allow(PublishingAPINotifier).to receive(:send_to_publishing_api) }

    it 'updates the groups-data to be sent to the content store' do
      topic = create(:topic)
      create(:list, name: 'A Listname', tag: topic)

      ListPublisher.new(topic).perform

      expect(topic.published_groups).to eql([{"name"=>"A Listname", "contents"=>[]}])
    end

    it 'sends the updated information to the content-store' do
      topic = create(:topic)

      ListPublisher.new(topic).perform

      expect(PublishingAPINotifier).to have_received(:send_to_publishing_api)
    end
  end
end

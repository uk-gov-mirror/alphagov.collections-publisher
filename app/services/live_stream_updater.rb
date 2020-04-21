class LiveStreamUpdater
  CORONAVIRUS_PAGE_CONTENT_ID = "774cee22-d896-44c1-a611-e3109cce8eae".freeze

  attr_reader :errors

  def initialize(object, state = nil)
    @object = object
    @state = state
    @content_item = fetch_live_content_item
    @errors = []
  end

  def update
    update_object_and_content_item.try(:code) == 200
  end

  def publish
    publish_content_item.try(:code) == 200
  end

  def resync
    states_in_sync? ? object : object.toggle(:state)
  end

private

  attr_reader :state, :live_stream, :content_item
  attr_accessor :object

  def states_in_sync?
    live_state == object.state
  end

  def live_state
    content_item["details"]["live_stream_enabled"]
  end

  def update_object_and_content_item
    if object.update(state: state)
      update_content_item
    end
  end

  def update_content_item
    begin
      Services.publishing_api.put_content(CORONAVIRUS_PAGE_CONTENT_ID, live_stream_payload)
    rescue GdsApi::HTTPErrorResponse => e
      errors << "There was a problem updating the livestream (error: #{e.code} - #{e.message})"
      object.toggle(:state)
    end
  end

  def publish_content_item
    begin
      Services.publishing_api.publish(CORONAVIRUS_PAGE_CONTENT_ID, "minor")
    rescue GdsApi::HTTPErrorResponse => e
      errors << "There was a problem publishing the livestream change (error: #{e.code} - #{e.message})"
      object.toggle(:state)
    end
  end

  def fetch_live_content_item
    content = Services.publishing_api.get_content(CORONAVIRUS_PAGE_CONTENT_ID)
    JSON.parse(content.raw_response_body)
  end

  def presenter
    CoronavirusPagePresenter.new(content_item["details"], "/coronavirus")
  end

  def live_stream_payload
    presenter.payload.merge(
      {
        "title" => "Coronavirus (COVID-19): what you need to do",
        "description" => content_item["description"],
      },
    )
  end
end

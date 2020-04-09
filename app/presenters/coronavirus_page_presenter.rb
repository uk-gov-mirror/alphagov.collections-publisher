class CoronavirusPagePresenter
  attr_reader :description, :details, :title, :path

  def initialize(corona_content, path)
    @title = corona_content.delete("title")
    @description = corona_content.delete("meta_description")
    @details = corona_content
    @path = path
  end

  def payload
    {
      "base_path" => path,
      "title" => title,
      "description" => description,
      "document_type" => "coronavirus_landing_page",
      "schema_name" => "coronavirus_landing_page",
      "details" => details["live_stream"].merge(live_stream_state),
      "links" => {},
      "locale" => "en",
      "rendering_app" => "collections",
      "publishing_app" => "collections-publisher",
      "routes" => [{ "path" => path, "type" => "exact" }],
      "update_type" => "minor",
    }
  end

  def live_stream_state
    {
      "live_stream" => {
        "show_video" => LiveStream.last.state,
      },
     }
  end
end

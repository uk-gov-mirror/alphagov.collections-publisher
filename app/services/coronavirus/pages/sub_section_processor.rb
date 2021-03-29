module Coronavirus::Pages
  class SubSectionProcessor
    def self.call(*args)
      new(*args).output
    end

    attr_reader :sub_sections, :action_link

    def initialize(sub_sections)
      @sub_sections = [sub_sections].flatten
      @action_link = { url: nil, content: nil, summary: nil }.with_indifferent_access
    end

    def output
      process
      {
        content: output_array.join("\n"),
        action_link_url: action_link[:url],
        action_link_content: action_link[:content],
        action_link_summary: action_link[:summary],
      }
    end

    def output_array
      @output_array ||= []
    end

    def add_string(text)
      output_array << text
    end

    def add_action_link(item)
      key_map = { url: :url, label: :content, description: :summary }.with_indifferent_access
      item.map do |key, value|
        action_link[key_map[key]] = value unless key_map[key].nil?
      end
    end

    def process
      sub_sections.each do |sub_section|
        add_string("####{sub_section['title']}") if sub_section["title"].present?
        sub_section["list"].each do |item|
          if item["featured_link"]
            add_action_link(item)
          else
            add_string "[#{item['label']}](#{remove_priority_taxon_param(item['url'])})"
          end
        end
      end
    end

    def remove_priority_taxon_param(url)
      uri = Addressable::URI.parse(url)
      uri.query_values = uri.query_values&.except("priority-taxon")
      uri.normalize.to_s
    end
  end
end

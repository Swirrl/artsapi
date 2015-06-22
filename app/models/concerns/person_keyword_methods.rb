require 'memoist'
module PersonKeywordMethods

  extend ActiveSupport::Concern
  extend Memoist

  def get_or_generate_subject_area!
    return self.subject_area if !self.subject_area.blank?
    get_subject_area!
  end

  # points to resources of the KeywordCategory class 
  # and contains KeywordSubCategor(ies)
  # if nothing exists in that field, it will write after calculating
  def get_subject_area!(opts={})
    save_functional_areas = opts.fetch(:save_functional_areas, true)
    save_categories = opts.fetch(:save_categories, true)
    bin_threshold = opts.fetch(:bin_threshold, 2)

    begin
      # get sorted keywords
      weighted_keywords = self.sorted_keywords

      # work out which are actually important
      highest_val = weighted_keywords.first[1].to_i
      lowest_val = weighted_keywords.last[1].to_i # will probably be 1
      bin_size = (highest_val - lowest_val) / 10

      cutoff_value = lowest_val + (bin_threshold * bin_size)

      remaining_keywords = weighted_keywords.map { |kw| kw if kw[1].to_i > cutoff_value }.compact

      category_counter = {}

      # hydrate, hydrate and hydrate some more
      # each item structure is now:
      # [keyword_object, occurrences, containing_category]
      remaining_keywords.each do |kw|
        keyword_object = Keyword.hydrate_from_label(kw[0])
        kw[0] = keyword_object

        category_uri = keyword_object.get_category.to_s
        kw << category_uri

        # while we're at it, save this functional area
        # as it's over the threshold of interestingness
        self.functional_area = self.functional_area + [keyword_object.in_sub_category] if save_functional_areas

        if category_counter.has_key?(category_uri)
          category_counter[category_uri] = category_counter[category_uri] + kw[1].to_i
        else
          category_counter[category_uri] = kw[1].to_i
        end
      end

      # suss out which keyword category contains the most resources
      category_uris = category_counter.sort { |a, b| b[1] <=> a[1] }

      categories = category_uris[0..2].map { |c| c[0] }
      self.subject_area = categories
      self.save if save_categories # save functional areas and category

      categories
    rescue
      # need to decide what to do here - some people will have no keywords
    end
  end

  def all_keywords_from_emails
    kw_hash = {}

    self.mentioned_keywords.each do |keyword|
      kw = keyword.to_s

      query = Tripod::SparqlQuery.new("
        #{Person.query_prefixes}
        SELECT ?email
        WHERE {
          GRAPH <http://data.artsapi.com/graph/emails> {
            ?email arts:emailSender <#{self.uri.to_s}> .
            ?email arts:containsKeyword <#{kw}> .
          }
        }
      ")

      mentions = User.current_user.within {
        Tripod::SparqlClient::Query.select(query.as_count_query_str)[0]["tripod_count_var"]["value"].to_i
      }

      label = Keyword.label_from_uri(kw)
      kw_hash[kw] = [label, mentions]
    end

    kw_hash
  end

  def sorted_keywords
    sorted = []
    ak = all_keywords_from_emails
    ak.sort { |a, b| ak[b[0]][1] <=> ak[a[0]][1] }.each { |h| sorted << [ak[h[0]][0], ak[h[0]][1]] }
    sorted
  end

  # for debug and partner feedback; not for production use!
  def print_sorted_keywords
    puts "#{self.name.titleize}: #{self.uri}\n\n"
    sorted_keywords.each { |a| puts "'#{a[0]}' mentions: #{a[1]}"}
  end

end
require 'csv'

module D3

  extend ActiveSupport::Concern

  class ConnectionsChart

    attr_accessor :csv, :sorted_email_density, :data

    def initialize(person)
      self.csv = []
      self.data = {}
      self.sorted_email_density = person.sorted_email_density

      assemble_data!
      assemble_csv!
    end

    # probably need to organise this into bins
    def assemble_data!
      self.sorted_email_density.each do |uri, value|
        if data.has_key?(value)
          data[value] = data[value] + 1
        else
          data[value] = 1
        end
      end
    end

    def assemble_csv!
      self.csv = ::CSV.generate do |csv|
        csv << ["occurrences", "emails"]

        self.data.each do |emails, occurrences|

          csv << [occurrences, emails]

        end
      end
    end
  end

end
require 'csv'

module Exports

  extend ActiveSupport::Concern

  def self.assemble_person_list_csv
    all_person_uris = Person.all_uris

    # avoid looking up organisations repeatedly
    organisation_hash = {}

    person_list = ::CSV.generate do |csv|

      # csv header
      csv << ["Person", "Sector", "City", "Country"]

      # blast through unhydrated list
      all_person_uris.each do |uri|
        p = Person.find(uri)

        # make sure we show something identifiable
        name_or_email = (p.human_name == 'No Name Available') ? p.mbox.downcase : p.human_name

        # sector or empty cell
        sector = p.works_in_sector rescue ""

        org_uri = p.member_of.to_s

        # avoid a db lookup if possible
        if organisation_hash.has_key?(org_uri)
          city = organisation_hash[org_uri][:city]
          country = organisation_hash[org_uri][:country]
        else
          city = p.parent_org_city || ""
          country = p.parent_org_country || ""

          # add to the hash
          organisation_hash[org_uri] = {
            city: city,
            country: country
          }
        end

        csv << [
          p.human_name,
          sector,
          city,
          country
        ]
      end
    end

    person_list
  end

  def self.assemble_person_matrix_csv
    all_person_uris = Person.all_uris_and_emails
    all_person_hash = {}
    all_person_uris.each { |i| all_person_hash[i[0]] = i[1] }

    # knock out the emails
    all_person_uris = all_person_uris.map { |i| i[0] }

    csv = ::CSV.generate do |csv|
      first_row = ["Person"]

      all_person_uris.each do |row_uri|
        first_row << all_person_hash[row_uri]
      end

      csv << first_row

      all_person_uris.each do |row_uri| # row
        row = [all_person_hash[row_uri]]

        all_person_uris.each do |col_uri| # column
          row << Person.total_emails_between(row_uri, col_uri)
        end

        csv << row
      end
    end

    csv
  end

end

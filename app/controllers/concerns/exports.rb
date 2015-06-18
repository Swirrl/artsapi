# encoding: utf-8
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
          name_or_email,
          sector,
          city,
          country
        ]
      end
    end

    person_list
  end

  def self.dump_people_as_csv
    all_person_uris = Person.all_uris

    # avoid looking up organisations repeatedly
    organisation_hash = {}

    person_list = ::CSV.generate do |csv|

      # csv header
      csv << [
        "URI",
        "Label",
        "Human Readable Name",
        "Name",
        "Email",
        "Number of Connections",
        "Position",
        "Subject Area",
        "Number of Sent Emails",
        "Number of Received Emails",
        "Organisation Name",
        "Organisation URI",
        "Sector",
        "City",
        "Country"
      ]

      # blast through unhydrated list
      all_person_uris.each do |uri|
        p = Person.find(uri)

        label = p.label || ""
        human_name = p.human_name
        name = p.name.first
        email = p.mbox
        connections = p.get_or_write_connections!.count rescue ""
        position = p.position || ""
        subject_area = p.get_or_generate_subject_area! rescue ""
        sent_emails = p.number_of_sent_emails
        received_emails = p.number_of_incoming_emails
        org_uri = p.member_of.to_s

        # sector or empty cell
        sector = p.works_in_sector rescue ""

        # avoid a db lookup if possible
        if organisation_hash.has_key?(org_uri)
          city = organisation_hash[org_uri][:city]
          country = organisation_hash[org_uri][:country]
          org_name = organisation_hash[org_uri][:name]
        else
          city = p.parent_org_city || ""
          country = p.parent_org_country || ""
          org_name = p.parent_organisation.label || ""

          # add to the hash
          organisation_hash[org_uri] = {
            city: city,
            country: country,
            name: org_name
          }
        end

        csv << [
          uri,
          label,
          human_name,
          name,
          email,
          connections,
          position,
          subject_area,
          sent_emails,
          received_emails,
          org_name,
          org_uri,
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

    # knock out the emails, de-dupe to avoid esoteric issue
    # of .mbox being multivalued from the point of view of 
    # raw sparql queries vs tripod as it is case sensitive
    # and grafter does not (as of 17/6) downcase emails by default
    all_person_uris = all_person_uris.map { |i| i[0] }.uniq
    total_count = all_person_uris.count

    csv = ::CSV.generate do |csv|
      first_row = ["Person"]

      all_person_uris.each do |row_uri|
        first_row << all_person_hash[row_uri]
      end

      csv << first_row

      progress = 1
      starting_time = Time.now

      all_person_uris.each do |row_uri| # row
        row = [all_person_hash[row_uri]]

        # populate the row; we will use .index to populate later
        total_count.times { row << "" }

        # structured as [uri, count]
        keyword_counts = Person.find(row_uri).calculate_email_density

        # go through and inject in the values we want
        keyword_counts.each do |uri, count|
          index = all_person_uris.index(uri)

          # row is one element longer than the all_person_uris array
          row[(index + 1)] = count
        end

        current_time = Time.now
        Rails.logger.debug "> [Matrix Export]#{row_uri} processed.\n  #{progress} of #{total_count} People processed for export. #{(total_count - progress)} People left. \n  #{(current_time - starting_time)} seconds elapsed.\n\n"
        progress += 1

        csv << row
      end
    end

    csv
  end

  # create a tempfile and upload it to the root 
  # of the initiating user's dropbox
  def self.create_tempfile_and_upload!(file_contents, export_type)
    hash = Digest::MD5.new.to_s
    file_name_and_location = "/#{export_type}_#{DateTime.now.to_s.dasherize.gsub(/T/, 'TIME').gsub(/\:/, "_").gsub(/\+/, 'PLUS')}.csv"

    encoding = "utf-8"
    file = Tempfile.new([hash, '.csv'], encoding: encoding)

    begin
      file.write(file_contents)
      file.close

      Rails.logger.debug "> [Exports] File path: #{file.path}"
      Rails.logger.debug "> [Exports] Uploading to Dropbox..."

      upload_client = UploadClient.new
      response = upload_client.upload_to_dropbox!(file_name_and_location, file)

      Rails.logger.debug "> [Exports] Complete.\n  Uploaded #{response["size"]} to #{response["path"]} at #{response["modified"]}."
    ensure
      file.unlink
    end
  end

end

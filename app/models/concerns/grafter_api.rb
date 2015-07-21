# encoding: utf-8
module GrafterAPI

  extend ActiveSupport::Concern

  # Creates a tempfile and Grafter will have a crack at uploading it
  def self.send_to_grafter!(contents, mine_keywords)
    hash = Digest::MD5.new.to_s

    Rails.logger.debug "> [GrafterAPI] Encoding: #{contents.encoding}"
    encoding = contents.encoding
    file = Tempfile.new([hash, '.mbox'], encoding: encoding)

    begin
      file.write(contents)
      file.close

      Rails.logger.debug "> [GrafterAPI] File path: #{file.path}"
      Rails.logger.debug "> [GrafterAPI] Grafting..."

      # Okay, this is gnarly. I am genuinely sorry about that
      User.current_user.within {
        `cd #{ArtsAPI.grafter_location}; java -jar artsapi-graft-standalone.jar #{file.path} #{Tripod.query_endpoint} #{Tripod.update_endpoint} #{'no-convert' unless mine_keywords}`
      }

      Rails.logger.debug "> [GrafterAPI] Grafted."
    ensure
      file.unlink
    end
  end

  class ImportError < StandardError; end

end
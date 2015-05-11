module GrafterAPI

  extend ActiveSupport::Concern

  # Creates a tempfile and Grafter will have a crack at uploading it
  def self.send_to_grafter!(contents)
    hash = Digest::MD5.new.to_s
    filename = "/artsapi/tmp/#{hash}.mbox"
    file = Tempfile.new(filename)
    file.write(contents)

    # Okay, this is gnarly. I am genuinely sorry about that
    User.current_user.set_tripod_endpoints!
    if Rails.env.production?
      `cd /artsapi-email-processing-tool; lein run #{filename} #{Tripod.query_endpoint} #{Tripod.update_endpoint}`
    else
      `cd ~/grafter; lein run #{filename} #{Tripod.query_endpoint} #{Tripod.update_endpoint}`
    end

    file.close
    file.unlink
  end

end
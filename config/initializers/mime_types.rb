# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
MIME::Types.add(
  MIME::Type.new('application/n-triples') do |t|
    t.extensions  = ['nt']
  end
)
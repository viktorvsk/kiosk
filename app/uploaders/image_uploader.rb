class ImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  storage :fog
  #sprocess convert: :png

  process quality: 85
  process :watermark, if: :watermarkable?


  # Create different versions of your uploaded files:
  # version :large do
  #   process resize_to_fit: [200, 200]
  # end
  # version :medium do
  #   process resize_to_fit: [80, 80]
  # end
  # version :thumb do
  #   process resize_to_fit: [35, 35]
  # end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{model.imageable.class.to_s.underscore}"
  end

  def cache_dir
    Rails.root.join('tmp','uploads')
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
   'missing.png'
  end

  def extension_white_list
   %w(jpg jpeg gif png)
  end

  def full_original_filename
    filename = super
    return filename if filename.blank?

    extension = File.extname(filename)
    basename = File.basename(filename, extension)[0...240]
    basename + extension
  end


  def filename
    if original_filename
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}.#{file.extension}"
    end
  end

  def watermark
    manipulate! do |img|
      logo = MiniMagick::Image.open("#{Rails.root}/public/logo_min.png")
      img = img.composite(logo) do |i|
        i.gravity 'southeast'
        i.geometry '+15+0'
      end
    end
  end

  protected

  def watermarkable?(new_file)
    model.imageable_type == 'Catalog::Product'
  end

end

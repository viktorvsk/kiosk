module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end

CarrierWave.configure do |config|
  config.sftp_host = Figaro.env.carrierwave_sftp_host
  config.sftp_user = Figaro.env.carrierwave_sftp_user
  config.sftp_folder = Figaro.env.carrierwave_sftp_folder
  config.sftp_url = Figaro.env.carrierwave_sftp_url
  config.sftp_options = {
    :password => Figaro.env.carrierwave_sftp_password,
    :port     => Figaro.env.carrierwave_sftp_port
  }
end

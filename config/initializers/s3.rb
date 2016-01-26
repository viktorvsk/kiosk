CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => Figaro.env.aws_access_key_id,
      :aws_secret_access_key  => Figaro.env.aws_secret_access_key,
      :region                 => Figaro.env.aws_region
  }
  config.fog_directory  = Figaro.env.aws_bucket
end

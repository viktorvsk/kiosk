# TODO: hardcoded app name
class BackupDb
  @queue = :common

  def self.perform
    username = Rails.application.config.database_configuration[Rails.env]['username']
    dbname = Rails.application.config.database_configuration[Rails.env]['database']
    pass = Rails.application.config.database_configuration[Rails.env]['password']
    `PGPASSWORD=#{pass} pg_dump -U #{username} #{dbname} --no-owner -f ${HOME}/kiosk/shared/backups/$(date +"%Y%m%d%H%M").backup.sql`
    `find ${HOME}/kiosk/shared/backups/ -type f -mtime +2 -delete`
  end
end

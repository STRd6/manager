class DeployWorker
  include Sidekiq::Worker

  def perform(app)
    cmd = "APP=\"#{app}\" scripts/deploy 2>&1"
    logger.info cmd
    logger.info `#{cmd}`
  end
end

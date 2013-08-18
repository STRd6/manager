class DeployWorker
  include Sidekiq::Worker

  def perform(app)
    `APP="#{app}" scripts/deploy`
  end
end

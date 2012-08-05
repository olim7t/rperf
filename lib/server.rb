class Server
  class << self
    attr_reader :subclasses
  end

  @subclasses = []

  def self.inherited(subclass)
    Server.subclasses << subclass
  end

  def self.for_platform(platform)
    server_class = Server.subclasses.find do |klass|
      klass.name == platform.capitalize + "Server"
    end
  end
end



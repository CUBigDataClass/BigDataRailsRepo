class BDElasticSearch

  # Statics

  def self.all
    shared_instace.search q: class.name
  end

  # Instance methods

  def initialize(hash)
    @data = hash
  end

  def create(index, type, id, doc)
    client.create format_document(index, type, id, doc)
  end

  # Perform all actions syncroniously
  def perform_in_bulk(actions)
    queue_bulk_actions actions
    exec_bulk_queue
  end

  # Used to queue actions to be executed at a later time
  def queue_bulk_actions(actions[])
    exec_bulk_queue
  end

  # Pass along all available methods to the client object
  def method_missing(method, *args, &block)
    if client.respond_to?(method)
      client.send method, *args, &block
    else
      super
    end
  end

  private

  def client; @client ||= Elasticsearch::Client.new log: true; end

  # Formats a document to be indexed
  def format_document(index, type, id, doc)
    {
      index: index,
      type: type,
      id: id.to_s,
      body: doc
    }
  end

  def exec_bulk_queue
    client.bulk body: bulk_action_queue
    clear_bulk_queue
  end

  def clear_bulk_queue
    bulk_action_queue = []
  end

  def bulk_action_queue=(arr)
    @bulk_action_queue = arr
  end

  def bulk_action_queue
    @bulk_action_queue ||= []
    @bulk_action_queue
  end

  def self.shared_instance
    new
  end
end

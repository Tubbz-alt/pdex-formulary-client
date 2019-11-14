class ClientConnections

    @clients = Hash.new

    def self.set(id, url)
        begin
            client = FHIR::Client.new(url)
            client.use_r4
            FHIR::Model.client = client
            profile = "http://hl7.org/fhir/us/Davinci-drug-formulary/StructureDefinition/usdf-FormularyDrug"
            search = { parameters: { _profile: profile, _summary: "count" } }
            count = client.search(FHIR::MedicationKnowledge, search: search ).resource.total
            raise "No FormularyDrugs in server" unless count > 0
        rescue
            return nil
        end
        @clients[id] = Hash.new
        prune(id)
        @clients[id][:client] = client
    end

    def self.get(id)
        return nil unless @clients[id]
        prune(id)
        @clients[id][:client]
    end

    # sets cache if input is provided, then returns current cache value
    def self.cache(id, input = nil)
        prune(id)
        input ? @clients[id][:cache] = input : @clients[id][:cache]
    end

    def self.cache_nil?(id)
        prune(id)
        @clients[id].nil? || @clients[id][:cache].nil?
    end

    def self.prune(protectID = nil)
        @clients[protectID][:lastUsed] = Time.now if protectID && @clients[protectID]
        safeHours = 5
        @clients.delete_if { |id, connection| (Time.now - connection[:lastUsed]) > (safeHours * 60 * 60) }
    end

end
db.createCollection("flight", {
    validator: {
        $jsonSchema: {
            "bsonType": "object",
            "required": ["FlightNo", "Schedule", "Type", "AircraftId", "AirlineId"],
            "properties": {
              "_id": { "bsonType": "objectId" },
         
              "FlightNo": { "bsonType": "string" },
         
              "Schedule": { "bsonType": "date" },
         
              "Type": { "enum": ["DIRECT", "CONNECTED"] },
         
              "AircraftId": {
                "bsonType": "objectId",
                "description": "Reference to AIRCRAFT._id"
              },
         
              "AirlineId": {
                "bsonType": "objectId",
                "description": "Reference to AIRLINE._id"
              },
         
              "Transit": {
                "bsonType": "object",
                "required": ["City", "Time"],
                "properties": {
                  "City": { "bsonType": "string" },
                  "Time": { "bsonType": "date" }
                }
              }
            }
        }        
    }
});
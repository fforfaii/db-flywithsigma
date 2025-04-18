db.createCollection("seat", {
    validator: {
        $jsonSchema: {
            "bsonType": "object",
            "required": ["AircraftId", "SeatType", "SeatNo"],
            "properties": {
                "_id": { "bsonType": "objectId" },
            
                "AircraftId": {
                "bsonType": "objectId",
                "description": "Reference to AIRCRAFT._id"
                },
            
                "SeatType": {
                "enum": ["ECONOMY", "BUSINESS", "FIRSTCLASS"]
                },
            
                "SeatNo": { "bsonType": "string" }
            }
        }
    }
});
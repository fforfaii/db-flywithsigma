db.createCollection("airline", {
    validator: {
        $jsonSchema: {
            "bsonType": "object",
            "required": ["AirlineName", "TelNo"],
            "properties": {
                "_id": { "bsonType": "objectId" },
                "AirlineName": { "bsonType": "string" },
                "AirlineCaption": { "bsonType": "string" },
                "Website": { "bsonType": "string" },
                "TelNo": {
                    "bsonType": "array",
                    "items": { "bsonType": "string" }
                },
        
                "Aircrafts": {
                    "bsonType": "array",
                    "items": {
                        "bsonType": "objectId"
                    }
                }

            }
        }
    }
});
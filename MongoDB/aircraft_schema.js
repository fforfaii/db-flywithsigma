db.createCollection("aircraft", {
    validator: {
        $jsonSchema: {
                "bsonType": "object",
                "required": ["RegistrationNo", "ModelName", "SeatCapacity", "CabinClass", "SeatAmount"],
                "properties": {
                  "_id": { "bsonType": "objectId" },
                  "RegistrationNo": { "bsonType": "string" },
                  "ModelName": { "bsonType": "string" },
                  "SeatCapacity": { "bsonType": "int" },
                  "CabinClass": {
                            "bsonType": "array",
                            "minItems": 1,
                            "maxItems": 3,
                            "items": {
                                  "enum": ["ECONOMY", "BUSINESS", "FIRSTCLASS"]
                              },
                            "uniqueItems": true
                   },
                  "SeatAmount": {"bsonType":  "int"}
                }
          }
    }
});
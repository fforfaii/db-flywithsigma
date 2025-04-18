db.getCollection('flight').aggregate(
  [
    {
      $match: {
        Type: 'DIRECT',
        Schedule: {
          $gte: ISODate(
            '2025-05-03T00:00:00.000Z'
          ),
          $lte: ISODate(
            '2025-05-06T23:59:59.000Z'
          )
        }
      }
    },
    {
      $lookup: {
        from: 'airline',
        localField: 'AirlineId',
        foreignField: '_id',
        as: 'airline'
      }
    },
    { $unwind: { path: '$airline' } },
    {
      $match: {
        'airline.AirlineName': 'Qatar Airways'
      }
    },
    {
      $lookup: {
        from: 'aircraft',
        localField: 'AircraftId',
        foreignField: '_id',
        as: 'aircraft'
      }
    },
    { $unwind: { path: '$aircraft' } },
    {
      $project: {
        _id: 0,
        FlightNo: 1,
        Type: 1,
        Schedule: 1,
        AirlineName: '$airline.AirlineName',
        ModelName: '$aircraft.ModelName',
        SeatCapacity: '$aircraft.SeatCapacity',
        SeatTypeAvailable: '$aircraft.CabinClass'
      }
    }
  ],
  { maxTimeMS: 60000, allowDiskUse: true }
);
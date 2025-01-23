import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:car_manufac/car_mfr.dart'; // เชื่อมต่อกับไฟล์ car_mfr.dart

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  List<Result> manufacturers = [];
  List<Result> filteredManufacturers = [];

  Future<CarMfr> getCarMfr() async {
    var url = 'vpic.nhtsa.dot.gov';
    var uri =
        Uri.https(url, "/api/vehicles/getallmanufacturers", {"format": "json"});
    var response = await get(uri);

    CarMfr carMfr = carMfrFromJson(response.body);
    manufacturers = carMfr.results!;
    filteredManufacturers = manufacturers;
    return carMfr;
  }

  void filterManufacturers(String query) {
    setState(() {
      filteredManufacturers = manufacturers
          .where((manufacturer) {
            var lowerQuery = query.toLowerCase();
            return (manufacturer.mfrCommonName?.toLowerCase().contains(lowerQuery) ??
                    false) ||
                (manufacturer.mfrName?.toLowerCase().contains(lowerQuery) ??
                    false) ||
                (manufacturer.country?.toLowerCase().contains(lowerQuery) ??
                    false);
          })
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getCarMfr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
          ),
          Expanded(
            child: FutureBuilder<CarMfr>(
              future: getCarMfr(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.red)));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: filteredManufacturers.length,
                    itemBuilder: (context, index) {
                      var manufacturer = filteredManufacturers[index];
                      return Card(
                        elevation: 2.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          leading: Icon(Icons.directions_car,
                              color: Colors.blueGrey),
                          title: Text(
                            "ID: ${manufacturer.mfrId} - ${manufacturer.mfrCommonName ?? "No Name"}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.blueGrey,
                            ),
                          ),
                          subtitle: Text(
                            "Country: ${manufacturer.country}",
                            style: TextStyle(
                              color: Colors.blueGrey[600],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CarDetailsPage(manufacturer),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                      child: Text('No data found',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CarDetailsPage extends StatelessWidget {
  final Result manufacturer;

  CarDetailsPage(this.manufacturer);

  String getVehicleTypeName(String vehicleType) {
    Map<String, String> vehicleTypeMap = {
      'PASSENGER_CAR': 'Passenger Car',
      'TRUCK': 'Truck',
      'SUV': 'SUV',
    };

    return vehicleTypeMap[vehicleType] ?? vehicleType;
  }

  @override
  Widget build(BuildContext context) {
    var vehicleTypes = manufacturer.vehicleTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text('ID: ${manufacturer.mfrId} Details'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manufacturer ID: ${manufacturer.mfrId}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Manufacturer: ${manufacturer.mfrName}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10),
            Text(
              'Country: ${manufacturer.country}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20),
            Text(
              'Vehicle Types:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...(vehicleTypes?.isNotEmpty ?? false)
                ? vehicleTypes!.map<Widget>((vehicle) {
                    return Row(
                      children: [
                        Icon(
                          vehicle.isPrimary! ? Icons.check_circle : Icons.cancel,
                          color: vehicle.isPrimary! ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(
                          getVehicleTypeName(vehicle.name?.toString() ??
                              "Unknown"),
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    );
                  }).toList()
                : [],
          ],
        ),
      ),
    );
  }
}

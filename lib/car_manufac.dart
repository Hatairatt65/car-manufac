import 'package:car_manufac/car_mfr.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  CarMfr? carMfr;

  Future<CarMfr?> getCarMfr() async{
    var url = "vpic.nhtsa.dot.gov";

    var uri = Uri.https(url, "/api/vehicles/getallmanufacturers", {"format": "json"});
    // https://vpic.nhtsa.dot.gov/api/vehicles/getallmanufacturers?format=json&page=2
    await Future.delayed(const Duration(seconds: 3));
    var response = await get(uri);

    carMfr = carMfrFromJson(response.body);
    print(carMfr?.results![0].mfrName);
    return carMfr;
  }

  @override

  void initState() {
    super.initState();
    getCarMfr();
    print("Initiated....");
  }


  @override
  Widget build(BuildContext context) {
    print("Building....");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
      ),
      body: FutureBuilder(
        future: getCarMfr(), 
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.connectionState == ConnectionState.done){
            return Text("Finished loading data ${carMfr?.results![0].mfrName}");
          }
          return LinearProgressIndicator();
        },
      )
    );
  }
}
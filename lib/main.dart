import 'dart:async';
//import 'dart:html';
//import 'dart:html';
//import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';


void main() => runApp(MyApp());
const kGoogleApiKey = "AIzaSyDjWRsbD99Zh2pbbmi3ojJ5x-M9ERh7qjg";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
//final ArgumentCallback<LatLng> onTap

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _controller = Completer();
final Set<Marker> _marker1={};
final Set<Marker> _marker2={};
  //final Distance distance = new Distance();

Marker marker=Marker(markerId: MarkerId("Current"));
final Set<Circle> _circles={};
Set<Polyline> _polylines = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();

MapType _currenttype = MapType.normal;

  LatLng _center=LatLng(18.4640821,73.8654249); 
  LatLng hosp1=LatLng(18.5333877,73.8748232);
  LatLng hosp2=LatLng(18.5260608,73.8694035);
  final String a1="18.4747615",a2="73.8619964";

  Position position;
    BitmapDescriptor pinLocationIcon;

  void coordinates() async
  {
    
 // List<Placemark> placemark = await Geolocator().placemarkFromAddress("Gronausestraat 710, Enschede");
 double distanceInMeters = await Geolocator().distanceBetween(position.latitude,position.longitude,hosp1.latitude, hosp1.longitude);
  //print(placemark);
  double km=distanceInMeters/1000;
  print(distanceInMeters);
  print(km);
  }
  
void initState() 
  {
   //_addmarker();
    super.initState();
    getLocation();
   }
   void _onMapCreated(GoogleMapController controller) {
    getLocation();
    //mapposition();
    _controller.complete(controller);  
  }
_launchURL() async {
    final String a1="18.4747615",a2="73.8619964";
  String url = 'https://www.google.com/maps/@'+a1+','+a2+',15z';
  print('Inside the app');
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}


void _addmarker()
{
    _marker1.add(
      Marker(
    markerId: MarkerId(hosp1.toString()),
    position:hosp1,
    infoWindow: InfoWindow(
      title: 'Sasoon Hospital',
    ),
    icon: BitmapDescriptor.defaultMarkerWithHue(250.0),
    
    ),
  );
}
void marker2()
{
 setState(() 
  {
    _marker1.add(Marker(
    markerId: MarkerId(hosp2.toString()),
    position:hosp2,
    infoWindow: InfoWindow(
      title: 'Ruby Hall Clinic',
    ),
    icon:
        BitmapDescriptor.defaultMarkerWithHue(200.0),
  ));
  });
}
  void _addcircle()
  {
    setState(()
    {
      getLocation();
    _circles.add(Circle(
    circleId: CircleId("circle"),
    center: LatLng(position.latitude,position.longitude),
    radius: 0,
        ));   
  });
  }

   void _maptypechange() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _currenttype = _currenttype == MapType.normal
        ? MapType.satellite
        : MapType.normal;
    });
 
  }


  setPolylines() async {
   List<PointLatLng> result = await
      polylinePoints?.getRouteBetweenCoordinates(
         kGoogleApiKey,
         position.latitude, 
         position.longitude,
         hosp1.latitude, 
         hosp1.longitude);
   if(result.isNotEmpty){
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point){
         polylineCoordinates.add(
            LatLng(point.latitude, point.longitude));
      });
   }
   setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
         polylineId: PolylineId('poly'),
         color: Color.fromARGB(255, 40, 122, 198),
         points: polylineCoordinates
      );
 
      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    });
}


   void getLocation() async
  {
   position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
   //print(position);
  }
   Future<void> mapposition() async 
   { 
    getLocation();
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(position.latitude,position.longitude), 15.0));
    }
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Ambulance',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
         appBar: AppBar(
          title: Text('Smart Ambulance'),
          backgroundColor: Colors.green[700],
        ),
        body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
   child: Align(
     alignment: Alignment.topCenter,
     child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 15.0,
          ),
          mapType: _currenttype,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: _marker1,
          circles: _circles,
          polylines: _polylines,
         // onTap: _handleTap,
        ),
        ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
        child: Align(
         alignment: Alignment.bottomRight,
        child: Column(
        children: <Widget>[
          FloatingActionButton(
            heroTag: "btn1",
           onPressed: _maptypechange,
           child: Icon(Icons.satellite),
          ),
            SizedBox(height: 16.0),
        FloatingActionButton(
            heroTag: "btn2",
          onPressed: ()
          {
            _addcircle();
            mapposition();
            coordinates();
         },
         child: Icon(Icons.my_location),
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            heroTag: "btn3",
          onPressed: ()
          {
           _addmarker();
            marker2();
         },
         child: Icon(Icons.place),
          ),
        
        ] 
      ),
        ),  
    ),
        ],
        ),
      ),
    );
  }
}
 
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // latitude - 위도, longitude - 경도
  static final LatLng companyLatLng = LatLng(37.501520, 126.787560);

  // CameraPosition : 우주에서 지구를 바라보는 시점
  static final CameraPosition initialPosition = CameraPosition(
    target: companyLatLng, // target엔 위도와 경도를 넣어주면 됨
    zoom: 15, // 작을수록 멀리! 클수록 가깝게
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: renderAppBar(),
        body: Column(
          children: [
            _CustomGoogleMap(initialPosition: initialPosition),
            _ChoolCheckButton(),
          ],
        ),
      ),
    );
  }

  AppBar renderAppBar() {
    return AppBar(
      centerTitle: true,
      title: const Text(
        '오늘도 출근',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final CameraPosition initialPosition;
  const _CustomGoogleMap({Key? key, required this.initialPosition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        initialCameraPosition:
            initialPosition, // 구글 지도를 처음 실행했을때 어떤 위치를 바라보고 있을지
        mapType: MapType.normal, // 높낮이가 표시가 됨
      ),
    );
  }
}

class _ChoolCheckButton extends StatelessWidget {
  const _ChoolCheckButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text('출근'),
    );
  }
}

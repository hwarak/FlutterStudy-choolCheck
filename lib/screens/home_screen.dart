import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
        body: FutureBuilder(
          // Future를 리턴해주는 어떤 함수든 넣어줄 수 있다,
          // 그리고 함수의 상태가 변경될때마다(ex. 로딩중이거나, 로딩이 끝났거나)
          // builder를 다시 실행해서  화면을 다시 그려줄 수 있다
          // 그리고 future가 리턴해준 값을 snapshot에서 받아 볼 수 있다.
          future: checkPermission(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 로딩 상태
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // 로딩이 끝나서 데이터를 받았어
            // 받은 데이터가 이거와 같다면! 리턴해줘
            if (snapshot.data == '위치 권한이 허가되었습니다.') {
              return Column(
                children: [
                  _CustomGoogleMap(initialPosition: initialPosition),
                  _ChoolCheckButton(),
                ],
              );
            }

            // 그게 아니라면 그냥 메세지를 화면 가운데다 띄우자
            return Center(
              child: Text(snapshot.data),
            );
          },
        ),
      ),
    );
  }

  // 권한과 관련된 모든 기능은 async로 작업해야해
  // 권한 요청을 하고서 유저의 input을 기다리기때문에
  // 미래의 값으로 작업을 하는것이기 때문에 모두 async로 작업하겠디
  Future<String> checkPermission() async {
    // Geolocator.isLocationServiceEnabled() : 핸드폰 기기 자체의 로케이션 서비스가 활성화 되어있는지 확인하는거임
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      // isLocationEnabled이 false라면 == 로케이션 서비스가 꺼져있다면
      return '위치 서비스를 활성화해주세요.';
    }

    // Geolocator.checkPermission() : 현재 앱이 갖고있는 위치서비스에 대한 권한이 어떻게 되는지
    // LocationPermission 형태로 가져올 수 있다.

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    if (checkedPermission == LocationPermission.denied) {
      // 만약 현재 앱이 갖고있는 위치서비스에 대한 권한이 denied라면
      // 권한 요청을 보내야한다.
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        // 여전히 denied 상태라면 에러 메세지를 보낸다
        return '위치 권한을 허가해주세요.';
      }
    }
    if (checkedPermission == LocationPermission.deniedForever) {
      // 거절한 상태라면
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }

    // 여기까지 통과했다면 권한(whileInUse or always)이 있는거임 !!!!!!
    return '위치 권한이 허가되었습니다.';
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

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

  static final double okDistance = 100;

  static final Circle withinDistanceCircle = Circle(
    // 화면에 여러개의 동그라미르르 그렸을때
    // 한 동그라미와 다른 동그라미를 구분할 수 있게된다.
    circleId: CircleId('withinDistanceCircle'),
    center: companyLatLng, // 회사를 중심으로 하겠다!
    fillColor: Colors.blue.withOpacity(0.5), // 원의 내부 색깔
    radius:
        okDistance, // 반지름(반경), 출석 체크를 할 수 있는 미터 수, 미터기준으로 받게 됩니다 !!! , 반지름이 100m
    strokeColor: Colors.blue, //  원의 둘레 색깔
    strokeWidth: 1, // 둘레를 어느정도의 두께로 할건지
  );

  static final Circle notwithinDistanceCircle = Circle(
    circleId: CircleId('notwithinDistanceCircle'),
    center: companyLatLng,
    fillColor: Colors.red.withOpacity(0.5),
    radius: okDistance,
    strokeColor: Colors.red,
    strokeWidth: 1,
  );

  static final Circle checkDoneCircle = Circle(
    circleId: CircleId('checkDoneCircle'),
    center: companyLatLng,
    fillColor: Colors.green.withOpacity(0.5),
    radius: okDistance,
    strokeColor: Colors.green,
    strokeWidth: 1,
  );

  static final Marker marker = Marker(
    markerId: MarkerId('marker'),
    position: companyLatLng,
  );
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: renderAppBar(),
        body: FutureBuilder<String>(
          // Future를 리턴해주는 어떤 함수든 넣어줄 수 있다,
          // 그리고 함수의 상태가 변경될때마다(ex. 로딩중이거나, 로딩이 끝났거나)
          // builder를 다시 실행해서  화면을 다시 그려줄 수 있다
          // 그리고 future가 리턴해준 값을 snapshot에서 받아 볼 수 있다.
          future: checkPermission(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 로딩 상태
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // 로딩이 끝나서 데이터를 받았어
            // 받은 데이터가 이거와 같다면! 리턴해줘
            if (snapshot.data == '위치 권한이 허가되었습니다.') {
              return StreamBuilder<Position>(
                  stream: Geolocator.getPositionStream(),
                  builder: (context, snapshot) {
                    // 기본값은 true이지만 내 위치가 반경 100m 안에 있다면 true로 해주자
                    bool isWithinrange = false;
                    if (snapshot.hasData) {
                      // 만약 데이터가 있다면 실행한다
                      // 거리를 측정할 첫번째 데이터, 느낌표를 붙힌 이유는 snapshot.hasData가 true이기 때문이지
                      // 지금 여기서 snapshot.data는 내 현재 위치를 Position으로 클래스로 표시한것
                      final start = snapshot.data!;
                      final end = companyLatLng; // 회사 위치를 넣어주자

                      final distance = Geolocator.distanceBetween(
                        start.latitude,
                        start.longitude,
                        end.latitude,
                        end.longitude,
                      );

                      if (distance < okDistance) {
                        //  나랑 회사의 거리가 100m보다 작다면
                        isWithinrange = true;
                      }
                    }
                    return Column(
                      children: [
                        _CustomGoogleMap(
                          initialPosition: initialPosition,
                          circle: isWithinrange
                              ? withinDistanceCircle
                              : notwithinDistanceCircle,
                          marker: marker,
                        ),
                        _ChoolCheckButton(
                          isWithinrange: isWithinrange,
                          onPressed: onChoolCheckPressed,
                        ),
                      ],
                    );
                  });
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

  void onChoolCheckPressed() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('출근하기'),
          content: Text('출근을 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('출근하기'),
            ),
          ],
        );
      },
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
  final Circle circle;
  final Marker marker;
  const _CustomGoogleMap(
      {Key? key,
      required this.initialPosition,
      required this.circle,
      required this.marker})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        initialCameraPosition:
            initialPosition, // 구글 지도를 처음 실행했을때 어떤 위치를 바라보고 있을지
        mapType: MapType.normal, // 높낮이가 표시가 됨
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        circles: Set.from([circle]), // Set로 값이 들어가서 중복체크를 해줌.
        markers: Set.from([marker]),
      ),
    );
  }
}

class _ChoolCheckButton extends StatelessWidget {
  final bool isWithinrange;
  final VoidCallback onPressed;
  const _ChoolCheckButton(
      {Key? key, required this.isWithinrange, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timelapse_outlined,
            size: 50.0,
            color: isWithinrange ? Colors.blue : Colors.red,
          ),
          const SizedBox(
            height: 20.0,
          ),
          if (isWithinrange)
            TextButton(
              // 출근할수 있는 위치에 있으면 보이고 없으면 안보이게끔 할 수 있어!
              onPressed: onPressed,
              child: const Text('출근하기'),
            ),
        ],
      ),
    );
  }
}

class RideRepository {
  RideRepository._();
  static RideRepository? _instance;

  static RideRepository? get instance {
    if (_instance == null) {
      _instance = RideRepository._();
    }
    return _instance;
  }

  //load ride

  //See all ride

  //Cancel ride

  //board ride

}

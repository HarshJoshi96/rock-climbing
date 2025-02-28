class ActivityData {
  List<Facility>? facility;
  String? details;
  String? longitude;
  List<TimeSlots>? timeSlots;
  String? price;
  String? placeName;
  String? latitude;
  List<Type>? type;
  String? name;
  String? url;

  ActivityData(
      {this.facility,
      this.details,
      this.longitude,
      this.timeSlots,
      this.price,
      this.placeName,
      this.latitude,
      this.type,
      this.name,
      this.url});

  ActivityData.fromJson(Map<String, dynamic> json) {
    if (json['facility'] != null) {
      facility = <Facility>[];
      json['facility'].forEach((v) {
        facility!.add(new Facility.fromJson(v));
      });
    }
    details = json['details'];
    longitude = json['longitude'];
    if (json['timeSlots'] != null) {
      timeSlots = <TimeSlots>[];
      json['timeSlots'].forEach((v) {
        timeSlots!.add(new TimeSlots.fromJson(v));
      });
    }
    price = json['price'];
    placeName = json['placeName'];
    latitude = json['latitude'];
    if (json['type'] != null) {
      type = <Type>[];
      json['type'].forEach((v) {
        type!.add(new Type.fromJson(v));
      });
    }
    name = json['name'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.facility != null) {
      data['facility'] = this.facility!.map((v) => v.toJson()).toList();
    }
    data['details'] = this.details;
    data['longitude'] = this.longitude;
    if (this.timeSlots != null) {
      data['timeSlots'] = this.timeSlots!.map((v) => v.toJson()).toList();
    }
    data['price'] = this.price;
    data['placeName'] = this.placeName;
    data['latitude'] = this.latitude;
    if (this.type != null) {
      data['type'] = this.type!.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['url'] = this.url;
    return data;
  }
}

class Facility {
  String? name;
  String? price;
  String? time;

  Facility({this.name, this.price, this.time});

  Facility.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['time'] = this.time;
    return data;
  }
}

class TimeSlots {
  String? date;
  String? time;

  TimeSlots({this.date, this.time});

  TimeSlots.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['time'] = this.time;
    return data;
  }
}

class Type {
  String? name;
  String? price;
  String? description;

  Type({this.name, this.price, this.description});

  Type.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    data['description'] = this.description;
    return data;
  }
}

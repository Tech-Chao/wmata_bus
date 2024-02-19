class BusPrediction {
  String? rid;
  String? tripid;
  String? schdtm;
  String? tmstmp;
  String? typ;
  String? stpnm;
  String? stpid;
  String? vid;
  int? dstp;
  String? rt;
  String? rtdir;
  String? des;
  String? prdtm;
  String? tablockid;
  String? tatripid;
  bool? dly;
  String? prdctdn;
  String? zone;

  BusPrediction(
      {this.rid,
      this.tripid,
      this.schdtm,
      this.tmstmp,
      this.typ,
      this.stpnm,
      this.stpid,
      this.vid,
      this.dstp,
      this.rt,
      this.rtdir,
      this.des,
      this.prdtm,
      this.tablockid,
      this.tatripid,
      this.dly,
      this.prdctdn,
      this.zone});

  BusPrediction.fromJson(Map<String, dynamic> json) {
    rid = json['rid'];
    tripid = json['tripid'];
    schdtm = json['schdtm'];
    tmstmp = json['tmstmp'];
    typ = json['typ'];
    stpnm = json['stpnm'];
    stpid = json['stpid'];
    vid = json['vid'];
    dstp = json['dstp'];
    rt = json['rt'];
    rtdir = json['rtdir'];
    des = json['des'];
    prdtm = json['prdtm'];
    tablockid = json['tablockid'];
    tatripid = json['tatripid'];
    dly = json['dly'];
    prdctdn = json['prdctdn'];
    zone = json['zone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rid'] = rid;
    data['tripid'] = tripid;
    data['schdtm'] = schdtm;
    data['tmstmp'] = tmstmp;
    data['typ'] = typ;
    data['stpnm'] = stpnm;
    data['stpid'] = stpid;
    data['vid'] = vid;
    data['dstp'] = dstp;
    data['rt'] = rt;
    data['rtdir'] = rtdir;
    data['des'] = des;
    data['prdtm'] = prdtm;
    data['tablockid'] = tablockid;
    data['tatripid'] = tatripid;
    data['dly'] = dly;
    data['prdctdn'] = prdctdn;
    data['zone'] = zone;
    return data;
  }
}

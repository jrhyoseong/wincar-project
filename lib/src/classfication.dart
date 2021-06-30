class Classfication {

  String classTy;
  String classTyNm;

  Classfication({
    String classTy,
    String classTyNm
  }){
    this.classTy = classTy;
    this.classTyNm = classTyNm;
  }

  factory Classfication.fromJson(Map<String, dynamic> json) {
    return Classfication(
      classTy: json['classTy'],
      classTyNm: json['classTyNm'],
    );
  }

}